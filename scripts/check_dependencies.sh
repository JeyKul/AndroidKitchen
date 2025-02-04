#!/bin/bash

# Ensure 'debug' is set to a valid integer (default to 0 if not set)
if [[ -z "$debug" ]] || ! [[ "$debug" =~ ^[0-1]$ ]]; then
  debug=0
fi

# Check if the filesystem supports EROFS
if ! grep -q "erofs" /proc/filesystems; then
  echo "Error: EROFS support not found. Aborting."
  exit 1
fi

KITCHEN_HOME=$(pwd)

mkdir -p $KITCHEN_HOME/ext
BINARYPATH="$KITCHEN_HOME/ext/bin"
mkdir -p "$BINARYPATH"

PACKAGES=(
  libbrotli-dev liblz4-dev libzstd-dev
  openjdk-17-jdk
  python3
  python-is-python3 zip
)

# Function to check and install a package using apt
install_package() {
  local package="$1"
  if ! dpkg -l | grep -q "$package"; then
    echo "Package $package not found. Installing..."
    sudo apt update > /dev/null 2>&1
    sudo apt install -y "$package" > /dev/null 2>&1 || { echo "Failed to install $package. Attempting to compile from source..."; compile_package "$package"; }
  fi
}

download_needed_bins(){
  wget -nc https://github.com/AndroidDumps/Firmware_extractor/raw/refs/heads/master/tools/lpunpack -P $BINARYPATH > /dev/null 2>&1
  chmod +x $BINARYPATH/lpunpack

  SIMG2IMGPATH=$KITCHEN_HOME/ext/simg2img
  git clone --quiet https://github.com/anestisb/android-simg2img $SIMG2IMGPATH > /dev/null 2>&1
  cd $SIMG2IMGPATH
  make > /dev/null 2>&1
  cp *2*img $BINARYPATH 
  cd $KITCHEN_HOME
}

# Function to compile a package from source
compile_package() {
  local package="$1"
  case "$package" in
    libbrotli-dev)

      LIBBROTLIPATH="$KITCHEN_HOME/ext/libbrotli"

      git clone --quiet https://github.com/google/brotli "$LIBBROTLIPATH" > /dev/null 2>&1

      cd "$LIBBROTLIPATH"
      mkdir -p out
      cd out

      cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=./installed .. > /dev/null 2>&1
      cmake --build . --config Release > /dev/null 2>&1

      cp "$LIBBROTLIPATH/out/"*brotli* "$BINARYPATH"

      ;;
    liblz4-dev)

      LIBLZ4PATH="$KITCHEN_HOME/ext/liblz4"

      git clone --quiet https://github.com/lz4/lz4.git "$LIBLZ4PATH" > /dev/null 2>&1

      cd "$LIBLZ4PATH"
      mkdir -p build
      cd build

      cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=./installed .. > /dev/null 2>&1
      make -j$(nproc) > /dev/null 2>&1
      cp "$LIBLZ4PATH/build/installed/bin/lz4" "$BINARYPATH"

      ;;
    libzstd-dev)
      LIBZSTD_PATH="$KITCHEN_HOME/ext/libzstd"

      git clone --quiet https://github.com/facebook/zstd.git "$LIBZSTD_PATH" > /dev/null 2>&1
      cd "$LIBZSTD_PATH"
      make clean > /dev/null 2>&1
      make -j$(nproc) > /dev/null 2>&1
      cp "$LIBZSTD_PATH/programs/zstd" "$BINARYPATH"
      ;;
    openjdk-17-jdk)
    OPENJDKPATH="$KITCHEN_HOME/ext/java"
    JAVAFILENAME="openjdk-23.0.1_linux-x64_bin.tar.gz"
      wget --quiet https://download.java.net/java/GA/jdk23.0.1/c28985cbf10d4e648e4004050f8781aa/11/GPL/openjdk-23.0.1_linux-x64_bin.tar.gz -P $OPENJDKPATH
      mkdir $OPENJDKPATH/unpack
      tar -xvzf $JAVAFILENAME -C $OPENJDKPATH/unpack > /dev/null 2>&1
      cp $OPENJDKPATH/unpack/jdk-23.0.1 $BINARYPATH/jdk-23.0.1
      ln -s $BINARYPATH/java $BINARYPATH/jdk-23.0.1/bin/java
      ;;
  esac
}

# Check each package in the list
if [ "$debug" -eq 0 ]; then
  download_needed_bins > /dev/null 2>&1
  for package in "${PACKAGES[@]}"; do
    install_package "$package" > /dev/null 2>&1
  done
else
  download_needed_bins
  for package in "${PACKAGES[@]}"; do
    install_package "$package"
  done
fi

echo "Dependency installation and compilation check completed."
