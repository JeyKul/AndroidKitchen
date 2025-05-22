#!/usr/bin/env bash

# MESSAGE #
echo "setting up workspace "

# CREATE WORKSPACE FOLDER TO KEEP ROOT CLEAR #
mkdir -p $WKSPCE

# CREATE FOLDER INSIDE WORKSPACE #
mkdir -p $PRJCT $DWNLD

mkdir -p $LOG

# DOWNLOAD LPUNPACK AND SIMG2IMG #

mkdir -p $WKSPCE/bin

wget -N https://github.com/unix3dgforce/lpunpack/raw/refs/heads/master/lpunpack.py -O $WKSPCE/bin/lpunpack

chmod +x $WKSPCE/bin/lpunpack

PATH=$WKSPCE/bin:$PATH


LATEST_URL=$(curl -s https://api.github.com/repos/JeyKul/android-simg2img/releases/latest | jq -r '.assets[] | select(.name | endswith(".tar.gz")) | .browser_download_url')

wget -q $LATEST_URL -O /tmp/simg_tools.tar.gz && \
mkdir -p $WKSPCE/bin && \
tar -xzf /tmp/simg_tools.tar.gz -C $WKSPCE/bin/

rm /tmp/simg_tools.tar.gz

# Required commands and their explanations
declare -A dependencies=(
    [jq]="jq is a lightweight JSON processor. Required for reading/parsing JSON."
    [python3]="Python 3 is the interpreter needed to run Python scripts."
    [unzip]="unzip is used to extract .zip archives."
    [lz4]="lz4  is used to extract .lz4 archives"
)

missing=0

echo "Checking for required programs..."

# PACKAGAE CHECK #
for cmd in "${!dependencies[@]}"; do
    if ! command -v "$cmd" &>/dev/null; then
        echo -e "\n❌ '$cmd' is NOT installed."
        echo -e "   ➤ Why it's needed: ${dependencies[$cmd]}"
        echo -e "   ➤ Suggested fix (Debian/Ubuntu): sudo apt install $cmd"
        missing=1
    else
        echo "✅ $cmd is installed."
    fi
done

# PYTHON3-VENV CHECK #
echo -e "\nChecking for python3-venv support..."
venv_test_dir=$(mktemp -d)
if ! python3 -m venv "$venv_test_dir" &>/dev/null; then
    echo -e "\n❌ 'python3-venv' is NOT available or not working."
    echo -e "   ➤  Why it's needed: Allows creation of isolated Python environments."
    echo -e "   ➤  Suggested fix: sudo apt install python3-venv"
    missing=1
else
    echo "✅ python3-venv is working."
fi
rm -rf "$venv_test_dir"

# Summary
if [[ $missing -ne 0 ]]; then
    echo -e "\nSome required programs are missing. Please install them and try again."
    exit 1
else
    echo -e "\nAll required programs are installed and functional. ✅"
fi
