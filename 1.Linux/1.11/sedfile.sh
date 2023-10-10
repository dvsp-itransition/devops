#!/bin/bash
set -euo pipefail
echo -n "Введите имя файла: "; read -r FILENAME; 
if [ -f "$FILENAME" ]
then
    sed 's/error/warning/g' "$FILENAME"
else
    echo "Файла не существует"
fi



