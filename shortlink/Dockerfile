# Kejizero 短链服务
# 兼容 myurls 协议：POST /short (longUrl=base64) -> {"Code":1,"ShortUrl":...}
# 域名由环境变量 BASE_URL 注入（docker-compose 传参）
FROM python:3.11-alpine

WORKDIR /app
COPY server.py /app/server.py

ENV DB_PATH=/data/urls.db
ENV BASE_URL=https://short.example.com
ENV HTTP_PORT=7999

VOLUME /data
EXPOSE 7999/tcp

CMD ["python3", "/app/server.py"]
