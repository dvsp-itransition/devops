### Задача: 1.13. * Вам нужно разработать Bash-скрипт для создания менеджера свободного места на диске, который будет следить за использованием дискового пространства на вашем компьютере и предоставлять информацию о статистике использования свободного места. Скрипт должен включать следующие функциональности:

- Отображение текущей статистики: Скрипт должен выводить информацию о текущем использовании свободного места на всех монтируемых дисках.
- Предупреждения о нехватке места: Если свободное место на каком-либо диске опускается ниже заданного порога, скрипт должен отправлять предупреждение, например, по электронной почте или в лог-файл. 
- Очистка устаревших файлов: Скрипт должен предоставлять опцию для автоматической очистки устаревших или временных файлов на выбранном диске, чтобы освободить дополнительное место.
- Логирование: Скрипт должен вести лог, в котором записываются события, связанные с управлением свободным местом, включая предупреждения и операции по очистке.
- Использование функций и циклов: Скрипт должен быть разбит на функции для выполнения различных задач и использовать циклы для обхода дисков и анализа статистики.
- Обработчик case для аргументов: Используйте оператор case для обработки аргументов командной строки и выполнения соответствующих действий

nano diskspace.sh

```
#!/bin/bash
alertval="85"
normalval="50"

# shows the space of mounted disks to monitor
df -h | grep -vE 'tmpfs|cdrom|/dev/loop*' | awk '{ print $1 " - " $2 " - " $4 }' | tee -a log-`date +%F`

# Get list of disks to monitor
devnames=$(df -H | grep -vE '^Filesystem|tmpfs|cdrom|/dev/loop*' | awk '{ print $1 }')

check_disk_space_state (){
  p=$(df -k $1 | grep -v ^File | awk '{print $5}' | cut -d "%" -f 1)
  
  if [ "$p" -ge "$alertval" ]; then
    val=1
    space=$p    
  elif [ "$p" -gt "$normalval" ] && [ "$p" -lt "$alertval" ]; then
    val=2
    space=$p    
  else [ "$p" -lt "$normalval" ]
    val=3
    space=$p    
  fi 
}

for devname in $devnames; do
    check_disk_space_state $devname
    case $val in
    1 )
        echo "Disk $devname is in critical state. $space% of space in use" | tee -a log-`date +%F` 
        echo "Here are the list of temp files older than 30 days to be cleaned" | tee -a log-`date +%F` 
        find /tmp -type f -mtime +30 | tee -a log-`date +%F`
        find /var/tmp -type f -mtime +30 | tee -a log-`date +%F`     
        ;;
    2 )
         echo "Disk $devname is in warning state. $space% of space in use. Think about to free some space" | tee -a log-`date +%F`  
        ;;
    3 )
         echo "Disk $devname is ok. $space% of space in use" | tee -a log-`date +%F` 
        ;;
    esac
done
```

![disks.PNG](img%2Fdisks.PNG)

Запускает скрипт каждый день в 10pm
```
crontab -e 
0 22 * * * /root/bash/diskcheck.sh
```

![result.png](img%2Fresult.png)
