# Kejizero订阅转换 (SubHub)

现代化订阅转换全家桶，**单镜像一键部署**：前端 + 后端 + 短链 + Caddy 网关全部装在一个镜像里。
基于 [cmliu/sub-web-modify](https://github.com/cmliu/sub-web-modify) 定制，品牌为 **Kejizero订阅转换**。

**两种运行模式：**
- **本机模式**（默认，不填域名）：端口直连，开箱即用
- **域名模式**（填了三个域名）：Caddy 自动反代 + HTTPS 证书

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
├── entrypoint.sh           # 启动脚本（双模式：本机端口直连 / 域名反代）
├── supervisord.conf        # 进程管理（subconverter + shortlink + caddy）
├── docker-compose.yml      # 一键部署（单服务）
├── .env.example            # 环境变量模板（复制为 .env 修改）
├── .dockerignore
├── .github/workflows/      # Docker Hub 镜像构建工作流（手动触发）
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

### 模式一：本机模式（默认，不填域名）

```bash
docker compose up -d --build
```

| 服务 | 地址 |
|---|---|
| 前端 | http://本机IP:8080 |
| 后端 | http://本机IP:25500 |
| 短链 | http://本机IP:7999 |

### 模式二：域名模式（填三个域名，自动 HTTPS）

```bash
# 复制 .env.example 为 .env 修改
cp .env.example .env
```

`.env` 里填写（需已解析 A 记录到服务器）：
```ini
FRONTEND_DOMAIN=sub.example.com
BACKEND_DOMAIN=api.example.com
SHORTLINK_DOMAIN=short.example.com
```

```bash
docker compose up -d --build
```

| 服务 | 地址 |
|---|---|
| 前端 | https://FRONTEND_DOMAIN |
| 后端 | https://BACKEND_DOMAIN |
| 短链 | https://SHORTLINK_DOMAIN |

### 前提条件

- 域名模式：三个域名已添加 A 记录指向服务器公网 IP，开放 80/443
- 本机模式：开放 8080/25500/7999 端口
- 安装 Docker + Docker Compose

## 环境变量说明

| 变量 | 默认值 | 说明 |
|---|---|---|
| `FRONTEND_DOMAIN` | 空（本机模式） | 前端域名，填了即启用域名模式 |
| `BACKEND_DOMAIN` | 空（本机模式） | 后端（subconverter）域名 |
| `SHORTLINK_DOMAIN` | 空（本机模式） | 短链域名 |
| `BACKEND_URL` | 自动推导 | 前端默认调用的后端完整地址（域名模式=https://域名，本机=http://localhost:25500） |
| `SHORTLINK_URL` | 自动推导 | 前端默认调用的短链完整地址 |
| `ACME_EMAIL` | `admin@kejizero.xyz` | Let's Encrypt 证书通知邮箱（域名模式用） |

> 单容器架构：Caddy 一个进程伺服前端静态文件 + 反代后端(25500) + 反代短链(7999)，
> subconverter 与短链服务由 supervisord 管理，`/data` 卷持久化短链数据。
> 本机模式下 Caddy 监听 8080 伺服前端，后端/短链端口直接映射到宿主机。

## Docker Hub 镜像（手动触发构建）

工作流 `.github/workflows/docker-build.yml` 构建并推送单镜像 `zhaoweiwen123/subhub:latest`。

**触发方式**：GitHub Actions → Build & Push Docker Image → **Run workflow**（手动触发，不自动构建）

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
