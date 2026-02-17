#!/bin/bash
set -e

INFO='\033[1;34m'
SUCCESS='\033[1;32m'
WARNING='\033[1;33m'
ERROR='\033[1;31m'
NC='\033[0m'

echo -e "${INFO}===== BUILD WEB (WebAssembly) =====${NC}"

########################################
# 1️⃣ Check root / sudo
########################################

if [ "$(id -u)" -eq 0 ]; then
  PKG_MANAGER="apt-get"
else
  if command -v sudo &> /dev/null; then
    PKG_MANAGER="sudo apt-get"
  else
    echo -e "${ERROR}Need root or sudo privileges.${NC}"
    exit 1
  fi
fi

########################################
# 2️⃣ Install required packages
########################################

REQUIRED_PACKAGES=(
    build-essential
    cmake
    ninja-build
    git
    python3
)

echo -e "${INFO}---> Checking required packages...${NC}"
MISSING=()

for pkg in "${REQUIRED_PACKAGES[@]}"; do
    if ! dpkg -s "$pkg" &> /dev/null; then
        MISSING+=("$pkg")
    fi
done

if [ ${#MISSING[@]} -ne 0 ]; then
    echo -e "${WARNING}Installing missing packages...${NC}"
    $PKG_MANAGER update
    $PKG_MANAGER install -y "${MISSING[@]}"
fi

########################################
# 3️⃣ Install Emscripten if missing
########################################

if ! command -v emcc &> /dev/null; then
    echo -e "${INFO}---> Installing Emscripten...${NC}"
    git clone https://github.com/emscripten-core/emsdk.git $HOME/emsdk
    cd $HOME/emsdk
    ./emsdk install latest
    ./emsdk activate latest
    cd -
fi

########################################
# 4️⃣ Load emsdk environment
########################################

if [ -f "$HOME/emsdk/emsdk_env.sh" ]; then
    source "$HOME/emsdk/emsdk_env.sh"
else
    echo -e "${ERROR}emsdk_env.sh not found!${NC}"
    exit 1
fi

########################################
# 5️⃣ Clean old build
########################################

echo -e "${INFO}---> Cleaning old build...${NC}"
rm -rf build_web
mkdir build_web

########################################
# 6️⃣ Configure CMake for WebAssembly
########################################

echo -e "${INFO}---> Configuring CMake (Web)...${NC}"
emcmake cmake -S . -B build_web -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_EXECUTABLE_SUFFIX=".html"

########################################
# 7️⃣ Build
########################################

echo -e "${INFO}---> Building project...${NC}"
emmake cmake --build build_web -- -j$(nproc)

echo ""
echo -e "${SUCCESS}===== BUILD COMPLETE =====${NC}"
echo "Output folder: build_web/"
echo ""
echo "Run locally with:"
echo "  source \$HOME/emsdk/emsdk_env.sh"
echo "  emrun build_web/*.html"
