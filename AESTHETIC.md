# Design System — h3 dotfiles

## Color Palette — Catppuccin Mocha

| Token      | Hex         | Uso                              |
|------------|-------------|----------------------------------|
| `base`     | `#1e1e2e`   | Fondo principal                  |
| `surface0` | `#313244`   | Separadores, hover               |
| `surface1` | `#45475a`   | Bordes sutiles                   |
| `overlay0` | `#6c7086`   | Apagado / muteado / inactivo     |
| `subtext`  | `#a6adc8`   | Texto e iconos normales          |
| `text`     | `#cdd6f4`   | Énfasis / texto principal        |
| `accent`   | `#89b4fa`   | Activo / seleccionado            |
| `ok`       | `#a6e3a1`   | Correcto / cargando              |
| `warn`     | `#f9e2af`   | Advertencia                      |
| `crit`     | `#f38ba8`   | Crítico / error                  |

## Principios de Diseño

- **Plano y minimalista**: sin fondos por módulo, sin bloques de color. La separación visual la dan separadores finos (`1px solid`).
- **Color = estado**: el color no decora, señala. Normal es `subtext`, activo es `accent`, error es `crit`.
- **Transparencia**: fondos con opacidad (kitty `0.8`, mako con alpha `A6`). La wallpaper se ve a través.
- **Subrayado > fondo**: para marcar selección activa se usa `box-shadow: inset 0 -2px @accent` en vez de cambiar el fondo.
- **Flat sin border-radius**: bordes rectos, sin esquinas redondeadas (waybar `border-radius: 0`).

## Tipografía

| Contexto   | Fuente                        | Tamaño  |
|------------|-------------------------------|---------|
| Terminal   | Comic Sans MS                 | 10px    |
| Barra      | Noto Sans + Symbols Nerd Font | 13px    |
| Notificaciones | Liberation Sans           | 11px    |

- **Iconos**: Symbols Nerd Font (glifos Material Design `U+F0000+`).
- En terminal se prioriza legibilidad personal; en barra, densidad de información.

## Iconografía

Usar Nerd Font glyphs. Convención en waybar:

| Estado       | Ejemplo icono | Color     |
|--------------|---------------|-----------|
| Normal       | `󰕾` `󰖩`     | `@subtext`|
| Activo       | `󰈈`          | `@accent` |
| Muteado/off  | `󰝟` `󰖪`     | `@overlay0`|
| Warning      | `󰔏`          | `@warn`   |
| Error        | —             | `@crit`   |

## Efectos

- **Hover**: fondo `@surface0`, texto `@text`. Sin transiciones bruscas.
- **Animaciones**: solo opacidad (blink en batería crítica: `opacity 0.3`, alternando).
- **Transiciones**: `transition-duration: .5s` en fondo de barra.

## Geometría Waybar

- Altura: `26px`
- Spacing entre módulos: `0` (separadores CSS, no gap)
- Padding módulos: `0 10px`
- Separadores: `border-left: 1px solid @surface0`

## Referencias

- Waybar CSS: `waybar/style.css`
- Waybar config: `waybar/config`
- Mako config: `mako/config`
- Kitty config: `kitty/kitty.conf` + `kitty/no-preference-theme.auto.conf`
- Sway config: `sway/config`
