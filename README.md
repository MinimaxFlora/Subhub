# Kejizero订阅转换

现代化订阅转换 Web 前端 + subconverter 后端 + 自建短链服务，基于 [cmliu/sub-web-modify](https://github.com/cmliu/sub-web-modify) 定制，
品牌为 **Kejizero订阅转换**，支持 **Docker / Docker Compose 一键部署**：只需设置三个域名环境变量，
Caddy 自动反代并签发 HTTPS 证书。

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
├── caddy/
│   └── Caddyfile           # Caddy 反代配置（{$域名} 由环境变量注入）
├── frontend/               # Vue 前端（基于 sub-web-modify 定制）
│   ├── Dockerfile          # 构建时通过 ARG 注入后端/短链域名
│   ├── nginx.conf          # SPA 部署配置（history 路由 + 缓存 + gzip）
│   ├── public/             # logo.png / favicon.ico（品牌图）
│   ├── src/views/Subconverter.vue   # 主页面
│   └── .env                # 构建环境变量（后端地址、链接等）
├── backend/                # subconverter 后端
│   ├── Dockerfile          # 基于 asdlokj1qpi23/subconverter 官方镜像
│   └── README.md
└── shortlink/              # 自建短链服务（myurls 协议兼容）
    ├── Dockerfile
    └── server.py           # Python + SQLite，无第三方依赖
```

## 快速开始（Docker Compose 一键部署）

```bash
# 1. 克隆/上传本仓库后：
cp .env.example .env

# 2. 编辑 .env，只改三个域名（必须先解析 A 记录到本机）：
#    FRONTEND_DOMAIN=sub.你的域名.com
#    BACKEND_DOMAIN=api.你的域名.com
#    SHORTLINK_DOMAIN=short.你的域名.com

# 3. 一键构建启动
docker compose up -d --build

# 4. 完成！Caddy 自动为三个域名申请 HTTPS 证书
```

部署完成后：
| 服务 | 域名 | 说明 |
|---|---|---|
| 前端 | `https://FRONTEND_DOMAIN` | Kejizero订阅转换 页面 |
| 后端 | `https://BACKEND_DOMAIN` | subconverter API |
| 短链 | `https://SHORTLINK_DOMAIN` | 短链生成服务 |

前端会自动把默认后端指向 `https://BACKEND_DOMAIN`、默认短链指向 `https://SHORTLINK_DOMAIN`。

### 前提条件

- 三个域名已添加 A 记录指向服务器公网 IP
- 服务器开放 80/443 端口
- 安装 Docker + Docker Compose

## 单独部署

### 仅后端（subconverter）

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

## 环境变量说明

| 变量 | 必填 | 说明 |
|---|---|---|
| `FRONTEND_DOMAIN` | ✅ | 前端域名 |
| `BACKEND_DOMAIN` | ✅ | 后端（subconverter）域名 |
| `SHORTLINK_DOMAIN` | ✅ | 短链域名 |
| `ACME_EMAIL` | 可选 | Let's Encrypt 证书通知邮箱（默认 admin@kejizero.xyz） |

## 致谢

- [cmliu/sub-web-modify](https://github.com/cmliu/sub-web-modify) — 前端基础
- [CareyWang/sub-web](https://github.com/CareyWang/sub-web) — 原始项目
- [asdlokj1qpi233/subconverter](https://github.com/asdlokj1qpi233/subconverter) — 后端

## License

MIT
