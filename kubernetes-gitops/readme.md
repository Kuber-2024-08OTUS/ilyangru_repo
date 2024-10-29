## Задание №10: ArgoCD, Flux, Flagger
### Установка ArgoCD
Добавить репозиторий ArgoCD в `helm` и обновить список чартов из него
```shell
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update argo
```
Ознакомиться с дефолтной конфигурацией чарта 
```shell
helm show values argo/argo-cd > helm-values-argocd-defaults.yaml
```
```shell
kubectl create namespace argocd
helm upgrade --install -n argocd argocd argo/argo-cd --values helm-values-argocd.yaml
```