#!/bin/sh
# Kejizero订阅转换 - 单容器启动脚本
# 设置默认环境变量（不填则本机地址），然后交给 supervisord 管理所有进程

# ---- 三个域名（默认本机 localhost）----
export FRONTEND_DOMAIN="${FRONTEND_DOMAIN:-localhost}"
export BACKEND_DOMAIN="${BACKEND_DOMAIN:-localhost}"
export SHORTLINK_DOMAIN="${SHORTLINK_DOMAIN:-localhost}"

# ---- 前端调用的后端/短链完整地址 ----
# 填了域名 -> https://域名；否则本机 http 端口
if [ "$BACKEND_DOMAIN" != "localhost" ]; then
    export BACKEND_URL="${BACKEND_URL:-https://$BACKEND_DOMAIN}"
else
    export BACKEND_URL="${BACKEND_URL:-http://localhost:25500}"
fi

if [ "$SHORTLINK_DOMAIN" != "localhost" ]; then
    export SHORTLINK_URL="${SHORTLINK_URL:-https://$SHORTLINK_DOMAIN}"
else
    export SHORTLINK_URL="${SHORTLINK_URL:-http://localhost:7999}"
fi

# ---- TLS 证书邮箱 ----
export ACME_EMAIL="${ACME_EMAIL:-admin@kejizero.xyz}"

echo "[SubHub] 启动配置:"
echo "  前端域名: $FRONTEND_DOMAIN"
echo "  后端域名: $BACKEND_DOMAIN"
echo "  短链域名: $SHORTLINK_DOMAIN"
echo "  前端默认后端: $BACKEND_URL"
echo "  前端默认短链: $SHORTLINK_URL"

exec /usr/bin/supervisord -c /etc/supervisord.conf
