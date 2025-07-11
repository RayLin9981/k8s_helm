k create secret generic gitlab.fck8slab.local.crt --from-file=./gitlab.fck8slab.local.crt -n gitlab-system
k -n gitlab-system create secret generic my-ldap-password-secret --from-literal=password='1qaz!QAZ'
