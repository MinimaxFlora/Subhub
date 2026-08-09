# Kejizero订阅转换

现代化订阅转换 Web 前端 + subconverter 后端 + 自建短链服务，基于 [cmliu/sub-web-modify](https://github.com/cmliu/sub-web-modify) 定制，
品牌为 **Kejizero订阅转换**，支持 **Docker / Docker Compose 一键部署**。

三个域名通过 `docker-compose.yml` 的 `environment` 传入，**不填默认本机地址（localhost）**，
填了真实域名则 Caddy 自动反代并签发 HTTPS 证书。

## 功能特性

- 🎨 现代化界面设计，亮色/暗色主题自动切换
- 📱 响应式设计，适配桌面端与移动端
- 🔗 多格式订阅转换：Clash、Surge、Sing-Box、V2Ray、Quantumult X、Loon 等
- 🛠 节点筛选（关键字/正则）、批量重命名、Emoji 前缀等高级选项
- 📦 内置大量远程配置模板（ACL4SSR 规则等）
- 🔗 自建短链服务（myurls 协议兼容，数据 SQLite 持久化）

## 项目结构

```
kejizero-sub-converter/
├── docker-compose.yml      # 一键编排：caddy + frontend + backend + shortlink
├── .env.example            # 环境变量模板（复制为 .env 修改）
├── .github/workflows/      # Docker Hub 镜像构建工作流
├── caddy/
│   └── Caddyfile           # Caddy 反代配置（域名由环境变量注入）
├── frontend/               # Vue 前端（基于 sub-web-modify 定制）
│   ├── Dockerfile          # 构建时通过 ARG 注入后端/短链域名
│   ├── nginx.conf          # SPA 部署配置（history 路由 + 缓存 + gzip）
│   ├── public/             # logo.png / favicon.ico（品牌图）
│   ├── src/views/Subconverter.vue   # 主页面
│   └── .env                # 构建环境变量（后端地址、链接等）
├── backend/                # subconverter 后端（内置源码，本地编译）
│   ├── Dockerfile          # 基于仓库内源码构建（无需拉取外部镜像）
│   ├── README.md
│   └── subconverter/       # subconverter v0.9.9 完整源码
└── shortlink/              # 自建短链服务（myurls 协议兼容）
    ├── Dockerfile
    └── server.py           # Python + SQLite，无第三方依赖
```

## 快速开始（Docker Compose 一键部署）

### 本机模式（不填域名，直接跑）

```bash
docker compose up -d --build
```

| 服务 | 地址 |
|---|---|
| 前端 | http://localhost |
| 后端 | http://localhost:25500 |
| 短链 | http://localhost:7999 |

### 公网模式（填三个域名，自动 HTTPS）

```bash
# 方式一：环境变量传入
export FRONTEND_DOMAIN=sub.example.com
export BACKEND_DOMAIN=api.example.com
export SHORTLINK_DOMAIN=short.example.com
export BACKEND_URL=https://api.example.com
export SHORTLINK_URL=https://short.example.com
docker compose up -d --build

# 方式二：复制 .env.example 为 .env 修改
cp .env.example .env
docker compose up -d --build
```

部署完成后 Caddy 自动为三个域名申请 HTTPS 证书，前端自动把默认后端指向
`https://BACKEND_DOMAIN`、默认短链指向 `https://SHORTLINK_DOMAIN`。

### 前提条件

- 公网模式：三个域名已添加 A 记录指向服务器公网 IP
- 服务器开放 80/443 端口
- 安装 Docker + Docker Compose

## 环境变量说明

| 变量 | 默认值 | 说明 |
|---|---|---|
| `FRONTEND_DOMAIN` | `localhost` | 前端域名 |
| `BACKEND_DOMAIN` | `localhost` | 后端（subconverter）域名 |
| `SHORTLINK_DOMAIN` | `localhost` | 短链域名 |
| `BACKEND_URL` | `http://localhost:25500` | 前端默认调用的后端完整地址 |
| `SHORTLINK_URL` | `http://localhost:7999` | 前端默认调用的短链完整地址 |
| `ACME_EMAIL` | `admin@kejizero.xyz` | Let's Encrypt 证书通知邮箱 |

## Docker Hub 镜像构建（GitHub Actions）

仓库内置工作流 `.github/workflows/docker-build.yml`，自动构建并推送三个镜像到 Docker Hub：

- `zhaoweiwen123/kejizero-frontend:{sha|latest}`
- `zhaoweiwen123/kejizero-backend:{sha|latest}`
- `zhaoweiwen123/kejizero-shortlink:{sha|latest}`

触发方式：
- **手动**：Actions → Build & Push Docker Images → Run workflow（可选填三个域名）
- **自动**：push master 分支（改动 frontend/backend/shortlink/compose 时）

> 需要先在仓库 Settings → Secrets and variables → Actions 配置
> `DOCKERHUB_USERNAME` 和 `DOCKERHUB_TOKEN`。

## 单独部署

### 仅后端（subconverter，源码编译）

```bash
docker build -t kejizero-backend ./backend
docker run -d --restart=always -p 25500:25500 kejizero-backend
```

### 仅前端（Cloudflare Pages / EdgeOne / Vercel）

构建前设置环境变量：

```ini
VUE_APP_SUBCONVERTER_DEFAULT_BACKEND=https://你的后端域名
VUE_APP_MYURLS_DEFAULT_BACKEND=https://你的短链域名
```

构建命令：`npm run build`（输出 `dist/`）

### 仅短链服务

```bash
docker build -t kejizero-shortlink ./shortlink
docker run -d --restart=always -p 7999:7999 \
  -e BASE_URL=https://你的短链域名 \
  -v shortlink_data:/data \
  kejizero-shortlink
```

## 自定义品牌

- `frontend/public/logo.png` — 页面头部 logo
- `frontend/public/favicon.ico` — 浏览器标签图标
- `frontend/.env` — 项目名、链接等构建变量
- `frontend/src/views/Subconverter.vue` — 页面文案（标题、描述等）

## 致谢

- [cmliu/sub-web-modify](https://github.com/cmliu/sub-web-modify) — 前端基础
- [CareyWang/sub-web](https://github.com/CareyWang/sub-web) — 原始项目
- [asdlokj1qpi233/subconverter](https://github.com/asdlokj1qpi233/subconverter) — 后端

## License

MIT
