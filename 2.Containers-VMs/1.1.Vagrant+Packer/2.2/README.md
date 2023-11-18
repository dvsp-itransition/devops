## Задача 2.2: Создание многокомпонентного окружения с использованием Vagrant и VirtualBox

После успешного овладения основами Vagrant и VirtualBox, вашей задачей будет создать
многокомпонентное виртуальное окружение для тестирования и разработки. Это
окружение будет включать в себя несколько виртуальных машин с разными
конфигурациями.

Инициализация проекта: Создайте новую директорию для вашего многокомпонентного
окружения. В этой директории выполните команду vagrant init, чтобы создать файл
Vagrantfile.

![v_init.PNG](img%2Fv_init.PNG)

Создание нескольких виртуальных машин: В файле Vagrantfile определите несколько
виртуальных машин с разными характеристиками (разное количество CPU, объем
оперативной памяти и др.). Каждая из них должна использовать базовый образ вашей
операционной системы по выбору.

Конфигурация сети: Настройте сеть так, чтобы ваши виртуальные машины могли
взаимодействовать друг с другом внутри виртуальной сети, а также имели доступ к
интернету через NAT.

nano Vagrantfile

```
Vagrant.configure("2") do |config|
  
  config.vm.define "web" do |web|    
    web.vm.box = "ubuntu/focal64"   
    web.vm.hostname = "web" 
    web.vm.network "private_network", ip: "192.168.100.100"
    web.vm.provision "install", type: "shell", path: "web.sh"

    web.vm.provider "virtualbox" do |vb|    
      vb.name = "web" # vm name on virtual box list    
      vb.memory = "1024" 
      vb.cpus = 1
    end
  end

  config.vm.define "db" do |db|
    db.vm.box = "ubuntu/focal64" 
    db.vm.hostname = "db" 
    db.vm.network "private_network", ip: "192.168.100.200"
    db.vm.provision "install", type: "shell", path: "db.sh"

    db.vm.provider "virtualbox" do |vb|    
      vb.name = "db"    
      vb.memory = "2048" 
      vb.cpus = 2
    end
  end
end
```

Скрипты установки: Создайте скрипты установки (Bash-скрипты) для каждой
виртуальной машины, которые будут выполняться при их создании. Скрипты должны
устанавливать и настраивать необходимое программное обеспечение или компоненты.

nano web.sh
```
#!/bin/bash
sudo apt update
sudo apt install nginx -y
sudo mkdir /opt/devops
```

nano db.sh
```
#!/bin/bash
sudo apt update
sudo apt install mysql-server -y
sudo mkdir /opt/devops
```
Запуск и настройка: Запустите все виртуальные машины с помощью команды vagrant up.
Убедитесь, что они корректно настроены и могут взаимодействовать друг с другом

```
vagrant up
vagrant status
Vagrant global-status
```
![v_status.PNG](img%2Fv_status.PNG)

![vm_web.PNG](img%2Fvm_web.PNG)

![vm_db.PNG](img%2Fvm_db.PNG)

Взаимодействие и тестирование: Войдите в каждую виртуальную машину через SSH с
помощью vagrant ssh и проверьте их работоспособность. Попробуйте взаимодействовать
между машинами, например, пинговать друг друга.

![s_web.PNG](img%2Fs_web.PNG)

![s_db.PNG](img%2Fs_db.PNG)

Логирование и документация: Ведите лог своих действий и подготовьте документацию,
описывающую создание и настройку каждой виртуальной машины. Укажите, какие
проблемы возникли, и как вы их решали.

Отчет: Подготовьте подробный отчет о создании многокомпонентного окружения. В
отчете укажите все действия, которые вы выполнили, и описания результатов. Также
предоставьте документацию и логи

```
vagrant init
vagrant up 
vagrant ssh web
vagrant ssh db
Vagrant status # Shows status of current box from within it’s containing folder
Vagrant global-status  # Shows status of ALL boxes
Vagrant reload 
vagrant stop web
vagrant stop db
vagrant halt
vagrant destroy --force
```