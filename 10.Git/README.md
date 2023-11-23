### Задача: Начало работы с Git 

Цель: Создать новый репозиторий, выполнить коммиты и пуш в удаленный репозиторий.
1. Инициализируйте новый Git-репозиторий в пустой директории.
2. Создайте новый текстовый файл с именем hello.txt и добавьте в него любой текст.
3. Добавьте hello.txt в индекс и создайте коммит с сообщением "Добавлен файл hello.txt".
4. Создайте удаленный репозиторий на платформе, такой как GitHub.
5. Свяжите ваш локальный репозиторий с удаленным репозиторием (git remote add origin <URL>).
6. Отправьте коммиты в удаленный репозиторий с помощью git push origin master. general structure for course

```
mkdir -p gitrepo && cd gitrepo
git init
git config --global user.email "dvsp@yahoo.com"
git config --global user.name "dvsp"
cat .git/config
git config --list
touch hello.txt
echo "first text" > hello.txt
git add hello.txt
git status
git commit -m "Добавлен файл hello.txt"
git log --oneline
git remote add origin git@github.com:dvsp-itransition/gitrepo.git
git remote -v; git remote show origin # to see which remote URL you have currently in this local repository
git branch
git push origin master
```

![t1.PNG](img%2Ft1.PNG)

Работа с ветками

Цель: Создать и переключаться между ветками, выполнить слияние веток.
1. Создайте новую ветку с именем "feature" (git branch feature) и переключитесь на нее (git checkout feature).
2. Внесите изменения в файл hello.txt, например, добавьте еще текст.
3. Добавьте и закоммитьте изменения в ветке "feature".
4. Переключитесь обратно на ветку "master".
5. Слейте ветку "feature" с веткой "master" (git merge feature) и решите возможные конфликты.

```
git branch feature
git branch
git checkout feature
echo "second text" >> hello.txt
git add hello.txt
git commit -m "second text"
git log --oneline
git checkout master
"third text" >> hello.txt
git add .
git commit -m "third text"
git merge feature
```
![t2_mc.PNG](img%2Ft2_mc.PNG)

![t2_mc2.PNG](img%2Ft2_mc2.PNG)

nano hello.txt

![t2_mc3.PNG](img%2Ft2_mc3.PNG)

```
git add hello.txt
git commit -m "fixed merge conflicts"
git merge feature
```

![t2_mc4.PNG](img%2Ft2_mc4.PNG)

Работа с удаленным репозиторием и ветками

Цель: Работа с удаленными ветками и синхронизация с удаленным репозиторием.

1. Склонируйте удаленный репозиторий на вашу локальную машину.
2. Создайте новую ветку с именем "feature-remote" (git checkout -b feature-remote).
3. Внесите изменения в файл hello.txt и закоммитьте их.
4. Отправьте новую ветку "feature-remote" в удаленный репозиторий (git push origin feature-remote).
5. В GitHub создайте запрос на слияние (Pull Request) для ветки "feature-remote" в ветку "master".

```
git clone git@github.com:dvsp-itransition/gitrepo.git
cd gitrepo
git checkout -b feature-remote
git branch
echo "some text" >> hello.txt
git add hello.txt
git commit -m "some text"
git push origin feature-remote
```

создано pull request

![t3_pr.PNG](img%2Ft3_pr.PNG)

Попросите другого студента (или преподавателя) просмотреть и принять ваш Pull Request

![t3_merged.PNG](img%2Ft3_merged.PNG)

![t3_result.PNG](img%2Ft3_result.PNG)