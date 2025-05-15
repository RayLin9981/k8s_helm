helm repo add gitlab https://charts.gitlab.io/
helm repo update
#helm upgrade --install gitlab gitlab/gitlab \
#  --timeout 600s \
#  --set global.hosts.domain=gitlab.fck8slab.local \
#  --set global.hosts.externalIP=192.168.147.61 \
#  --set certmanager-issuer.email=ray.lin@fongcon.com.tw



helm upgrade  -n gitlab-system --create-namespace --install gitlab-system gitlab/gitlab -f values.yaml --timeout 600s 
