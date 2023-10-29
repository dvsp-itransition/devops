## Практические задания. 

### Часть 1 - Основы AWS

1. Создать выделенную сеть Amazon Virtual Private Cloud с тремя подсетями, как минимум в двух разных зонах (например, обычно обозначаются как us-west-1a,
us-west-1c). Две подсети (расположенные в разных зонах) должны быть публичными. Третья подсеть – приватная, ограничить доступ на ACL.

Создано:

- новый сеть demo-VPC → 10.0.0.0/16
- Internet gateway demo-IG → прикрепил к demo-VPC 

- в us-east-2a (AZ1)
  - demo-pubsub-web-az1 - 10.0.1.0/24, включить auto-assign public IPv4 address
  - demo-privsub-db-az1 - 10.0.2.0/24
    - ограничить доступ на ACL
      - db-ACL →  associate 10.0.2.0/24 network
      - 100 → inbound port=all traffic source=10.0.1.0/24, outbound port=all traffic source=10.0.1.0/24 (публик сеть 1)
      - 101 → outbound port=all traffic source=10.0.3.0/24, outbound port=all traffic source=10.0.3.0/24 (публик сеть 2)
- в us-east-2b (AZ2)
  - demo-pubsub-web-az2 - 10.0.3.0/24, включить auto-assign public IPv4 address

- Route table Public-RT → demo-VPC
- Добавить route по умолчанию в Routes | 0.0.0.0/0 -> IG 
- Ассоциировать/Добавить наш 2 Public Subnets 10.0.1.0/24, 10.0.3.0/24 к Public-RT

![net_map.PNG](img%2Fnet_map.PNG)

В приватной сети ограничить доступ по ACL

![db_NAL.PNG](img%2Fdb_NAL.PNG)

2. Создать Security Group (назовем ее web-sg):
 - Разрешить входящий SSH трафик только со своего IP (или доверенных IPs).
 - Разрешить входящий HTTP/HTTPS трафик со своего IP (или доверенных IPs).
 - Разрешить весь исходящий трафик во все 3 подсети.
 - Остальной трафик запретить.

Создано 

- demo-web-SG security group 
  - allow port=80/443 → source=demo-ELB-Security-Group
  - allow port22 → my IP
  - outbound, allow all → 10.0.1.0/24, 10.0.2.0/24, 10.0.3.0/24 subnets

- demo-ELB-SG (application load balancer SG)
  - allow port=80/443 →  source=0.0.0.0

![demo_web_SG.PNG](img%2Fdemo_web_SG.PNG)

![demo_web_SG_out.PNG](img%2Fdemo_web_SG_out.PNG)

3. Сгенерировать собственный RSA ключ (Key Pairs) для использования в дальнейшем при создании инстансов (необходимо для подключения по SSH)

![key_pairs.PNG](img%2Fkey_pairs.PNG)

4. EC2:
 - a. Создать один t2.micro инстанс в созданной в п 6.1 VPC и одной из публичных подсетей. Использовать Security Group из п 6.1.1.
 - b. Создать второй t2.micro инстанс в созданной в п 6.1 VPC и второй публичной подсети. Использовать Security Group из п 6.1.1.
 - c. На оба инстанса установить Nginx и создать простую страницу-заглушку (index.html) на 80-ом порту.

Создано

- Instance demo-nginx1 , в demo-web-SG, demo-key, в demo-pubsub-web-az1 сети
- user_data
  ```
  #!/bin/bash
  apt update
  apt install nginx -y
  cat > index.html <<EOF
  <html>
  <body>
  <h1>demo-nginx-1</h1>
  </body>
  </html>
  EOF
  rm -rf /var/www/html/*
  cp ./index.html /var/www/html/index.html
  systemctl enable nginx
  systemctl restart nginx
  ```
  
- demo-nginx2 (EC2), demo-web-SG, demo-key, на второй demo-pubsub-web-az2 сети 
- user_data
  ```
  #!/bin/bash
  apt update
  apt install nginx -y
  cat > index.html <<EOF
  <html>
  <body>
  <h1>demo-nginx-2</h1>
  </body>
  </html>
  EOF
  rm -rf /var/www/html/*
  cp ./index.html /var/www/html/index.html
  systemctl enable nginx
  systemctl restart nginx
  ```
![instances.PNG](img%2Finstances.PNG)

5. ELB:
 - a. Создать один ELB с поддержкой созданных Availability Zones.
 - b. Разрешить HTTP трафик на ELB с любого IP адреса.
 - c. Добавить в ELB оба инстанса.
 - d. Настроить Health Check на протокол HTTP, порт 80, страница index.html с минимальными интервалами проверки.
 - e. Обновить security group созданную в пункте 2., так чтобы доступ по http/https был возможен только с ELB.
 - Принудительно остановить веб-сервер на одном из инстансов и проверить доступность сайта.

Создано

- Target Group - demo-TG
  - instance,  select 2 zones, нужно регистрировать targets (2 nginx сервера)
- Application load balancer - demo-ELB как 
  
![elb_sum.PNG](img%2Felb_sum.PNG)

![demo_TG.PNG](img%2Fdemo_TG.PNG)

![demo_elb_link.PNG](img%2Fdemo_elb_link.PNG) 

![demo_nginx.PNG](img%2Fdemo_nginx.PNG)

6. RDS:
 - a. Создать инстанс PostgreSQL в выделенной VPС и приватной подсети с типом хранилища как General Purpose и объёмом в 20 Гб. Использовать Security Group из п 6.1.2.
 - b. Разрешить входящий трафик только от web-sg. Как результат должны продемонстрировать возможность подключения к RDS как минимум с двух иcходных точек (серверов)

Создано

- RDS (Database PostgreSQL)
- demo-DB-SG security group для сервера базы данных 
  - allow port=5432 → source=demo-web-SG
- PostgresSQL15.3, user/pass=postgres, port=5432

![demo_db_SG.PNG](img%2Fdemo_db_SG.PNG)

![psql_db.PNG](img%2Fpsql_db.PNG)

Подключения к RDS с двух наших nginx серверов

![nginx1_psql.PNG](img%2Fnginx1_psql.PNG)

![nginx2_psql.PNG](img%2Fnginx2_psql.PNG)

7. ElastiCache:
 - a. Создать один инстанс ElastiCache (Redis) в выделенной VPC.
 - b. Разрешить трафик только внутри выделенной VPC. Как результат: должны продемонстрировать возможность подключения к Redis как минимум с двух иcходных точек (серверов)
 - c. Создать один инстанс ElastiCache (Memcached) в выделенной VPC.
 - d. Разрешить трафик только от серверов созданных в пункте 5.3. Как результат: должны продемонстрировать возможность подключения к Memcached как минимум с двух иcходных точек (серверов)

Создано 

- Instance Redis
  - demo-redis-SG security group для redis, сеть приватный
  - открыт порт port=icmp -> source=demo-db-SG, demo-web-SG
  - Проверить подключения к Redis с nginx сервера 

![redis.PNG](img%2Fredis.PNG)

![redis_ping.PNG](img%2Fredis_ping.PNG)

![redis_sg.PNG](img%2Fredis_sg.PNG)

- Instance memcached
  - demo-memcached-SG security group, сеть приватный
  - открыт порт port=icmp -> source=demo-web-SG 
  - Проверить подключения к Memcached с nginx сервера

![mem_instance.PNG](img%2Fmem_instance.PNG)

![mem_ping.PNG](img%2Fmem_ping.PNG)

![mem_sg.PNG](img%2Fmem_sg.PNG)


8. Создать CloudFront Distribution с параметрами по умолчанию.
 - a. Сгенерировать 100 небольших файлов ( < 512 Kb) и заполнить ими созданный бакет в S3. К файлам сторонние лица не должны иметь доступ.
 - b. Настроить политику хранения объектов в данном бакете S3 следующим образом:
   - по истечении 30 дней – отправлять объекты в Glacier;
   - после 6 месяцев хранения – полностью удалять с Glacier

Создано

- S3 bucket my-sample-bucket-dvsp (private)
- 100 файлов < 512kb `for i in {1..100}; do fallocate -l 512K filename_$i;done`
- и выгружено в S3   
- 100files > 100 дней → в Glacier ( Glacier Flexible Retrieval - для бэкапов/архивов)
- 100files > 6 месяца → удалить
- cloudfront https://console.aws.amazon.com/cloudfront/v3/home → origin my-sample-bucket-dvsp.s3.us-east-2.amazonaws.com → с параметрами по умолчанию

![s3_backet.PNG](img%2Fs3_backet.PNG)

![s3_lifeSycle.PNG](img%2Fs3_lifeSycle.PNG)

9. *На одном из серверов созданных в пункте 6.3. подготовьте скрипт (с использование aws cli) для загрузки/выгрузки/удаления файлов в S3 бакете созданном в пункте 6.7.1 
в соответствии с best practice и наибольшим уровнем безопасности окружения

Настройка aws cli `apt  install awscli →  aws configure` 

Скрипт для загрузки/выгрузки/удаления файлов в S3 бакете
```
aws s3 ls # shows available S3 backets
aws s3 cp ./files s3://my-sample-bucket-dvsp --recursive # upload files
aws s3 cp s3://my-sample-bucket-dvsp/ ./files/ # download files
aws s3 rm --recursive s3://my-sample-bucket-dvsp/ # deletes all files
aws s3 rm s3://my-sample-bucket-dvsp/filename_99 # deletes single file
```

10. Заменить инстансы (ELB должно будет ссылаться на новые инстансы созданные через autoscaling group) созданные в пункте 6.3 на autoscalinng group, со следующими правилами:
 - Если CPU Utilization > 70%, то добавить инстанс
 - Если CPU Utilization < 15%, то удалить инстанс
 - Минимальное количество запущенных инстансов = 1
 - Максимальное количество запущенных инстансов = 4
 - Autoscaling group должна разворачивать инстанс вместе с установленным nginx и страницей заглушкой из пункта 6.3

Создано 

- launch template (demo-LT)
  - ubuntu20.04, demo-key, t2.micro, demo-web-SG
  - user_data
  ```
  #!/bin/bash
  apt update
  apt install nginx -y
  apt install stress s-tui -y
  cat > index.html <<EOF
  <html>
  <body>
  <h1>demo-nginx-ASG</h1>
  </body>
  </html>
  EOF
  rm -rf /var/www/html/*
  cp ./index.html /var/www/html/index.html
  systemctl enable nginx
  systemctl restart nginx
  ```
  
![demo-LT.PNG](img%2Fdemo-LT.PNG) 
  
- AutoScalingGroup
  - Выбрать demo-LT launch template, demo-VPC, 2 AZ subnets,
  - demo-ELB Load balancer, demo-TG Target group
  - health check -> ELB
  - capacity min=1, desired=2, max=4
  - scaling policy 
    - CPU > 70% = добавить инстанс, CPU < 15% удалить инстанс

![instances_ASG.PNG](img%2Finstances_ASG.PNG)

![instances_ids.PNG](img%2Finstances_ids.PNG)

![instances_TG.PNG](img%2Finstances_TG.PNG)

![Auto_Scale.PNG](img%2FAuto_Scale.PNG)

Проверка работы auto scaling, делаем стресс тест на процессор `stress --cpu 1 --timeout 60s`

![test_cpu.PNG](img%2Ftest_cpu.PNG)

![tetst_cpu_in.PNG](img%2Ftetst_cpu_in.PNG)

![web_ASG.PNG](img%2Fweb_ASG.PNG)


