helm repo add gitea-charts https://dl.gitea.com/charts/
helm repo update
helm upgrade --install -n gitea-system --create-namespace -f values.yaml gitea gitea-charts/gitea
