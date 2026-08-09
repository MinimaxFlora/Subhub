# subconverter 后端部署

后端使用 [asdlokj1qpi233/subconverter](https://github.com/asdlokj1qpi233/subconverter)（tindy2013/subconverter 增强分支），
支持 Clash / Surge / Sing-Box / V2Ray / Quantumult X 等全格式转换。

## 方式一：Docker 一键部署（推荐）

```bash
docker run -d --restart=always --name subconverter \
  -p 25500:25500 asdlokj1qpi23/subconverter:latest

# 验证
curl http://localhost:25500/version
# 输出 subconverter vX.X.X backend 即成功
```

## 方式二：docker-compose

```bash
docker compose up -d
```

## 方式三：本地编译（Dockerfile.local）

```bash
docker build -f Dockerfile.local -t subconverter-local .
docker run -d --restart=always -p 25500:25500 subconverter-local
```

## 自定义 pref 配置

容器内 `/base/` 目录结构对应仓库 `base/` 文件夹：

```bash
# 在线更新配置（需在 pref.ini 中设置 api_access_token）
curl -F "data=@newpref.ini" "http://localhost:25500/updateconf?type=form&token=password"

# 或构建自定义镜像
FROM asdlokj1qpi23/subconverter:latest
COPY replacements/ /base/
EXPOSE 25500
```

## 安全建议

- 修改 `base/pref.ini` 中的 `api_access_token`，避免配置被他人篡改
- 公网部署建议套一层反代（Caddy/nginx）并开启 HTTPS
- 如需限流/防滥用，可在反代层配置速率限制
