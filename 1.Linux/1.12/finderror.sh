#!/bin/bash
set -euo pipefail

function check {
    grep -Rl "error" /var/log/ > /dev/null
    echo $?
}

RETVAL=$(check)

if [ "$RETVAL" != 0 ]
then
    echo "Файла не существует"
else
    count=$(grep -Rl "error" /var/log/ | wc -l) 
    echo "Найдено $count файлов"
fi

