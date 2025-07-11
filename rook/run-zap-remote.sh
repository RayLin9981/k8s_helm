#!/bin/bash

# === 參數設定 ===
NODES=("dgx-w1" "bcm10-headnode" "dgx1")
REMOTE_SCRIPT="/tmp/zap-disk.sh"

# === 清理腳本內容（會在遠端執行）===
CLEAN_SCRIPT_CONTENT='#!/bin/bash
set -euo pipefail

echo "🔍 掃描 ceph 可能的磁碟於 $(hostname)..."
DISK="/dev/sdb"

# Zap the disk to a fresh, usable state (zap-all is important, b/c MBR has to be clean)
sgdisk --zap-all $DISK

# Wipe portions of the disk to remove more LVM metadata that may be present
dd if=/dev/zero of="$DISK" bs=1K count=200 oflag=direct,dsync seek=0 # Clear at offset 0
dd if=/dev/zero of="$DISK" bs=1K count=200 oflag=direct,dsync seek=$((1 * 1024**2)) # Clear at offset 1GB
dd if=/dev/zero of="$DISK" bs=1K count=200 oflag=direct,dsync seek=$((10 * 1024**2)) # Clear at offset 10GB
dd if=/dev/zero of="$DISK" bs=1K count=200 oflag=direct,dsync seek=$((100 * 1024**2)) # Clear at offset 100GB
dd if=/dev/zero of="$DISK" bs=1K count=200 oflag=direct,dsync seek=$((1000 * 1024**2)) # Clear at offset 1000GB
echo "➡ 處理 $DISK"
blkdiscard "$DISK" || echo "⚠ blkdiscard 失敗或不支援：$DISK"
sgdisk --zap-all "$DISK"

echo "🧹 清除常見 metadata 區塊..."
dd if=/dev/zero of="$DISK" bs=1K count=200 oflag=direct,dsync seek=0
dd if=/dev/zero of="$DISK" bs=1K count=200 oflag=direct,dsync seek=$((1 * 1024**2))
dd if=/dev/zero of="$DISK" bs=1K count=200 oflag=direct,dsync seek=$((10 * 1024**2))
dd if=/dev/zero of="$DISK" bs=1K count=200 oflag=direct,dsync seek=$((100 * 1024**2))
dd if=/dev/zero of="$DISK" bs=1K count=200 oflag=direct,dsync seek=$((1000 * 1024**2))
echo "🔁 執行 partprobe 通知系統變更"
partprobe "$DISK"
echo "✅ 完成 $DISK"

echo "🧹 移除 Rook 目錄（如有）"
rm -rf /var/lib/rook

echo "🎉 所有磁碟清除完成於 $(hostname)"
'

# === 寫入暫存檔 ===
echo "$CLEAN_SCRIPT_CONTENT" > ./zap-disk.sh
chmod +x ./zap-disk.sh

# === 對每個節點進行操作 ===
for node in "${NODES[@]}"; do
  echo "➡ 傳送清理腳本到 $node..."
  scp ./zap-disk.sh "$node:$REMOTE_SCRIPT"

  echo "➡ 執行清理腳本於 $node..."
  ssh "$node" "sudo bash $REMOTE_SCRIPT"

  echo "✅ $node 處理完成"
  echo "---------------------------------------"
done

# 清理本機腳本檔
rm -f ./zap-disk.sh

