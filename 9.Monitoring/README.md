## Задача 1: Установка и Настройка Prometheus и Grafana

### Цель: Установить и настроить Prometheus и Grafana в кластере Minikube.

- Установите Prometheus в кластере Minikube, используя Helm Chart
- Установите Grafana также с использованием Helm Chart

```
# installs prometheus 
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/prometheus
kubectl expose service prometheus-server --type=NodePort --target-port=9090 --name=prometheus-nodeport
kubectl expose service prometheus-alertmanager --type=NodePort --target-port=9093 --name=alertmanager-nodeport
kubectl describe svc prometheus-nodeport

# Installs Grafana
helm repo add grafana 
helm install grafana grafana/grafana
kubectl expose service grafana --type=NodePort --target-port=3000 --name=grafana-nodeport
kubectl get secret --namespace default grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo # get admin password
```

![mon_stack.PNG](img%2Fmon_stack.PNG)

- Настройте Prometheus для мониторинга самого себя (self-monitoring)

```
kubectl edit cm prometheus-server

scrape_configs:
  - job_name: 'Prometheus'
    scrape_interval: 10s
    static_configs:
      - targets: ['localhost:9090']
```
![pm-target.PNG](img%2Fpm-target.PNG)

- Создайте источник данных (data source) Prometheus в Grafana.

```
Home -> Connections -> Data sources -> Prometheus -> http://prometheus-server:80

```

![ds.PNG](img%2Fds.PNG)

### Задача 2: Создание Дашборда в Grafana

Цель: Создать пользовательский дашборд в Grafana и добавить на него панели с данными из Prometheus.
- Войдите в интерфейс Grafana и создайте новый дашборд.
- Добавьте на дашборд несколько панелей, используя метрики из Prometheus.
- Например, можно добавить график с использованием метрики prometheus_http_requests_total.

![gf_dash.PNG](img%2Fgf_dash.PNG)

- Настройте панели, чтобы они отображали интересующие вас метрики и временной интервал.

использовал dashboard id 10000 

![cl_mon.PNG](img%2Fcl_mon.PNG)

![cl_mon2.PNG](img%2Fcl_mon2.PNG) 


### Задача 3: Создание Алертов в Prometheus и Интеграция с Grafana

Цель: Создать алерты в Prometheus и интегрировать их с Grafana для мониторинга состояния кластера Minikube.

- Создайте правило алерта в файле конфигурации Prometheus. Например, правило может отслеживать использование CPU или памяти.

```
kubectl get cm
kubectl edit cm prometheus-server

alerting_rules.yml: |
  groups:
  - name: Alerts
    rules:        
    - alert: HostHighCpuLoad
      expr: (sum by (instance) (avg by (mode, instance) (rate(node_cpu_seconds_total{mode!="idle"}[2m]))) > 0.8) * on(instance) group_left (nodename) node_uname_info{nodename=~".+"}
      for: 1m
      labels:
        severity: warning
      annotations:
        summary: Host high CPU load (instance {{ $labels.instance }})
        description: "CPU load is > 80%\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"
    - alert: HostOutOfMemory
      expr: (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes * 100 < 10) * on(instance) group_left (nodename) node_uname_info{nodename=~".+"}
      for: 1m
      labels:
        severity: warning
      annotations:
        summary: Host out of memory (instance {{ $labels.instance }})
        description: "Node memory is filling up (< 10% left)\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

```

![a_rules.PNG](img%2Fa_rules.PNG)

Делаем stresstest на cpu

![s_test.PNG](img%2Fs_test.PNG)

![pm_alerts.PNG](img%2Fpm_alerts.PNG)


- Настройте интеграцию алерта Prometheus с Grafana, чтобы алерты отображались в интерфейсе Grafana.

![gr_alerts.PNG](img%2Fgr_alerts.PNG)

Useful links
- https://samber.github.io/awesome-prometheus-alerts/rules.html 
- https://prometheus.io/docs/tutorials
- https://grafana.com/grafana/dashboards/






