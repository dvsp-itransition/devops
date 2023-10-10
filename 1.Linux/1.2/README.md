## Задача:

**1.2. Написать скрипт, который выводит текущую дату и время в формате: 2023-07-20 12:00:00**

## Решение:

nano /tmp/data.sh

```
#!/bin/bash
set -euo pipefail
DATE=$(date +"%Y-%m-%d %H:%M:%S")
echo $DATE
```

## Результат:

![image](img/result.png)


