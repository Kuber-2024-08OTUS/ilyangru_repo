#!/usr/bin/env bash
# Сгенерировать kubeconfig для ServiceAccount "cd" и его токена "cd-kubeconfig-sa-token"
# при условии что текущий контекст kubectl указывает на кластер где применены манифесты из задания:
# chmod u+x ./gen-kubeconfig-for-sa.sh && ./gen-kubeconfig-for-sa.sh
#
# Ref: https://docs.armory.io/continuous-deployment/armory-admin/manual-service-account/#get-the-service-account-and-token

# Update these to match your environment
# BEGIN
SERVICE_ACCOUNT_NAME="cd"
CONTEXT=$(kubectl config current-context)
NAMESPACE=homework

NEW_CONTEXT="$CONTEXT-$SERVICE_ACCOUNT_NAME"
KUBECONFIG_PATH="$HOME/kubeconfig"
KUBECONFIG_FILE="$KUBECONFIG_PATH/kubeconfig-$NEW_CONTEXT"
# END

# В моей версии minikube почему то нет такого поля => закоментировал оригинальную часть из Ref
#SECRET_NAME=$(kubectl get serviceaccount ${SERVICE_ACCOUNT_NAME} \
#  --context ${CONTEXT} \
#  --namespace ${NAMESPACE} \
#  -o jsonpath='{.secrets[0].name}')
SECRET_NAME=$(kubectl describe serviceaccounts cd | grep 'Tokens:' | cut -d ':' -f 2 | xargs)

TOKEN_DATA=$(kubectl get secret ${SECRET_NAME} \
  --context ${CONTEXT} \
  --namespace ${NAMESPACE} \
  -o jsonpath='{.data.token}')

TOKEN=$(echo ${TOKEN_DATA} | base64 -d)

# Create dedicated kubeconfig
# Create a full copy
kubectl config view --raw > ${KUBECONFIG_FILE}.full.tmp
# Switch working context to correct context
kubectl --kubeconfig ${KUBECONFIG_FILE}.full.tmp config use-context ${CONTEXT}
# Minify
kubectl --kubeconfig ${KUBECONFIG_FILE}.full.tmp \
  config view --flatten --minify > ${KUBECONFIG_FILE}.tmp
# Rename context
kubectl config --kubeconfig ${KUBECONFIG_FILE}.tmp \
  rename-context ${CONTEXT} ${NEW_CONTEXT}
# Create token user
kubectl config --kubeconfig ${KUBECONFIG_FILE}.tmp \
  set-credentials ${CONTEXT}-${NAMESPACE}-token-user \
  --token ${TOKEN}
# Set context to use token user
kubectl config --kubeconfig ${KUBECONFIG_FILE}.tmp \
  set-context ${NEW_CONTEXT} --user ${CONTEXT}-${NAMESPACE}-token-user
# Set context to correct namespace
kubectl config --kubeconfig ${KUBECONFIG_FILE}.tmp \
  set-context ${NEW_CONTEXT} --namespace ${NAMESPACE}
# Flatten/minify kubeconfig
kubectl config --kubeconfig ${KUBECONFIG_FILE}.tmp \
  view --flatten --minify > ${KUBECONFIG_FILE}
# Remove tmp
rm ${KUBECONFIG_FILE}.full.tmp
rm ${KUBECONFIG_FILE}.tmp