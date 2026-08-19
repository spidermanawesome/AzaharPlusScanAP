#!/bin/sh -ex

mkdir build
cd build

if [ "$GITHUB_REF_TYPE" == "tag" ]; then
	export EXTRA_CMAKE_FLAGS=(-DENABLE_QT_UPDATE_CHECKER=ON)
fi

cmake .. -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_COMPILER_LAUNCHER=ccache \
    -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
    -DENABLE_QT_TRANSLATION=ON \
    -DUSE_DISCORD_PRESENCE=ON \
    -DENABLE_TESTS=OFF \
	"${EXTRA_CMAKE_FLAGS[@]}"
	
ninja
ninja bundle

# Manually copy zlib DLLs to ensure they're included in the bundle
if [ -f "$VCPKG_INSTALLATION_ROOT/installed/x64-windows/bin/zlib1.dll" ]; then
    cp "$VCPKG_INSTALLATION_ROOT/installed/x64-windows/bin/zlib1.dll" bundle/
fi
if [ -f "$VCPKG_INSTALLATION_ROOT/installed/x64-windows/bin/z.dll" ]; then
    cp "$VCPKG_INSTALLATION_ROOT/installed/x64-windows/bin/z.dll" bundle/
fi

strip -s bundle/*.exe

ccache -s -v
