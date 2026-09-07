#!/bin/sh
# Instala mpvpaper (wallpaper animado para Sway) en ~/.local, sin sudo.
#
# Ubuntu 24.04 no empaqueta mpvpaper, así que va compilado desde fuente. Para
# no pedir root, las dependencias de compilación se bajan con apt-get download
# (que no necesita permisos) y se desempaquetan en ~/.local en vez de /usr:
#
#   meson, ninja        pip --user
#   libmpv2/-dev        el binario mpv de Ubuntu no trae libmpv, hay que traerla
#   wayland-protocols   solo XMLs, los usa wayland-scanner al compilar
#
# libwayland-dev y libegl-dev ya vienen con el sistema.
#
# Como libmpv queda en ~/.local/lib (no en el ldconfig del sistema), el binario
# se linkea con un RPATH a esa carpeta. Así funciona sin LD_LIBRARY_PATH.
#
# Si algún día preferís la versión system-wide, es equivalente a:
#   sudo apt install meson ninja-build libmpv-dev wayland-protocols libegl1-mesa-dev
# y compilar con --prefix=/usr/local.

set -e

PREFIX="$HOME/.local"
WORK="${XDG_CACHE_HOME:-$HOME/.cache}/mpvpaper-build"
ARCH="$(dpkg-architecture -qDEB_HOST_MULTIARCH)"

rm -rf "$WORK"
mkdir -p "$WORK/debs" "$WORK/sysroot" "$PREFIX/lib/pkgconfig" "$PREFIX/include" "$PREFIX/share"

echo ">> meson y ninja"
pip3 install -q --user --break-system-packages meson ninja

echo ">> dependencias de compilación (sin root)"
(cd "$WORK/debs" && apt-get download libmpv2 libmpv-dev wayland-protocols)
for deb in "$WORK"/debs/*.deb; do dpkg -x "$deb" "$WORK/sysroot"; done

echo ">> instalando dependencias en $PREFIX"
cp -a "$WORK/sysroot/usr/include/mpv" "$PREFIX/include/"
cp -a "$WORK/sysroot/usr/lib/$ARCH/"libmpv.so* "$PREFIX/lib/"
cp -a "$WORK/sysroot/usr/share/wayland-protocols" "$PREFIX/share/"
# Los .pc vienen con prefix=/usr; reapuntarlos a $PREFIX
sed "s|^prefix=/usr$|prefix=$PREFIX|" \
    "$WORK/sysroot/usr/lib/$ARCH/pkgconfig/mpv.pc" \
    > "$PREFIX/lib/pkgconfig/mpv.pc"
sed "s|^prefix=/usr$|prefix=$PREFIX|" \
    "$WORK/sysroot/usr/share/pkgconfig/wayland-protocols.pc" \
    > "$PREFIX/lib/pkgconfig/wayland-protocols.pc"
# mpv.pc apunta a ${prefix}/lib/<arch>, pero acá la .so quedó en ${prefix}/lib
sed -i "s|^libdir=.*|libdir=\${prefix}/lib|" "$PREFIX/lib/pkgconfig/mpv.pc"
# Requires.private lista las ~40 libs con las que se compiló mpv (ffmpeg, lua,
# libva...). Solo hacen falta para linkeo estático, pero pkg-config igual las
# resuelve y falla porque no están los -dev. Linkeamos dinámico, así que fuera.
sed -i "/^Requires.private:/d" "$PREFIX/lib/pkgconfig/mpv.pc"

echo ">> compilando mpvpaper"
git clone -q --depth 1 --single-branch https://github.com/GhostNaN/mpvpaper "$WORK/src"
PATH="$PREFIX/bin:$PATH" \
PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig:${PKG_CONFIG_PATH:-}" \
    meson setup "$WORK/build" "$WORK/src" \
        --prefix="$PREFIX" \
        -Dc_link_args="-Wl,-rpath,$PREFIX/lib"
PATH="$PREFIX/bin:$PATH" ninja -C "$WORK/build"
PATH="$PREFIX/bin:$PATH" ninja -C "$WORK/build" install

echo
"$PREFIX/bin/mpvpaper" --help >/dev/null 2>&1 \
    && echo "mpvpaper instalado en $PREFIX/bin/mpvpaper" \
    || { echo "algo falló, mpvpaper no corre"; exit 1; }
