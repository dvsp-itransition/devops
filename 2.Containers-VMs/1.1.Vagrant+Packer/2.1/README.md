### Задача 2.1: Управление виртуальной машиной с использованием Vagrant

Вы учитеся администрированию и хотите научиться создавать и управлять
виртуальными машинами с помощью инструментов виртуализации. Для начала, вам
нужно научиться использовать Vagrant и VirtualBox для создания и управления
виртуальной машиной.

Установите Vagrant и VirtualBox: Если у вас еще не установлены Vagrant и VirtualBox, установите их на вашем компьютере.

![v_ver.PNG](img%2Fv_ver.PNG)

Инициализация проекта: Создайте новую директорию для вашего проекта. В этой
директории выполните команду vagrant init, чтобы создать файл Vagrantfile.

```
vagrant init
```
![v_init.PNG](img%2Fv_init.PNG)

Настройка виртуальной машины: Откройте Vagrantfile и настройте виртуальную машину следующим образом:

1. Используйте базовый образ, например, Ubuntu 20.04.
2. Установите количество CPU и объем оперативной памяти, которые вы считаете подходящими.
3. Пропишите проксирование портов, чтобы вы могли получить доступ к виртуальной машине извне.

nano Vagrantfile

```
Vagrant.configure("2") do |config|

  config.vm.box = "ubuntu/focal64"                          # boxes at https://vagrantcloud.com/search.
  config.vm.network "forwarded_port", guest: 80, host: 8080 # Create a forwarded port mapping which allows access to a specific port within the machine from a port on the host machine.

  config.vm.provider "virtualbox" do |vb|

    vb.name = "ubuntu-dev" # vm name on virtual box list
    vb.memory = "1024"
    vb.cpus = 1
  end

  config.vm.hostname = "ubuntu-dev-hostname" # vm hostname
end

```

4. Запуск виртуальной машины: Запустите виртуальную машину с помощью команды vagrant up.

```
vagrant up
```

![v_up.PNG](img%2Fv_up.PNG)


5. SSH-подключение: Подключитесь к виртуальной машине через SSH с помощью команды vagrant ssh. Убедитесь, что вы можете успешно войти в виртуальную машину.

![v_ssh.PNG](img%2Fv_ssh.PNG)

6. Выключение и уничтожение: Выполните команды vagrant halt для выключения виртуальной машины и vagrant destroy для удаления ее.

![v_halt_destroy.PNG](img%2Fv_halt_destroy.PNG)

7. Логирование: Ведите лог своих действий в файле, используя команды и результаты выполнения. Это поможет вам отслеживать, как вы выполняли каждый этап задачи.

```
vagrant --version
vagrant init - initialize the current directory to be a Vagrant environment
vagrant up - creates vm/powers on os
vagrant ssh
vagrant halt - powers off os
vagrant destroy 
Vagrant box list - lists all downloaded boxes/images
Vagrant status - state of OS (running/stopped)
Vagrant reload - restarts OS
```

