## Задача:

**1.6. Написать скрипт, который выводит список файлов в каталоге ~/**

## Решение:

nano listfile.sh

```
#!/bin/bash
set -euo pipefail
ls -l ~/
```

## Результат:

![image](img/result.png)


