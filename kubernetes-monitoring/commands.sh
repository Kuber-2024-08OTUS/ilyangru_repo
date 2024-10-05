#!/usr/bin/env bash

# установка prometheus-оператора в кластер
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
kubectl create namespace prometheus-operator
kubectl ns prometheus-operator
helm install prometheus prometheus-community/kube-prometheus-stack

