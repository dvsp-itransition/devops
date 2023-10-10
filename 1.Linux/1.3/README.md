## Задача:

**1.3. Написать скрипт, который создает новый каталог с именем my_new_dir и переходит в него**

## Решение:

nano newdir.sh

```
#!/bin/bash
set -euo pipefail
dir="my_new_dir"
mkdir -p $dir && cd $dir
```

## Результат:

![image](img/result.png)


