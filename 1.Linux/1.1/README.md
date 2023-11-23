## Задача:

**1.1. Написать скрипт определяющий запущен ли скрипт от имени пользователя root**

## Решение:

nano /tmp/ifroot.sh

```
#!/bin/bash
set -euo pipefail
if [ "$USER"  == "root" ]; then
    echo "This script is run on behalf of $USER user";
else
    echo "This is NOT root user.";
fi    
```

set -euxo pipefail.
With these settings in bash scripts, certain common errors will cause the script to immediately fail, explicitly and loudly. Otherwise, you can get hidden bugs that are discovered only when they blow up in production.

- e - Imadiately stops execution of bash script if any command has not-zero exit status
- u - Affects variables. if a variable is not defined, the script fails explicitly and immediately in the line with an exit code of 1
- x - prints all the command that exucuted, can be usefull for debugging
- o pipefail - This setting prevents errors in a pipeline from being masked. If any command in a pipeline fails, that return code will be used as the return code of the whole pipeline. By default, the pipeline's return code is that of the last command even if it succeeds.

## Результат:

![image](img/result.png)

