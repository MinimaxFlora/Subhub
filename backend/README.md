# subconverter 后端

后端使用 [asdlokj1qpi233/subconverter](https://github.com/asdlokj1qpi233/subconverter)（tindy2013/subconverter 增强分支），
支持 Clash / Surge / Sing-Box / V2Ray / Quantumult X 等全格式转换。

## 集成方式

推荐使用根目录 `docker-compose.yml` 一键部署（含 Caddy 反代 + HTTPS + 前端 + 短链）。
本目录的 Dockerfile 用于构建后端镜像：

```bash
docker build -t kejizero-backend .
docker run -d --restart=always --name kejizero-backend \
  -p 25500:25500 kejizero-backend

# 验证
curl http://localhost:25500/version
# 输出 subconverter vX.X.X backend 即成功
```

## 自定义 pref 配置

镜像基于官方镜像构建，容器内 `/base/` 目录结构对应仓库 `base/` 文件夹。
如需自定义，将文件放到 `replacements/` 并取消 Dockerfile 中的 COPY 注释：

```dockerfile
FROM asdlokj1qpi23/subconverter:latest
COPY replacements/ /base/
EXPOSE 25500
```

或在线更新（需在 pref.ini 中设置 api_access_token）：

```bash
curl -F "data=@newpref.ini" "http://localhost:25500/updateconf?type=form&token=***"
```

## 安全建议

- 修改 `base/pref.ini` 中的 `api_access_token`，避免配置被篡改
- 公网部署建议通过 Caddy/nginx 反代并开启 HTTPS（根目录 compose 已内置）
- 如需限流/防滥用，可在反代层配置速率限制
