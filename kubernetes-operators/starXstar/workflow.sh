#!/usr/bin/env bash

# 1. Install operator-sdk
# Ref: https://sdk.operatorframework.io/docs/installation/

# 2. Find and add Helm Chart repo locally
helm repo add homeenterpriseinc https://homeenterpriseinc.github.io/helm-charts/

# 3. Init operator-sdk project
mkdir "mysql-operator" && cd mysql-operator
operator-sdk init --domain otus.homework --plugins helm --helm-chart=homeenterpriseinc/mysql --group=mysql --kind=MySQL --version=v1

# 4. Check and fix (на самом деле нет :) ) generated config

# 5. Build and push docker image from project dir
make docker-build docker-push IMG="ilyang/mysql-operator:v0.0.1"

# 6. Prepare operator to deploy into cluster
# make deploy
cp config/crd/bases/* ../ # тут описание crd
cp config/samples/mysql* ./ # тут образец CR со всеми полями, извлеченными из values Helm-чарта