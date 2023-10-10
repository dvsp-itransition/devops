## Задача:

**Написать скрипт, который запрашивает у пользователя имя каталога и выводит список файлов в нем. Если каталог не существует, вывести сообщение об ошибке**

## Решение:

nano direxists.sh

```
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
```

## Результат:

![image](img/result.png)



