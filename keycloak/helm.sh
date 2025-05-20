# https://artifacthub.io/packages/helm/bitnami/keycloak
helm upgrade -f values.yaml --install -n keycloak-system --create-namespace keycloak oci://registry-1.docker.io/bitnamicharts/keycloak
