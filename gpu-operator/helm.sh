helm repo add nvidia https://helm.ngc.nvidia.com/nvidia && helm repo update
helm upgrade --install --wait gpu-operator -n gpu-operator --create-namespace nvidia/gpu-operator \
     --version=v25.3.0 \
     --values=values.yaml
