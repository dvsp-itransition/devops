## Задача:

**1.4. Написать скрипт, который копирует файл my_file.txt из каталога ~/ в каталог /tmp**

## Решение:

nano copyfile.sh

```
#!/bin/bash
set -euo pipefail
touch ~/my_file.txt && cp ~/my_file.txt /tmp/
```

## Результат:

![image](img/result.png)


