#!/bin/bash
set -euo pipefail
echo -n "Введите имя файла: "; read -r FILENAME; 
if [ -f "$FILENAME" ]
then
    echo "Содержимое файла $FILENAME: "
    cat "$FILENAME"
else
    echo "Файла не существует"
fi


