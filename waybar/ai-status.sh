#!/bin/bash
# Cuota restante de OpenCode Go y Claude Code para waybar (custom/ai).
# Muestra el % que queda del límite más restrictivo de cada uno (ventana 5h).

ICON=$'󰚩' # nf-md-robot-outline
CLAUDE_CREDS="${XDG_CONFIG_HOME:-$HOME/.claude}/.credentials.json"
# Claude guarda creds en ~/.claude aunque XDG diga otra cosa
[[ -f $CLAUDE_CREDS ]] || CLAUDE_CREDS="$HOME/.claude/.credentials.json"
OPENCODE_AUTH="${XDG_DATA_HOME:-$HOME/.local/share}/opencode/auth.json"
CACHE="/tmp/waybar-ai-status.cache"
CACHE_TTL=45

json_escape() {
    local s=${1//\\/\\\\}
    s=${s//\"/\\\"}
    s=${s//$'\n'/\\n}
    printf '%s' "$s"
}

emit() {
    printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' \
        "$(json_escape "$1")" "$(json_escape "$2")" "$3"
    exit 0
}

remaining_of() {
    # used% → remaining%, acotado a 0..100
    local used=${1%.*}
    [[ $used =~ ^[0-9]+$ ]] || { printf '?'; return; }
    local rem=$((100 - used))
    ((rem < 0)) && rem=0
    ((rem > 100)) && rem=100
    printf '%s' "$rem"
}

fmt_reset() {
    # ISO → "HH:MM" local si es hoy, si no "dd/mm HH:MM"
    local iso=$1
    [[ -n $iso && $iso != null ]] || { printf '—'; return; }
    local ts
    ts=$(date -d "$iso" +%s 2>/dev/null) || { printf '%s' "$iso"; return; }
    local today now
    today=$(date +%Y-%m-%d)
    local day
    day=$(date -d "@$ts" +%Y-%m-%d)
    if [[ $day == "$today" ]]; then
        date -d "@$ts" +%H:%M
    else
        date -d "@$ts" '+%d/%m %H:%M'
    fi
}

# Cache corto: las APIs no necesitan pegarse cada tick de waybar
if [[ -f $CACHE ]]; then
    age=$(($(date +%s) - $(stat -c %Y "$CACHE" 2>/dev/null || echo 0)))
    if ((age >= 0 && age < CACHE_TTL)); then
        cat "$CACHE"
        exit 0
    fi
fi

go_rem='?'
go_tip='OpenCode Go: sin datos'
claude_rem='?'
claude_tip='Claude: sin datos'
min_rem=100
have=0

# ── OpenCode Go ──────────────────────────────────────────────────────────────
# GET https://opencode.ai/zen/go/v1/usage  → percent = usado
if [[ -f $OPENCODE_AUTH ]]; then
    go_key=$(python3 -c "import json,sys; print(json.load(open(sys.argv[1])).get('opencode-go',{}).get('key',''))" "$OPENCODE_AUTH" 2>/dev/null)
    if [[ -n $go_key ]]; then
        go_json=$(curl -fsS --max-time 8 \
            -H "Authorization: Bearer $go_key" \
            -H "Accept: application/json" \
            -H "User-Agent: opencode/waybar" \
            "https://opencode.ai/zen/go/v1/usage" 2>/dev/null) || go_json=""
        if [[ -n $go_json ]]; then
            read -r g_roll g_week g_month g_rr g_wr g_mr < <(
                printf '%s' "$go_json" | python3 -c '
import json,sys
d=json.load(sys.stdin).get("usage",{})
def p(k):
    x=d.get(k) or {}
    return str(x.get("percent","")), str(x.get("resetsAt") or "")
a,b=p("rolling"); c,d_=p("weekly"); e,f=p("monthly")
print(a,c,e,b,d_,f)
' 2>/dev/null
            )
            go_rem=$(remaining_of "$g_roll")
            [[ $go_rem != '?' ]] && { have=1; ((go_rem < min_rem)) && min_rem=$go_rem; }
            go_tip="OpenCode Go (restante)
  5h:     ${go_rem}%  reset $(fmt_reset "$g_rr")
  semana: $(remaining_of "$g_week")%  reset $(fmt_reset "$g_wr")
  mes:    $(remaining_of "$g_month")%  reset $(fmt_reset "$g_mr")"
        else
            go_tip='OpenCode Go: error al consultar'
        fi
    else
        go_tip='OpenCode Go: sin API key (opencode auth)'
    fi
else
    go_tip='OpenCode Go: falta auth.json'
fi

# ── Claude Code ──────────────────────────────────────────────────────────────
# GET https://api.anthropic.com/api/oauth/usage  → utilization = usado
if [[ -f $CLAUDE_CREDS ]]; then
    claude_tok=$(python3 -c "import json,sys; print(json.load(open(sys.argv[1])).get('claudeAiOauth',{}).get('accessToken',''))" "$CLAUDE_CREDS" 2>/dev/null)
    if [[ -n $claude_tok ]]; then
        claude_json=$(curl -fsS --max-time 8 \
            -H "Authorization: Bearer $claude_tok" \
            -H "Content-Type: application/json" \
            -H "User-Agent: claude-cli/2.1.241 (external, cli)" \
            -H "anthropic-beta: oauth-2025-04-20" \
            -H "Accept: application/json" \
            "https://api.anthropic.com/api/oauth/usage" 2>/dev/null) || claude_json=""
        if [[ -n $claude_json ]]; then
            read -r c_5h c_week c_5r c_wr < <(
                printf '%s' "$claude_json" | python3 -c '
import json,sys
d=json.load(sys.stdin)
def u(k):
    x=d.get(k) or {}
    v=x.get("utilization")
    r=x.get("resets_at") or ""
    return ("" if v is None else str(v)), str(r)
a,b=u("five_hour"); c,d_=u("seven_day")
print(a,c,b,d_)
' 2>/dev/null
            )
            claude_rem=$(remaining_of "$c_5h")
            [[ $claude_rem != '?' ]] && { have=1; ((claude_rem < min_rem)) && min_rem=$claude_rem; }
            claude_tip="Claude Pro (restante)
  5h:     ${claude_rem}%  reset $(fmt_reset "$c_5r")
  semana: $(remaining_of "$c_week")%  reset $(fmt_reset "$c_wr")"
        else
            claude_tip='Claude: error al consultar (¿token vencido?)'
        fi
    else
        claude_tip='Claude: sin accessToken'
    fi
else
    claude_tip='Claude: falta .credentials.json'
fi

text="$ICON ${go_rem}% · ${claude_rem}%"
tooltip="$go_tip

$claude_tip"

if ((have == 0)); then
    class=error
elif ((min_rem <= 10)); then
    class=critical
elif ((min_rem <= 30)); then
    class=warning
else
    class=ok
fi

out=$(printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' \
    "$(json_escape "$text")" "$(json_escape "$tooltip")" "$class")
printf '%s' "$out" >"$CACHE"
printf '%s' "$out"
