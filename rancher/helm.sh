
helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
helm  upgrade --install rancher rancher-latest/rancher --namespace cattle-system --create-namespace -f values.yaml
