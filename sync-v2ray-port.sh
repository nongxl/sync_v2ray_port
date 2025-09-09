#!/bin/bash
set -e

# ========= 配置区 =========
REMOTE_USER="root"
REMOTE_HOST="xxx.xxx.xxx.xxx"
CONFIG_FILE="/etc/v2ray/config.json"
# =========================

# 获取远程端口
REMOTE_CMD="v2ray info | grep '端口' | awk -F'=' '{print \$2}' | tr -d ' '"
REMOTE_PORT_VALUE=$(ssh -p ${REMOTE_PORT} -o StrictHostKeyChecking=no ${REMOTE_USER}@${REMOTE_HOST} "${REMOTE_CMD}")

if [[ -z "$REMOTE_PORT_VALUE" ]]; then
  echo "❌ 获取远程端口失败"
  exit 1
fi

echo "✅ 远程服务器端口: $REMOTE_PORT_VALUE"

# 备份本地配置文件
#cp "$CONFIG_FILE" "${CONFIG_FILE}.bak.$(date +%F-%H%M%S)"

# 修改本地配置文件中的端口
sed -i -E "s/\"port\"\s*:\s*[0-9]+/\"port\": ${REMOTE_PORT_VALUE}/" "$CONFIG_FILE"

echo "🔧 已更新本地 v2ray 配置端口为: $REMOTE_PORT_VALUE"

# 重启本地 v2ray
systemctl restart v2ray
systemctl status v2ray --no-pager -l
