# Kejizero订阅转换 (SubHub)

现代化订阅转换全家桶，**单镜像一键部署**：前端 + 后端 + 短链 + Caddy 网关全部装在一个镜像里。
基于 [cmliu/sub-web-modify](https://github.com/cmliu/sub-web-modify) 定制，品牌为 **Kejizero订阅转换**。

三个域名通过 `environment` 传入，**不填默认本机地址（localhost）**，填了真实域名则 Caddy 自动反代并签发 HTTPS 证书。

## 功能特性

- 🎨 现代化界面设计，亮色/暗色主题自动切换
- 📱 响应式设计，适配桌面端与移动端
- 🔗 多格式订阅转换：Clash、Surge、Sing-Box、V2Ray、Quantumult X、Loon 等
- 🛠 节点筛选（关键字/正则）、批量重命名、Emoji 前缀等高级选项
- 📦 内置大量远程配置模板（ACL4SSR 规则等）
- 🔗 自建短链服务（myurls 协议兼容，数据 SQLite 持久化）
- 🐳 单镜像：`zhaoweiwen123/subhub`，一个容器跑全部服务

## 项目结构

```
kejizero-sub-converter/
├── Dockerfile              # 单镜像多阶段构建（前端构建 + 后端编译 + 运行镜像）
├── Caddyfile               # Caddy 网关配置（伺服前端静态文件 + 反代后端/短链）
├── entrypoint.sh           # 启动脚本（设置默认环境变量，交给 supervisord）
├── supervisord.conf        # 进程管理（subconverter + shortlink + caddy）
├── docker-compose.yml      # 一键部署（单服务）
├── .env.example            # 环境变量模板（复制为 .env 修改）
├── .dockerignore
├── .github/workflows/      # Docker Hub 镜像构建工作流
├── frontend/               # Vue 前端（基于 sub-web-modify 定制）
│   ├── public/             # logo.png / favicon.ico（品牌图）
│   ├── src/views/Subconverter.vue   # 主页面
│   └── .env                # 构建环境变量（后端地址、链接等）
├── backend/                # subconverter 后端（内置源码，本地编译）
│   ├── Dockerfile          # 独立构建（可选）
│   ├── README.md
│   └── subconverter/       # subconverter v0.9.9 完整源码
└── shortlink/              # 自建短链服务（myurls 协议兼容）
    ├── Dockerfile          # 独立构建（可选）
    └── server.py           # Python + SQLite，无第三方依赖
```

## 快速开始

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
docker compose up -d --build

# 方式二：复制 .env.example 为 .env 修改
cp .env.example .env
docker compose up -d --build
```

Caddy 自动为三个域名申请 HTTPS 证书；前端自动把默认后端指向 `https://BACKEND_DOMAIN`、默认短链指向 `https://SHORTLINK_DOMAIN`。

### 前提条件

- 公网模式：三个域名已添加 A 记录指向服务器公网 IP
- 服务器开放 80/443 端口
- 安装 Docker + Docker Compose

## 环境变量说明

| 变量 | 默认值 | 说明 |
|---|---|---|
| `FRONTEND_DOMAIN` | `localhost` | 前端域名（伺服 Vue 静态页面） |
| `BACKEND_DOMAIN` | `localhost` | 后端（subconverter）域名 |
| `SHORTLINK_DOMAIN` | `localhost` | 短链域名 |
| `BACKEND_URL` | 自动推导 | 前端默认调用的后端完整地址（域名非 localhost 时 = https://域名） |
| `SHORTLINK_URL` | 自动推导 | 前端默认调用的短链完整地址 |
| `ACME_EMAIL` | `admin@kejizero.xyz` | Let's Encrypt 证书通知邮箱 |

> 单容器架构：Caddy 一个进程伺服前端静态文件 + 反代后端(25500) + 反代短链(7999)，
> subconverter 与短链服务由 supervisord 管理，`/data` 卷持久化短链数据。

## Docker Hub 镜像（GitHub Actions 自动构建）

工作流 `.github/workflows/docker-build.yml` 构建并推送单镜像：

- `zhaoweiwen123/subhub:{commit-sha}`
- `zhaoweiwen123/subhub:latest`

触发方式：
- **手动**：Actions → Build & Push Docker Image → Run workflow（可选填三个域名）
- **自动**：push master 分支（改动 frontend/backend/shortlink/Dockerfile/Caddyfile 等时）

> 需在仓库 Settings → Secrets and variables → Actions 配置
> `DOCKERHUB_USERNAME` 和 `DOCKERHUB_TOKEN`。

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
