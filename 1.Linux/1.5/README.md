## Задача:

**1.5. Написать скрипт, который удаляет файл my_file.txt из каталога ~/**

## Решение:

nano delfile.sh

```
#!/bin/bash
set -euo pipefail
rm -f ~/my_file.txt
```

## Результат:

![image](img/result.png)


