helm repo add rook-release https://charts.rook.io/release
# operator
helm upgrade --install --create-namespace --namespace rook-ceph rook-ceph rook-release/rook-ceph -f operator-values.yaml
# cluster
helm upgrade --install --create-namespace --namespace rook-ceph rook-ceph-cluster \
   --set operatorNamespace=rook-ceph rook-release/rook-ceph-cluster -f cluster-values.yaml
