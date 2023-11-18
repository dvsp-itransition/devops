## Задача 2.3: Автоматизация конфигурации и администрирование виртуальной машины с помощью Ansible

В этой задаче вам предстоит создать виртуальную машину с использованием Vagrant и
VirtualBox, а затем автоматизировать её конфигурацию и выполнить несколько задач по
администрированию Linux с помощью Ansible

Инициализация проекта: Создайте новую директорию для вашего проекта. В этой
директории выполните команду vagrant init, чтобы создать файл Vagrantfile.

![v_init.PNG](img%2Fv_init.PNG)

Создаем ssh ключей для ansible
```
ssh-keygen -f F:/vagrant/ansible/id_rsa -N ""
```

Создание виртуальной машины: В файле Vagrantfile определите виртуальную машину
с базовым образом Ubuntu 20.04 (или другой по вашему выбору). Укажите параметры CPU,
RAM и другие настройки виртуальной машины.

#### Для этой задачи сделал vagrant файл, который автоматизирует создание 2 виртуальных машин (ansible controller и web vm) на virtualbox и их дальнейшие автоматическое конфигурирование с помощью ansible-плейбука при запуске vagrant up

nano Vagrantfile

```
Vagrant.configure("2") do |config|

  config.vm.box = "ubuntu/focal64"

#------------------WEB START--------------------

  config.vm.define "web" do |machine|
    machine.vm.hostname = "web"
    machine.vm.network "private_network", ip: "192.168.200.254"
    machine.vm.provision "shell", inline: "cat /vagrant/id_rsa.pub | tee -a /home/vagrant/.ssh/authorized_keys > /dev/null"

    machine.vm.provider "virtualbox" do |vb|
      vb.name = "web"
      vb.memory = "1024"
      vb.cpus = 1
    end
  end

#-------------------WEB END----------------------

#----------------ANSIBLE CONTROLLER START------------------

  config.vm.define "ansible" do |machine|
    machine.vm.hostname = "ansible"
    machine.vm.network "private_network", ip: "192.168.200.200"

    machine.vm.provision "ansible-install", type: "shell", path: "ansible.sh"
    machine.vm.provision "file", source: "./id_rsa", destination: "/home/vagrant/.ssh/id_rsa"
    machine.vm.provision "file", source: "./id_rsa.pub", destination: "/home/vagrant/.ssh/id_rsa.pub"
    machine.vm.provision "shell", inline: "chmod 400 /home/vagrant/.ssh/id_rsa"

    machine.vm.provision "ansible_local" do |ansible|
      ansible.playbook = "/vagrant/playbook.yml"
      ansible.inventory_path = "/vagrant/hosts"
      ansible.limit          = "all"
    end

    machine.vm.provider "virtualbox" do |vb|
      vb.name = "ansible"
      vb.memory = "2048"
      vb.cpus = 1
    end
  end

#-----------------ANSIBLE CONTROLLER END-------------------
end
```

nano ansible.sh
```
#!/bin/bash
sudo apt update
sudo apt install ansible -y
rm -f /etc/ansible/ansible.cfg

cat > /etc/ansible/ansible.cfg <<EOT
[defaults]
sudo_user = root
host_key_checking = False
EOT

# creating inventory file
cat > /vagrant/hosts <<HOSTS
web ansible_host=192.168.200.254 ansible_user=vagrant ansible_ssh_private_key_file=/home/vagrant/.ssh/id_rsa
HOSTS
```

Запуск виртуальной машины: Запустите виртуальную машину с помощью команды vagrant up.

![v_up_web.PNG](img%2Fv_up_web.PNG)

![v_up_ansible.PNG](img%2Fv_up_ansible.PNG)

![v_instances.PNG](img%2Fv_instances.PNG)

![v_web.PNG](img%2Fv_web.PNG)

![v_ansible.PNG](img%2Fv_ansible.PNG)

Настройка Ansible: Установите Ansible на вашем локальном компьютере, если он ещё не
установлен. Создайте файл ansible.cfg и настройте его для использования виртуальной
машины.

Ansible и ansible.cfg автоматический создано и установлено при запуске vagrant up

![a_install.PNG](img%2Fa_install.PNG)

![a_ssh.PNG](img%2Fa_ssh.PNG)

Написание Ansible-плейбука: Создайте Ansible-плейбук для конфигурации вашей виртуальной машины. 

Плейбук должен включать в себя следующие задачи:

- Обновление пакетов на виртуальной машине.
- Установка и настройка веб-сервера (например, Apache или Nginx).
- Создание пользовательского аккаунта и установка SSH-ключа для аутентификации.
- Применение плейбука: Запустите Ansible-плейбук для конфигурации виртуальной машины. Убедитесь, что все задачи выполнились успешно.

Задачи по администрированию Linux: Добавьте следующие задачи в ваш Ansible-плейбук:
- Создание текстового файла с временем его создания.
- Установка дополнительного программного обеспечения (например nginx, apache2,etc).
- Создание расписания с использованием cron для выполнения задачи (например, регулярной очистки временных файлов).
- Логирование: Ведите лог своих действий и операций, выполненных с использованием Ansible

Ansible-плейбук такжe автоматический выполнено при запуске vagrant up

![a_playbook.PNG](img%2Fa_playbook.PNG)

nano playbook.yml
```
---
- hosts: web
  become: yes
  tasks:
    - name: install packages
      apt:
        name: '{{ item }}'
        state: present
        update_cache: yes
      loop:
        - nginx
        - mc

    - name: add new group
      group:
        name: ansible
        state: present

    - name: add user
      user:
        name: ansible
        group: ansible
        shell: /bin/bash
        create_home: yes
        home: /home/ansible

    - name: Create ssh directory
      file:
        path: /home/ansible/.ssh
        state: directory
        recurse: yes
        owner: ansible
        group: ansible
        mode: '0700'

    - name: Create authorized_keys file
      become_user: root
      blockinfile:
        path: /home/ansible/.ssh/authorized_keys
        create: yes
        owner: ansible
        group: ansible
        mode: '0600'
        block: "{{lookup('ansible.builtin.file', '/vagrant/id_rsa.pub')}}"

    - name: Create file
      file:
        path: "/home/ansible/temp_file_{{lookup('pipe', 'date +%F_%T')}}"
        owner: ansible
        group: ansible
        state: touch

    - name: Add cronjob to delete temp files
      cron:
        name: cron job
        user: ansible
        minute: '0'
        hour: '22'
        job: 'rm -f /tmp/*'
```

Отчет: Подготовьте отчет, описывающий все действия, выполненные вами при создании
и настройке виртуальной машины с использованием Ansible. Укажите, какие команды и
плейбуки использовались, и какие результаты были получены. Также укажите, если
возникли какие-либо проблемы и как вы их решали.

#### Результаты выполнение Ansible-плейбук

![web_ssh.PNG](img%2Fweb_ssh.PNG)

Установлен nginx и создан новый пользователь ansible

![w_nginx_user_status.PNG](img%2Fw_nginx_user_status.PNG)

![a_tasks.PNG](img%2Fa_tasks.PNG)

Проверяем подключение с нового пользователя ansible 

![ssh_con.PNG](img%2Fssh_con.PNG)





