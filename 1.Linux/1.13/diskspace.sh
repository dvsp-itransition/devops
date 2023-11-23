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
        find /tmp -type f -ctime +30 | tee -a log-`date +%F`
        find /var/tmp -type f -ctime +30 | tee -a log-`date +%F`     
        ;;
    2 )
         echo "Disk $devname is in warning state. $space% of space in use. Think about to free some space" | tee -a log-`date +%F`  
        ;;
    3 )
         echo "Disk $devname is ok. $space% of space in use" | tee -a log-`date +%F` 
        ;;
    esac
done


