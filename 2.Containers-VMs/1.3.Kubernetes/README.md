## Задача:

**2.6: Знакомство с Kubernetes и Minikube**

Цель этой задачи - ознакомиться с Kubernetes и Minikube, создать мини-кластер Kubernetes и выполнить несколько базовых операций с контейнерами

- Установка Minikube и kubectl: Если еще не установлены Minikube и kubectl, они должны быть установлены их на рабочих станциях

Устанавливаем minikube, kubectl

nano minikube.sh
```
#!/bin/bash
sudo apt update 
# installs kubectl
curl -LO https://dl.k8s.io/release/`curl -LS https://dl.k8s.io/release/stable.txt`/bin/linux/amd64/kubectl && chmod +x ./kubectl && sudo mv ./kubectl /usr/local/bin/kubectl
alias k=kubectl
# installs & starts minikube 
curl -Lo minikube https://storage.googleapis.com/minikube/releases/v1.23.2/minikube-linux-amd64 && chmod +x minikube && sudo mv minikube /usr/local/bin/
sudo apt install conntrack
sudo apt -y install docker.io

```

- Запуск Minikube: Создать и запустить локальный мини-кластер Kubernetes с помощью команды minikube start.
- Проверка состояния кластера: Использовать команду kubectl cluster-info для проверки состояния кластера Kubernetes и доступности API сервера.

```
minikube start --vm-driver=none
kubectl cluster-info
minikube status
```
![k_status.PNG](2.6%2Fimg%2Fk_status.PNG)


- Создание и запуск пода: Создать файл манифеста для пода (например, my-pod.yaml) и запустить его в кластере с помощью kubectl create -f my-pod.yaml. Под должен содержать простое веб-приложение, которое будет доступно через сервис Kubernetes.

```
 kubectl run my-pod --image=nginx --dry-run=client -o yaml > my-pod.yaml
 kubectl create -f my-pod.yaml
 kubectl expose pod my-pod --port 80 --name svc-pod 
```

nano my-pod.yaml

```
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: my-pod
  name: my-pod
spec:
  containers:
  - image: nginx
    name: my-pod
```

- Проверка пода и сервиса: Использовать команды kubectl get pods и kubectl get services для проверки состояния своего пода и сервиса. 

![g_pods_svc.PNG](2.6%2Fimg%2Fg_pods_svc.PNG)


- Они также могут использовать команду kubectl describe pod <имя пода> для получения дополнительной информации о поде.

![k_describe.PNG](2.6%2Fimg%2Fk_describe.PNG)

- Журналы и отладка: Использовать команду kubectl logs <имя пода> для просмотра журналов пода и команду kubectl exec -it <имя пода> --/bin/bash для отладки внутри контейнера пода.

![k_logs_pod.PNG](2.6%2Fimg%2Fk_logs_pod.PNG)

![k_exec.PNG](2.6%2Fimg%2Fk_exec.PNG)


- Остановка и удаление ресурсов: Остановить и удалить свой под и сервис с помощью команд kubectl delete pod <имя пода> и kubectl delete service <имя сервиса>

![k_del.PNG](2.6%2Fimg%2Fk_del.PNG)

- Остановка Minikube: По окончании задачи, остановить локальный мини-кластер Kubernetes с помощью minikube stop.

![m_stop.PNG](2.6%2Fimg%2Fm_stop.PNG)

#### Дополнительно к задаче, я создал манифест файлы deployment, service, namespace и веб-приложение в контейнере nginx и использовал helm charts для его дальнейшего развертывания.

**Структура**

![structure.PNG](2.6%2Fimg%2Fstructure.PNG)

Запуск миникуб

```
minikube start --vm-driver=none
kubectl cluster-info
minikube status
```

![44220975-7193-4fb2-863a-a9f2b998844a.png](2.6%2Fimg%2F44220975-7193-4fb2-863a-a9f2b998844a.png)


**Создаем манифест файлы**

создаем deployment

```
kubectl create deployment webapp --image dvsp-webapp:v1 --replicas 1 -n webapp --dry-run=client -o yaml > manifests/deployment.yaml

apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: webapp
  name: webapp
  namespace: webapp
spec:
  replicas: 2
  selector:
    matchLabels:
      app: webapp
  template:
    metadata:      
      labels:
        app: webapp
    spec:
      containers:
      - image: dvsp-webapp:v1
        name: webapp  
        ports:
          - containerPort: 80      
        livenessProbe:
          exec:
            command:
            - /bin/sh
            - -c
            - "nginx -version"
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 10
        resources:
          requests:
            memory: "256Mi"
            cpu: "0.25"
          limits:
            memory: "512Mi"
            cpu: "0.5"

```

**создаем сервиса NodePort**

```
kubectl expose deployment webapp --port=80 --target-port=80 --type NodePort -n webapp --dry-run=client -o yaml > manifests/service.yaml

apiVersion: v1
kind: Service
metadata:
  labels:
    app: webapp
  name: webapp
  namespace: webapp
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
    nodePort: 30003
  selector:
    app: webapp
  type: NodePort
```

**создаем namespace**

```
kubectl create ns webapp --dry-run=client -o yaml > manifests/namespace.yaml
 
apiVersion: v1
kind: Namespace
metadata:
  name: webapp
```

**Создаем docker образ из nginx для веб приложения**

```
nano Dockerfile
FROM nginx:stable-alpine
RUN wget https://www.tooplate.com/zip-templates/2123_simply_amazed.zip && \
    unzip 2123_simply_amazed.zip && \
    mv 2123_simply_amazed/* /usr/share/nginx/html/
EXPOSE 80

docker build -t dvsp-webapp:v1
```

![275816459-2eee4600-c1a2-4beb-8f63-162ed801c1a9.png](2.6%2Fimg%2F275816459-2eee4600-c1a2-4beb-8f63-162ed801c1a9.png)

**Запускаем наши сервисы/обьекты**

```
kubectl create -f namespace.yaml
kubectl create -f deployment.yaml
kubectl create -f service.yaml
```

![275821496-0b396562-8aff-469d-aaaa-e919f32bba50.png](2.6%2Fimg%2F275821496-0b396562-8aff-469d-aaaa-e919f32bba50.png)

![275822063-1c874333-fabd-437c-8d22-7aaeddd63b0b.png](2.6%2Fimg%2F275822063-1c874333-fabd-437c-8d22-7aaeddd63b0b.png)

![275824500-e57c9376-737e-48f3-8966-15b3f978190b.png](2.6%2Fimg%2F275824500-e57c9376-737e-48f3-8966-15b3f978190b.png)

![275826895-7e0349a4-437d-441d-a306-6be015463b36.png](2.6%2Fimg%2F275826895-7e0349a4-437d-441d-a306-6be015463b36.png)

**Теперь используем helm Chart для дальнейшего развертывания наших приложений в kubernetes**

Helm - это пакетный менеджер для кубернетес, инструмент для управления чартами. Чарт - описывает необходимый набор данных для создания экземпляра приложения в кластере Kubernetes. Он содержит все определения ресурсов, необходимые для запуска приложения, инструмента или службы внутри кластера Kubernetes.

**Установка Helm**

```
curl https://get.helm.sh/helm-v3.12.0-linux-amd64.tar.gz > helm.tar.gz
tar xzvf helm.tar.gz
mv linux-amd64/helm /usr/local/bin
```

**Создаем chart со всеми необходимыми файлами в каталоге webapp-chart**

```
helm create webapp-chart
```

**Берем ранее подготовленный манифест файлы и вставляем свой значение в файлы templates, а также в values.yaml и Chart.yaml** 

nano templates/deployment.yaml

```
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: {{ .Values.application.name }}
  name: {{ .Chart.Name }}
  namespace: {{ .Values.namespace }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: {{ .Values.application.name }}
  template:
    metadata:      
      labels:
        app: {{ .Values.application.name }}
    spec:
      containers:
      - image: "{{ .Values.image.repository }}"
        name: {{ .Chart.Name }}
        livenessProbe:
          exec:
            command:
            - /bin/sh
            - -c
            - "nginx -version"
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /
            port: {{ .Values.service.port}}
          initialDelaySeconds: 30
          periodSeconds: 10
        ports:
          - containerPort: {{ .Values.service.targetPort}}
        resources:
          requests:
            memory: "{{ .Values.resources.requests.memory }}"
            cpu: "{{ .Values.resources.requests.cpu }}"
          limits:
            memory: "{{ .Values.resources.limits.memory }}"
            cpu: "{{ .Values.resources.limits.cpu }}"
```

nano templates/service.yaml

```
apiVersion: v1
kind: Service
metadata:
  labels:
    app: {{ .Values.application.name }}
  name: {{ .Chart.Name }}
  namespace: {{ .Values.namespace }}
spec:
  ports:
  - port: {{ .Values.service.port}}
    protocol: TCP
    targetPort: {{ .Values.service.targetPort}}
    nodePort: {{ .Values.service.nodePort}}
  selector:
    app: {{ .Values.application.name }}
  type: {{ .Values.service.type}}
```

nano templates/namespace.yaml
```
apiVersion: v1
kind: Namespace
metadata:
  name: {{ .Values.namespace }}
```

nano values.yaml
```
replicaCount: 2

image:
  repository: dvsp-webapp:v1

service:
  name: webapp
  type: NodePort
  port: 80
  targetPort: 80
  nodePort: 30003

namespace: webapp

application:
  name: webapp

resources:
  requests:
    memory: "256Mi"
    cpu: "0.25"
  limits:
    memory: "512Mi"
    cpu: "0.5"
```

nano Chart.yaml
```
apiVersion: v2
name: webapp
description: webapp Helm Chart
type: application
version: 0.1.0
appVersion: "1.0.0"
maintainers:
- email: 123@admin.com
  name: kube
```

**проверяем наш созданный chart**

```
helm lint webapp-chart
helm template webapp-chart
helm install --dry-run webapp webapp-chart
```

**Установка пакета/релиза webapp**
```
helm install webapp webapp-chart/
helm list # shows all the releases installed in the cluster
# helm delete webapp
```

## Результаты:

### Приложение успешно развернуто в Kubernetes 

![275842988-29563da2-362a-4ce6-a28d-5cf2fd7d81c0.png](2.6%2Fimg%2F275842988-29563da2-362a-4ce6-a28d-5cf2fd7d81c0.png)

![275843386-fa74430a-d0b7-4156-b0f1-2b666cb7f02e.png](2.6%2Fimg%2F275843386-fa74430a-d0b7-4156-b0f1-2b666cb7f02e.png)




