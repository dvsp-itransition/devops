### Практическое задание
4.1 Создать 3 репозитория в github или bitbucket с названием ab-haproxy, ab-logstash, ab-webui (все дальнейшие действия подразумевают выгрузку результатов в эти
репозитории). 

Важно: в решении необходимо использовать playbooks, а не ссылаться на репозиторий Galaxy.

4.2 Создать виртуальную машину Ubuntu 18.04

### 4.3 ab-haproxy
4.3.1 Создать следующие роли в Ansible: 
  - apt (добавление необходимых пакетов, обновление из репозиториев установленных по умолчанию пакетов)
  - ntp (обновить время, настроить синхронизацию времени по cron 1 раз в сутки с любого общедоступного сервера времени)
  - monit (установить и настроить monit для само-мониторинга виртуальной машины, правила можно составить любые, например: перезапуск haproxy)
  - haproxy (можно адаптировать роли из https://galaxy.ansible.com/incubateurpe/haproxy, haproxy будет использоваться в качестве балансировщика для веб-иинтерфейса
4.5.)
  - На выходе Ansible так же должен быть сформирован ini-файл, содержащий любой уникальный ID виртуалки, например Packer ID, следующего формата: 
`
[general]
uniqueID=
`
### 4.4 ab-logstash
4.4.1 Создать следующие роли в Ansible (можно пользоваться репозиторием Galaxy):
  - apt (добавление необходимых пакетов, обновление из репозиториев установленных по умолчанию пакетов)
  - ntp (обновить время, настроить синхронизацию времени по cron 1 раз в сутки с любого общедоступного сервера времени)
  - monit (установить и настроить monit для само-мониторинга виртуальной машины)
  - java (https://galaxy.ansible.com/andrewrothstein/openjdk для установки openjdk-8-jdk)
  - logstash (https://www.elastic.co/downloads/logstash без локального syslog и web интерфейса)
  - elasticsearch (https://www.elastic.co/downloads/elasticsearch)
  - На выходе Ansible также должен быть сформирован ini-файл, содержащий любой уникальный ID виртуалки, например Packer ID

### 4.5 ab-webui
4.5.1 Создать следующие роли в Ansible (можно пользоваться репозиторием Galaxy):
- apt (добавление необходимых пакетов, обновление из репозиториев установленных по умолчанию пакетов)
- ntp (обнвоить время, настроить синхронизацию времени по cron 1 раз в сутки с любого общедоступного сервера времени)
- monit (установить и настроить monit для само-мониторинга виртуальной машины)
- rsyslog (для трансляции любых стандартных системных логов)
- kibana
- nginx (настроить reverse proxy на kibana)
- На выходе Ansible так же должен быть сформирован ini-файл, содержащий любой уникальный ID виртуалки

### 4.6 Настроить конфигурации следующим образом:
- logstash должен собирать логи с rsyslog на ВМ WebUI
- kibana должен предоставлять интерфейс для просмотра логов из logstash
- доступ к kibana должен быть возможен через ВМ haproxy

## Решение

### Структура

![structure.PNG](img%2Fstructure.PNG)

Для выполнения задачи подготовил 4 сервера:

- Сервер 1: ansible мастер
- Сервер 2: logstash, на нем будет установлен logstash и elastic search
- Сервер 3: webui, будет установлен kibana и nginx 
- Сервер 4: haproxy 

Создал следующие ансибл роли которые поможет автоматизировать установку и настройку haproxy, webui (nginx,kibana,rsyslog) и logstash (elastic,logstash) на трех серверах
- Logstash  -> https://github.com/dvsp-itransition/ab-logstash.git 
- webui     -> https://github.com/dvsp-itransition/ab-webui.git
- haproxy   -> https://github.com/dvsp-itransition/ab-haproxy.git

На мастер сервере устанавливаем ansible
```
sudo apt update && sudo apt install ansible -y
```

Настроил связь между ansible мастером и с тремя удаленными серверами через ssh.
```
ssh-keygen
cat ~/.ssh/id_rsa.pub >> ubuntu@IP:/home/ubuntu/.ssh/authorized_keys

```

Проверка связи 
```
ssh ubuntu@IP
ansible haproxy -i hosts -m ping
ansible all -m ping
```

![check_connection.PNG](img%2Fcheck_connection.PNG)

### Запускаем Logstash роль

![ai1.PNG](img%2Fai1.PNG)
![ai2.PNG](img%2Fai2.PNG)

![es.PNG](img%2Fes.PNG)

![ls.PNG](img%2Fls.PNG)

![monit_ls.PNG](img%2Fmonit_ls.PNG)

![ls_crontab.PNG](img%2Fls_crontab.PNG)

Monit настроил на перезапуск ElasticSearch
![es_monit.PNG](img%2Fes_monit.PNG)

Сформирован уникальный ID системы
![ls_ini.PNG](img%2Fls_ini.PNG) 

Проверки работы службы Elasticsearch

```
curl -X GET "localhost:9200" 
```
 
Проверки конфигураций logstash
```
/usr/share/logstash/bin/logstash -f /etc/logstash/conf.d/logstash.conf --verbose # stop the service with sudo service logstash stop and run it
/usr/share/logstash/bin/logstash --path.settings /etc/logstash -t # displays "Configuration OK" if config OK
```

### Теперь, запускаем Webui роль

![wbu1.PNG](img%2Fwbu1.PNG)
![wbu2.PNG](img%2Fwbu2.PNG)

![kib.PNG](img%2Fkib.PNG)

![nginx.PNG](img%2Fnginx.PNG)

Monit настроил на перезапуск nginx
![webui_monit.PNG](img%2Fwebui_monit.PNG)

Логи авторизаций будет отправлены в logstash
![webui_rsyslog.PNG](img%2Fwebui_rsyslog.PNG)

Сформирован уникальный ID системы
![webui_ini.PNG](img%2Fwebui_ini.PNG)


## Запускаем Haproxy роль

![ha1.PNG](img%2Fha1.PNG)
![ha2.PNG](img%2Fha2.PNG)

![ha_status.PNG](img%2Fha_status.PNG)

Monit настроил на перезапуск haproxy
![ha_monit.PNG](img%2Fha_monit.PNG) 

Сформирован уникальный ID системы
![ha_ini.PNG](img%2Fha_ini.PNG)

Проверит конфигурационный файл haproxy

```
haproxy -f /etc/haproxy/haproxy.cfg -c 
```

![ha_ip.PNG](img%2Fha_ip.PNG)

# Результаты:


![el1.PNG](img%2Fel1.PNG)

![ha_stat.PNG](img%2Fha_stat.PNG)

### Теперь, через ssh с сервера мастера будем соединяться к webui, посмотрим появиться ли логи в нашей ELK системе

![ls4.PNG](img%2Fls4.PNG)

### Видим что дата и время сообщений, ип адреса совпадает, логи авторизаций успешно отправлены в logstash и появилось в нашей системе

![el5.PNG](img%2Fel5.PNG)

### Наш ELK стэк успешно установлено и настроено с помощью ansible 






