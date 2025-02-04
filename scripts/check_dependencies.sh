#!/bin/bash

if ! grep -q "erofs" /proc/filesystems; then
  echo "Error: EROFS support not found. Aborting."
  exit 1
#elif ! grep -q "f2fs" /proc/filesystems; then
#  echo "Error: F2FS support not found. Aborting."
#  exit 1
fi

KITCHEN_HOME=$(pwd)

mkdir $KITCHEN_HOME/ext
BINARYPATH="$KITCHEN_HOME/ext/bin"
mkdir -p "$BINARYPATH"

echo $KITCHEN_HOME what
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
    sudo apt update
    sudo apt install -y "$package" || { echo "Failed to install $package. Attempting to compile from source..."; compile_package "$package"; }
  fi
}
download_needed_bins(){
  wget -nc https://github.com/AndroidDumps/Firmware_extractor/raw/refs/heads/master/tools/lpunpack -P $BINARYPATH
  chmod +x $BINARYPATH/lpunpack

  SIMG2IMGPATH=$KITCHEN_HOME/ext/simg2img
  git clone https://github.com/anestisb/android-simg2img $SIMG2IMGPATH
  cd $SIMG2IMGPATH
  make
  cp *2*img $BINARYPATH 
  cd $KITCHEN_HOME
}
# Function to compile a package from source
compile_package() {
  local package="$1"
  case "$package" in
    libbrotli-dev)

      LIBBROTLIPATH="$KITCHEN_HOME/ext/libbrotli"

      git clone https://github.com/google/brotli "$LIBBROTLIPATH"

      cd "$LIBBROTLIPATH"
      mkdir -p out
      cd out

      cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=./installed ..
      cmake --build . --config Release

      cp "$LIBBROTLIPATH/out/"*brotli* "$BINARYPATH"

      ;;
    liblz4-dev)

      LIBLZ4PATH="$KITCHEN_HOME/ext/liblz4"

      git clone https://github.com/lz4/lz4.git "$LIBLZ4PATH"

      cd "$LIBLZ4PATH"
      mkdir -p build
      cd build

      cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=./installed ..
      make -j$(nproc)
      cp "$LIBLZ4PATH/build/installed/bin/lz4" "$BINARYPATH"

      ;;
    libzstd-dev)
      LIBZSTD_PATH="$KITCHEN_HOME/ext/libzstd"

      git clone https://github.com/facebook/zstd.git "$LIBZSTD_PATH"
      cd "$LIBZSTD_PATH"
      make clean
      make -j$(nproc)
      cp "$LIBZSTD_PATH/programs/zstd" "$BINARYPATH"
      ;;
    openjdk-17-jdk)
    OPENJDKPATH="$KITCHEN_HOME/ext/java"
    JAVAFILENAME="openjdk-23.0.1_linux-x64_bin.tar.gz"
      wget https://download.java.net/java/GA/jdk23.0.1/c28985cbf10d4e648e4004050f8781aa/11/GPL/openjdk-23.0.1_linux-x64_bin.tar.gz -P $OPENJDKPATH
      mkdir $OPENJDKPATH/unpack
      tar -xvzf $JAVAFILENAME -C $OPENJDKPATH/unpack
      cp $OPENJDKPATH/unpack/jdk-23.0.1 $BINARYPATH/jdk-23.0.1
      ln -s $BINARYPATH/java $BINARYPATH/jdk-23.0.1/bin/java
      ;;
  esac
}

# Check each package in the list
download_needed_bins
for package in "${PACKAGES[@]}"; do
  install_package "$package"
done

echo "Dependency installation and compilation check completed."