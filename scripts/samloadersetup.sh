#!/usr/bin/env bash

# MAKE A VENV #
if [ ! -f "$KHOME/venv/bin/activate" ]; then
  echo "Virtual environment not found, creating it..."
  python3 -m venv "$KHOME/venv"
else
  echo "Virtual environment already exists, continuing..."
fi
source $KHOME/venv/bin/activate > /dev/null


pip3 install git+https://github.com/ananjaser1211/samloader.git > /dev/null 2>&1