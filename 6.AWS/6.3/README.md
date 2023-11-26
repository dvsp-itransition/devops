
## Практические задания 

### Часть 3 — Работа с контейнерами

1. Создать в AWS два бесплатных инстанса – t2.micro c Ubuntu.

![instances.PNG](img%2Finstances.PNG)

2. Организовать доступ к ним через белый список IP (security group, SSH)


![jenkins_sg.PNG](img%2Fjenkins_sg.PNG)

3. Установить Jenkins на один из инстансов, не забыв открыть порт 8080 (по умолчанию) для своего IP.

nano jenkins.sh
```
# 1. installs java, jenkins needs java to run
sudo apt update
sudo apt install fontconfig openjdk-17-jre -y
java -version

# 2. installs jenkins
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key 
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null 
sudo apt-get update 
sudo apt-get install jenkins docker.io -y

sudo systemctl enable jenkins
sudo systemctl start jenkins


# sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

Устанавливаем и делаем настройку Jenkins, устанавливаем плагины по умолчанию

![jenkns_installed.PNG](img%2Fjenkns_installed.PNG)

4. Между инстансами установить SSH соединение. Для этого необходимо добавить public key пользователя Jenkins (Jenkins instance) в доверенные ключи пользователя ubuntu (Staging instance).

```
ssh-keygen
cat ~/.ssh/id_rsa.pub >> ubuntu@IP:/home/ubuntu/.ssh/authorized_keys
ssh ubuntu@IP # check connection
```

5. Установить Docker на Staging instance. Добавить пользователя ubuntu в группу Docker (sudo usermod -aG docker ubuntu)

nano docker.sh
```
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# Install the Docker packages.
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

sudo usermod -aG docker ubuntu
```

![docker_status.PNG](img%2Fdocker_status.PNG)

6. Запустить docker run hello-world в Staging instance.

![hello_world.PNG](img%2Fhello_world.PNG)

7. Создать репозиторий в GitHub. Положить в него Jenkinsfile.

- создано git repo -> https://github.com/dvsp-itransition/aws-jenkins-container.git
- Добавим публичную часть ssh ключа пользователя jenkins в GitHub: settings -> ssh and GPG keys -> new shh key -> input your ssh public key
- переходим к пользователю Jenkins и запускаем команду: `su - jenkins && git ls-remote -h -- git@github.com:dvsp-itransition/aws-jenkins-container.git HEAD`
- в jenkins используем SSH URL: `git@github.com:dvsp-itransition/aws-jenkins-container.git` 

8. В Jenkinsfile указать stages со скриптом проброса туннеля docker socket (https://medium.com/@dperny/forwarding-the-docker-socket-over-ssh-e6567cfab160) 
   для управления контейнерами в Staging

Примечания: Команда sleep 5, как видно из комментария, нужна для задержки следующего шага на 5 секунд, т.к. открытие туннеля происходит не моментально и может занять
некоторое время. Шаг post необходим для удаления туннеля.


9. Создать в Jenkins New Item –> docker-pipeline. В разделе Pipeline->SCM выбираем Git, вводим адрес репозитория (как в clone). Заодно увидим ошибку Failed to connect to repository, значит нужно положить
содержимое публичного ключа Jenkins instance в ssh ключи Github. Если всё произведено корректно, то ошибка пропадёт.

![jenkins_git.PNG](img%2Fjenkins_git.PNG)

### Обновить приватный IP машины staging в Jenkinsfile

![i_ip_staging.PNG](img%2Fi_ip_staging.PNG)

10. В разделе Script Path вводим путь к Jenkinsfile. Сохраняем настройки.
11. Нажимаем Build Now - должна запуститься задача. Заходим в задачу, а затем в Console output. 
Если всё прошло хорошо, то в логах мы должны увидеть результат выполнения команды docker ps -a на Staging instance.

## Результаты:

![pipeline1.PNG](img%2Fpipeline1.PNG)

![pipeline2.PNG](img%2Fpipeline2.PNG)

Staging сервер

![staging_vm.PNG](img%2Fstaging_vm.PNG)









