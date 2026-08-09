# ============================================================
# Kejizero订阅转换 - 单镜像全家桶
# 一个镜像包含: 前端(Vue) + 后端(subconverter) + 短链 + Caddy
# 镜像名: zhaoweiwen123/SubHub
# ============================================================

# ---------- 阶段1: 构建前端 ----------
FROM node:18-alpine AS web-build
WORKDIR /app/web
COPY frontend/ .

ARG VUE_APP_SUBCONVERTER_DEFAULT_BACKEND
ARG VUE_APP_MYURLS_DEFAULT_BACKEND
ENV VUE_APP_SUBCONVERTER_DEFAULT_BACKEND=$VUE_APP_SUBCONVERTER_DEFAULT_BACKEND
ENV VUE_APP_MYURLS_DEFAULT_BACKEND=$VUE_APP_MYURLS_DEFAULT_BACKEND

RUN yarn install && yarn build

# ---------- 阶段2: 编译 subconverter 后端 ----------
FROM alpine:3.16 AS sub-build
LABEL maintainer="MinimaxFlora"
ARG THREADS="4"

WORKDIR /
RUN set -xe && \
    apk add --no-cache --virtual .build-tools git g++ build-base linux-headers cmake python3 && \
    apk add --no-cache --virtual .build-deps curl-dev rapidjson-dev pcre2-dev yaml-cpp-dev && \
    git clone --no-checkout https://github.com/ftk/quickjspp.git && \
    cd quickjspp && \
    git fetch origin 0c00c48895919fc02da3f191a2da06addeb07f09 && \
    git checkout 0c00c48895919fc02da3f191a2da06addeb07f09 && \
    git submodule update --init && \
    cmake -DCMAKE_BUILD_TYPE=Release . && \
    make quickjs -j $THREADS && \
    install -d /usr/lib/quickjs/ && \
    install -m644 quickjs/libquickjs.a /usr/lib/quickjs/ && \
    install -d /usr/include/quickjs/ && \
    install -m644 quickjs/quickjs.h quickjs/quickjs-libc.h /usr/include/quickjs/ && \
    install -m644 quickjspp.hpp /usr/include && \
    cd .. && \
    git clone https://github.com/PerMalmberg/libcron --depth=1 && \
    cd libcron && \
    git submodule update --init && \
    cmake -DCMAKE_BUILD_TYPE=Release . && \
    make libcron -j $THREADS && \
    install -m644 libcron/out/Release/liblibcron.a /usr/lib/ && \
    install -d /usr/include/libcron/ && \
    install -m644 libcron/include/libcron/* /usr/include/libcron/ && \
    install -d /usr/include/date/ && \
    install -m644 libcron/externals/date/include/date/* /usr/include/date/ && \
    cd .. && \
    git clone https://github.com/ToruNiina/toml11 --branch="v4.3.0" --depth=1 && \
    cd toml11 && \
    cmake -DCMAKE_CXX_STANDARD=11 . && \
    make install -j $THREADS && \
    cd ..

# 使用仓库内本地源码编译
COPY backend/subconverter/ /subconverter
WORKDIR /subconverter
RUN python3 -m ensurepip && \
    python3 -m pip install gitpython && \
    python3 scripts/update_rules.py -c scripts/rules_config.conf && \
    cmake -DCMAKE_BUILD_TYPE=Release . && \
    make -j $THREADS

# ---------- 阶段3: 运行镜像 ----------
FROM alpine:3.16
LABEL maintainer="MinimaxFlora"

# 运行时依赖 + 进程管理
RUN apk add --no-cache pcre2 libcurl yaml-cpp python3 py3-supervisor

# Caddy（从官方镜像复制二进制）
COPY --from=caddy:2-alpine /usr/bin/caddy /usr/bin/caddy

# 前端产物
COPY --from=web-build /app/web/dist /app/web

# subconverter 后端
COPY --from=sub-build /subconverter/subconverter /usr/bin/
COPY --from=sub-build /subconverter/base /base/

# 短链服务
COPY shortlink/server.py /app/shortlink/server.py

# Caddy 配置 + 进程管理 + 启动脚本
COPY Caddyfile /etc/caddy/Caddyfile
COPY supervisord.conf /etc/supervisord.conf
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# 数据卷（短链 SQLite）
VOLUME /data

ENV TZ=Asia/Shanghai
RUN ln -sf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

EXPOSE 80/tcp 443/tcp

ENTRYPOINT ["/entrypoint.sh"]
