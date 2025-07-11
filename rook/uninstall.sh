#!/bin/bash

set -euo pipefail

NAMESPACE="rook-ceph"
CRD_FILE="/root/k8s_helm/rook/rook/deploy/examples/crds.yaml"

echo "🔧 Uninstalling Helm releases..."
helm uninstall -n $NAMESPACE rook-ceph || true
helm uninstall -n $NAMESPACE rook-ceph-cluster || true

echo "🧹 Cleaning up ConfigMaps and Secrets..."
kubectl delete -n $NAMESPACE cm,secret --all --wait=false || true

echo "🔓 Removing finalizers from mon resources..."
kubectl -n $NAMESPACE patch configmap/rook-ceph-mon-endpoints --type=merge -p '{"metadata":{"finalizers":[]}}' || true
kubectl -n $NAMESPACE patch secret/rook-ceph-mon --type=merge -p '{"metadata":{"finalizers":[]}}' || true

echo "🗑️ Deleting Ceph custom resources..."
RESOURCES=(
  "cephcluster/rook-ceph"
  "CephObjectStore/ceph-objectstore"
  "CephFilesystem/ceph-filesystem"
  "CephBlockPool/ceph-blockpool"
  "CephBlockPool/rook-ceph"
)

for res in "${RESOURCES[@]}"; do
  kubectl -n $NAMESPACE delete $res --wait=false || true
done

echo "🔓 Removing finalizers from Ceph resources..."
for res in "${RESOURCES[@]}"; do
  kubectl -n $NAMESPACE patch $res --type=merge -p '{"metadata":{"finalizers":[]}}' || true
done

echo "❌ Deleting CRDs..."
kubectl delete -f "$CRD_FILE" --wait=false || true

echo "🔓 Removing finalizers from remaining CRDs..."
CRDS=(
  "cephfilesystemsubvolumegroups.ceph.rook.io"
  "cephclusters.ceph.rook.io"
)

for crd in "${CRDS[@]}"; do
  kubectl patch crd "$crd" --type=merge -p '{"metadata":{"finalizers":[]}}' || true
done

# echo "🧽 Cleaning up data directories..."
# sudo rm -rf /var/lib/rook
# ssh dgx-w1 rm -rf /var/lib/rook
# ssh dgx1 rm -rf /var/lib/rook

# echo "🗑️ Optionally delete namespace:"
# kubectl delete ns $NAMESPACE --wait=false

echo "✅ Uninstall complete."

