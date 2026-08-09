#!/bin/sh
# Kejizero订阅转换 - 单容器启动脚本
#
# 两种模式：
#   1. 本机模式（默认，未填域名）: 直接端口访问
#        前端 http://本机IP:8080 | 后端 http://本机IP:25500 | 短链 http://本机IP:7999
#   2. 域名模式（设置了域名）: Caddy 反代 + HTTPS
#        https://FRONTEND_DOMAIN | https://BACKEND_DOMAIN | https://SHORTLINK_DOMAIN

# ---- 三个域名（默认本机模式）----
export FRONTEND_DOMAIN="${FRONTEND_DOMAIN:-localhost}"
export BACKEND_DOMAIN="${BACKEND_DOMAIN:-localhost}"
export SHORTLINK_DOMAIN="${SHORTLINK_DOMAIN:-localhost}"

# ---- TLS 证书邮箱 ----
export ACME_EMAIL="${ACME_EMAIL:-admin@kejizero.xyz}"

echo "[SubHub] 启动模式: $([ "$FRONTEND_DOMAIN" = "localhost" ] && echo 本机模式 || echo 域名模式)"

# ---- 生成 Caddyfile ----
if [ "$FRONTEND_DOMAIN" = "localhost" ]; then
    # 本机模式：Caddy 监听 8080 伺服前端静态文件
    # 后端(25500)/短链(7999) 由 docker-compose 直接映射端口，不经 Caddy
    cat > /etc/caddy/Caddyfile <<'EOF'
:8080 {
    root * /app/web
    file_server
    try_files {path} /index.html
    encode gzip
}
EOF
    echo "  前端: http://本机IP:8080"
    echo "  后端: http://本机IP:25500"
    echo "  短链: http://本机IP:7999"
else
    # 域名模式：Caddy 监听 80/443 反代三个域名
    cat > /etc/caddy/Caddyfile <<EOF
{$FRONTEND_DOMAIN} {
    root * /app/web
    file_server
    try_files {path} /index.html
    encode gzip
    tls {$ACME_EMAIL}
}

{$BACKEND_DOMAIN} {
    reverse_proxy 127.0.0.1:25500
    encode gzip
    tls {$ACME_EMAIL}
}

{$SHORTLINK_DOMAIN} {
    reverse_proxy 127.0.0.1:7999
    tls {$ACME_EMAIL}
}
EOF
    echo "  前端: https://$FRONTEND_DOMAIN"
    echo "  后端: https://$BACKEND_DOMAIN"
    echo "  短链: https://$SHORTLINK_DOMAIN"
fi

exec /usr/bin/supervisord -c /etc/supervisord.conf
