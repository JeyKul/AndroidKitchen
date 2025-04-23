#!/bin/bash

echo "This will delete everything except 'menu.sh' and 'scripts/'. Continue? (y/n)"
read -r confirm

if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
  for item in * .*; do
    [[ "$item" == "." || "$item" == ".." || "$item" == "menu.sh" || "$item" == "scripts" ]] && continue
    rm -rf "$item"
  done
  echo "Cleanup complete."
else
  echo "Aborted."
fi
