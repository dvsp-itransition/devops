#!/bin/bash
set -euo pipefail
echo -n "Введите имя каталога: "; read dirname;
if [ -d "$dirname" ] 
then
    echo "Файлы в каталоге $dirname:"
    ls -l "$dirname"
else
    echo "Каталога не существует"
fi