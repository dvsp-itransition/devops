# Задача

> 1. Установить Jenkins или Teamcit y server. Это может быть установка на ваш локальный компьютер или на инстансе в облаке, это не имеет значение, как не имеет значение и метод уставки (с использованием docker контейнера, playbook
   или установка вручную из репзитория и пр.).
> 2. Создать новый проект “Staging”, в нем добавить задачу для сборки простого приложения, например
>    - a. .net: https://github.com/chaitalidey6/HelloWorldAspNetCore/tree/master/HelloWorldAspNetCore
>    - b. Java: https://github.com/jenkins-docs/simple-java-maven-app
>    - c. Node JS: https://github.com/jenkins-docs/simple-node-js-react-npm-app
>    - Замечания:
>    - Вы можете использовать любое привычное приложение на любом языке - (.net, java, js, python, php).
>    - Код приложения должен быть размещен в вашем собственном git-репозитории.
>    - Должна использоваться ветка “staging”.
>    - Приложение может быть собрано в контейнере (предпочтительный способ).
>    - Задача по сборке должна запускаться с параметрами.
>    - Результатом сборки обязательно должен быть артифакт (архив, docker-контейнер), который вы дальше будете использовать.
>    - Необходимо самостоятельно подумать над тем, каким образом Jenkins/TeamCity получит доступ к git-репозиторию, при этом необходимо придумать наиболее безопасный на ваш вгляд способ.
> 3. Создать задачу в Jenkins /Teamcity для деплоя вашего артифакта на сервер и перезапуск приложения. 
>    - Замечания:
>    - Здесь артефакт может доставляться на удаленный сервер (например, на EC2 инстанс в AWS), либо на контейнер (при работе локально в Docker), либо на локальный сервер (при работе с Vagrant/VirtualBox).
>    - Необходимо самостоятельно подумать над тем, каким образом будет организован доступ из Jenkins/Teamcity на сервер (дря загрузки артефактов), при этом необходимо придумать наиболее безопасный на ваш вгляд способ.
> 4. Настроить зависимость задачи деплоя от задачи сборки.
> 5. Настроить деплой артефакта вместо, где он будет работать и запуск приложения.
> 6. Добавить задачу создания бэкапа артефактов на сервере.
> 7. Настроить пайплайн, где должны быть включены шаги: сборка, бэкап и деплой (опционально: тестирование). 
> 8. Настроить автоматический запуск деплоя при добавлении нового commit’а в ветке “staging” git.
>    - При запуске локально – здесь могут быть проблемы с настройкой webhook, потому используйте другой метод взаимодействия с git.
> 9. Создать новый проект “Production”, добавить задачу для сборки приложения, выполнить те же настройки, что и в Staging (п. 2), но с небольшими изменениями: должна использоваться ветка “master”.
> 10. Создать задачу для деплоя Production артефактов на сервер (здесь может использоваться тот же сервер, но приложения должны быть различными: «висеть» на разных портах или под разными доменами).
> 11. Настроить зависимость задачи деплоя от задачи сборки.
> 12. Настроить автоматический запуск деплоя при подтверждении pull request’а в ветке “master” в git. 

# Решение

### Структура

![structure.PNG](img%2Fstructure.PNG)

Для задачи подготовил 2 сервера:

- vm1 (jenkins master)
- vm2 (jenkins node)

Установил jenkins и nginx proxy сервер как контейнеры, создал проекты staging и production в Jenkins, задача запускается с параметрами, код приложение находится в гите: https://github.com/dvsp-itransition/boxfuse-sample-java-war-hello.git. 
Настроил webhooks, приложение собирается автоматический по гит коммит/push и запускается как контейнер на второй машине (jenkins node),  
использовал Amazon ECR для хранения образов. В Jenkins настроил доступ к гиту, VM2 и AWS ECR.

Установка и настройка docker и docker compose 

nano jenkins-pre-install.sh
```
#!/bin/bash
set -euo pipefail
sudo apt update && sudo apt -y install docker.io

# install docker-compose
sudo curl -SL https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-linux-x86_64 -o /usr/bin/docker-compose
sudo chmod 777 /usr/bin/docker-compose
sudo systemctl enable docker
sudo systemctl start docker
sudo systemctl status docker

# configure 
sudo usermod -aG docker $USER
chmod 777 /var/run/docker.sock
```
Создаем docker compose файл для установки jenkins и nginx proxy сервера как контейнеры

nano docker-compose.yml
```
version: '3.8'
services:
  jenkins: 
    image: jenkins/jenkins:lts
    container_name: jenkins
    privileged: true
    user: root
    volumes:
    - jenkins_home:/var/jenkins_home
    - /var/run/docker.sock:/var/run/docker.sock
    expose:
    - 8080
    - 50000

  nginx:
    image: nginx
    container_name: nginx
    ports:
      - 4000
    volumes:
    - ./nginx/nginx_conf:/etc/nginx/nginx.conf:ro
    depends_on:
    - jenkins

volumes:
    jenkins_home:
```

Настраиваем nginx как proxy для jenkins
```
nano nginx.conf
http {  
    server{
        listen *:4000;        
            
        location / {
            proxy_pass http://jenkins:8080;
        }    
    }
}
events {}  
```

Запускаем jekins и nginx как контейнер 
```
docker-compose -d up
docker ps
```
![1.compose-up.PNG](img%2F1.compose-up.PNG)

![2.jenkins-up.PNG](img%2F2.jenkins-up.PNG)

Далее, устанавливаем плагинов по умолчанию и обновляем пароли

![3.jenkins_pass.PNG](img%2F3.jenkins_pass.PNG)

![4.jenkins-up.PNG](img%2F4.jenkins-up.PNG)

Делаем дальнейшие настройки. 

Открываем Jenkins root page > Manage Jenkins > Manage Plugins -> устанавливаем необходимых плагинов для работы

- docker Pipeline, docker (allows building, testing, and using Docker images from Jenkins Pipeline projects, runs docker containers as jenkins nodes)
- Amazon ECR Plugin (allows to work with ECR)

Добавляем Maven tool для зборки проектов на java: Dashboard > Manage Jenkins > Global Tools Configuration. Click on Add Maven ...

![maven.PNG](img%2Fmaven.PNG)

Добавляем следующие credentials:
- node для соединение с jenkins node 
- github_access для соединение с github 
- awscred для отправки docker образов в AWS ECR

![creds.PNG](img%2Fcreds.PNG) 

Добавляем jenkins нода : Jenkins dashboard -> Manage Jenkins -> Manage Nodes

![node1.PNG](img%2Fnode1.PNG)

![node2.PNG](img%2Fnode2.PNG)

Создаем приватный репозиторий в AMAZON ECR для хранения копий наших докер образов: 
Amazon ECR -> Repositories -> create repository

![5.aws-repo.PNG](img%2F5.aws-repo.PNG)

Настраиваем Jenkins нода

nano node.sh
```
#! /bin/bash
sudo apt update 
sudo apt install default-jdk  maven docker.io -y
sudo systemctl enable docker
sudo systemctl start docker
sudo systemctl status docker

# Installs Trivy to scan docker images
wget https://github.com/aquasecurity/trivy/releases/download/v0.41.0/trivy_0.41.0_Linux-64bit.deb
sudo dpkg -i trivy_0.41.0_Linux-64bit.deb
```

## Проект "STAGING"

Создаем Jenkinsfile

nano Jenkinsfile

```
def registry = '753743851231.dkr.ecr.us-east-2.amazonaws.com'
def reponame = 'dvsp-javappimage'

pipeline {
    agent {
        node {
            label 'node'
        }
    }
    tools {
        maven 'maven3'
    }

    parameters { string(name: 'DEPLOY_TO', defaultValue: 'staging', description: '') }

    stages {
        stage('Building warfile') { 
            steps {
                sh 'mvn -B -DskipTests clean package' 
            }
        }

        stage('Unit Tests') { 
            steps {
                sh 'mvn test' 
            }
        }

        stage('Build Image') {
            steps {
                script{
                    image = reponame + ":" + env.BUILD_ID // prepares tag name for the image
                    javapp = docker.build(image)                 
                }                
            }
        }
       
        stage('Scan Image'){
            steps{                
                sh "trivy image ${reponame}:${env.BUILD_ID}"
            }
        }

        stage('Push Image') {
            steps {
                script{
                    docker.withRegistry('https://' + registry, 'ecr:us-east-2:awscred') {                                             
                        javapp.push()                          
                    }                                    
                }                
            }
            post {
                always {
                    sh "docker rmi ${reponame}:${env.BUILD_ID}"
                }           
            }
        }

        stage('Deploy Image') {            
            steps {
                script{

                    if (params.DEPLOY_TO  == 'staging') {

                            docker.withRegistry('https://' + registry, 'ecr:us-east-2:awscred') { 
                            javapp.pull()  
                            sh 'docker rm -f javapp-staging || true'                      
                            sh "docker run --name javapp-staging -p 7000:8080 -d ${registry}/${reponame}:${env.BUILD_ID}"                                          
                        
                        }                              
                    } 

                    if (params.DEPLOY_TO  == 'production') {

                            docker.withRegistry('https://' + registry, 'ecr:us-east-2:awscred') { 
                            javapp.pull()  
                            sh 'docker rm -f javapp-production || true'                      
                            sh "docker run --name javapp-production -p 8000:8080 -d ${registry}/${reponame}:${env.BUILD_ID}"                                          
                        
                        }                              
                    }                       
                }                
            }
        }
    }  
}
```

nano Dockerfile
```
FROM tomcat:8-alpine
ADD ./target/hello-1.0.war /usr/local/tomcat/webapps/hello-1.0.war
```

### Код приложение, файлы Dockrfile и Jenkinfile выложил в гит и находиться в ветке staging: 
https://github.com/dvsp-itransition/boxfuse-sample-java-war-hello.git

![staging_pipeline.PNG](img%2Fstaging_pipeline.PNG)

Добавим новую ветку - master

```
git branch master
git checkout master
git add .
git commit -m "added master files"
git push -u origin master
```

## Проект "Production"

### Код приложение, файлы Dockrfile и Jenkinfile выложил в гит и находиться в ветке master: 
https://github.com/dvsp-itransition/boxfuse-sample-java-war-hello-prod.git

![prod_pipeline.PNG](img%2Fprod_pipeline.PNG)

### Запускаем staging и production пайплайны

# Результаты:

### Stage и Production контейнеры запушены в разных портах

![containers.PNG](img%2Fcontainers.PNG) 

### Контейнер stage доступен по порту: 7000

![stage_con.PNG](img%2Fstage_con.PNG)

### Контейнер production доступен по порту: 8000

![prode_con.PNG](img%2Fprode_con.PNG)

![all_jobs.PNG](img%2Fall_jobs.PNG) 

![prod_result.PNG](img%2Fprod_result.PNG)

![stage_result.PNG](img%2Fstage_result.PNG)

![jenkins_output1.PNG](img%2Fjenkins_output1.PNG)

![jenkins_output2.PNG](img%2Fjenkins_output2.PNG)

![jenkins_output3.PNG](img%2Fjenkins_output3.PNG)

![jenkins_output4.PNG](img%2Fjenkins_output4.PNG)

![images_in_ECR.PNG](img%2Fimages_in_ECR.PNG)






















