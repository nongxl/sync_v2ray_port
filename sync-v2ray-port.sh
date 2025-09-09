#!/bin/bash
set -e

# ========= 配置区 =========
REMOTE_USER="root"
REMOTE_HOST="xxx.xxx.xxx.xxx"
REMOTE_SSH_PORT=22
CONFIG_FILE="/etc/v2ray/config.json"
# =========================

# 获取远程端口。需要使用sed去除颜色代码
REMOTE_CMD="v2ray info | grep '端口' | awk -F'=' '{print \$2}' | tr -d ' ' | sed 's/\x1b\[[0-9;]*m//g'"
REMOTE_PORT_VALUE=$(ssh -p ${REMOTE_SSH_PORT} -o StrictHostKeyChecking=no ${REMOTE_USER}@${REMOTE_HOST} "${REMOTE_CMD}")


if [[ -z "$REMOTE_PORT_VALUE" ]]; then
  echo "❌ 获取远程端口失败"
  exit 1
fi

echo "✅ 远程服务器端口: $REMOTE_PORT_VALUE"

# 备份本地配置文件
cp "$CONFIG_FILE" "${CONFIG_FILE}.bak.$(date +%F-%H%M%S)"

# 修改本地 outbounds[0].settings.vnext[0].port
jq --arg port "$REMOTE_PORT_VALUE" '
  .outbounds[0].settings.vnext[0].port = ($port | tonumber)
' "$CONFIG_FILE" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"

echo "🔧 已更新本地 outbounds port 为: $REMOTE_PORT_VALUE"

# 重启本地 v2ray
systemctl restart v2ray
systemctl status v2ray --no-pager -l
