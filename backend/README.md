# subconverter 后端

后端使用 [asdlokj1qpi233/subconverter](https://github.com/asdlokj1qpi233/subconverter)（tindy2013/subconverter 增强分支）v0.9.9，
支持 Clash / Surge / Sing-Box / V2Ray / Quantumult X 等全格式转换。

## 源码本地构建（本项目默认方式）

源码已内置在本目录 `subconverter/`（无需拉取外部镜像），构建时自动编译：

```bash
# 方式一：随根目录 compose 一键构建
cd .. && docker compose up -d --build

# 方式二：单独构建后端
docker build -t kejizero-backend ./backend
docker run -d --restart=always --name kejizero-backend \
  -p 25500:25500 kejizero-backend

# 验证
curl http://localhost:25500/version
# 输出 subconverter vX.X.X backend 即成功
```

> 说明：构建时会编译 quickjspp/libcron/toml11 等依赖（官方 Dockerfile.local 同款流程），
> 首次构建约 5-15 分钟，之后有构建缓存。

## 目录结构

```
backend/
├── Dockerfile            # 本地源码构建（alpine 3.16）
├── docker-compose.yml    # 单独部署后端（可选）
├── README.md
└── subconverter/         # subconverter 完整源码（base/src/scripts 等）
    ├── base/             # pref 配置、规则、snippets（可自定义）
    ├── src/              # C++ 源码
    └── scripts/          # 规则更新脚本
```

## 自定义 pref 配置

容器内 `/base/` 对应 `subconverter/base/`，直接改仓库里的文件即可：

- `subconverter/base/pref.ini` — 主配置（改 `api_access_token`！）
- `subconverter/base/rules/` — 规则文件
- `subconverter/base/snippets/` — 片段

改完重新 `docker compose build backend`。

## 安全建议

- 修改 `subconverter/base/pref.ini` 中的 `api_access_token`，避免配置被篡改
- 公网部署通过 Caddy 反代 + HTTPS（根目录 compose 已内置）
- 如需限流/防滥用，可在反代层配置速率限制
