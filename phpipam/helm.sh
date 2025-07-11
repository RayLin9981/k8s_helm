#/bin/bash
helm upgrade --install -f values.yaml phpipam ./phpipam-chart --namespace phpipam --create-namespace 
#helm repo add phpipam https://nullconfig.github.io/phpipam/stable
#helm repo update
#
##helm search repo phpipam
#helm upgrade --install  --create-namespace phpipam phpipam/phpipam \
#  --namespace phpipam \
#    -f values.yaml

# helm uninstall -n phpipam phpipam
