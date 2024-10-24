#!/usr/bin/env bash

# установка prometheus-оператора в кластер
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
kubectl create namespace prometheus-operator
kubectl ns prometheus-operator
helm install prometheus prometheus-community/kube-prometheus-stack

# развертывание тестового приложения в дефолтном ns и ServiceMonitor к нему
kubectl ns default
kubectl apply -f cm-nginx-configmap.yaml -f deployment.yaml -f service.yaml -f serviceMonitor.yaml

# проверка работоспособности
kubectl port-forward -n prometheus-operator statefulsets/prometheus-prometheus-kube-prometheus-prometheus 9090:9090
## В браузере по http://localhost:9090/service-discovery убедиться что ServiceDiscovery serviceMonitor/default/deployment-demo появилась в списке
## В браузере по http://localhost:9090/targets убедиться что появилось 3 таргета serviceMonitor/default/deployment-demo
## И убедиться что метрики на странице http://localhost:9090/graph собираются, например метрика nginx_connections_accepted