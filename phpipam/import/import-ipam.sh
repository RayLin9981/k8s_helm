#!/bin/bash

# 修改為你的實際 API 路徑與 Token
IPAM_API_URL="https://phpipam.fck8slab.local/api"
APP_ID="import-json"  # 這是在 phpIPAM 中定義的 API APP name
TOKEN="VlUa5y6TWQgmOv0xrgSeqltoggleuOsU"
SUBNET_ID="7"   # 目標子網的 ID（請依照實際 phpIPAM 設定）

# IP 清單 JSON 檔案
IP_LIST="ip-list.json"

# 匯入函數
import_ip() {
  local ip="$1"
  local hostname="$2"
  local desc="$3"

  curl -s -X POST "$IPAM_API_URL/$APP_ID/addresses/" \
    -H "Content-Type: application/json" \
    -H "token: $TOKEN" \
    -d @- <<EOF
{
  "subnetId": $SUBNET_ID,
  "ip": "$ip",
  "hostname": "$hostname",
  "description": "$desc",
  "owner": "auto-import"
}
EOF
}

# 循環處理所有 IP 項目
jq -c '.[]' "$IP_LIST" | while read -r item; do
  ip=$(echo "$item" | jq -r '.ip')
  hostname=$(echo "$item" | jq -r '.hostname')
  description=$(echo "$item" | jq -r '.description')
  echo "⏳ 匯入 $ip ($hostname): $description"
  import_ip "$ip" "$hostname" "$description"
done

