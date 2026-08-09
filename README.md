# Kejizero订阅转换 (SubHub)

现代化订阅转换全家桶，**单镜像一键部署**：前端 + 后端 + 短链 + Caddy 网关全部装在一个镜像里。
基于 [cmliu/sub-web-modify](https://github.com/cmliu/sub-web-modify) 定制，品牌为 **Kejizero订阅转换**。

**两种运行模式：**
- **本机模式**（默认，不填域名）：IP+端口直连，开箱即用
- **域名模式**（填了三个域名）：Caddy 自动反代 + HTTPS 证书

## 功能特性

- 🎨 现代化界面设计，亮色/暗色主题自动切换
- 📱 响应式设计，适配桌面端与移动端
- 🔗 多格式订阅转换：Clash、Surge、Sing-Box、V2Ray、Quantumult X、Loon 等
- 🛠 节点筛选（关键字/正则）、批量重命名、Emoji 前缀等高级选项
- 📦 内置大量远程配置模板（ACL4SSR 规则等）
- 🔗 自建短链服务（myurls 协议兼容，数据 SQLite 持久化）
- 🐳 单镜像：`zhaoweiwen123/subhub`，一个容器跑全部服务

---

## 一、Docker Compose 部署（推荐）

### 方式 1：本机模式（不填域名，IP+端口访问）

创建 `docker-compose.yml`：

```yaml
services:
  subhub:
    image: zhaoweiwen123/subhub:latest
    container_name: kejizero-subhub
    restart: always
    ports:
      - "8080:8080"      # 前端
      - "25500:25500"    # 后端 subconverter
      - "7999:7999"      # 短链
    environment:
      # 三个域名（不填 = 本机模式，填了 = 域名模式）
      FRONTEND_DOMAIN: ${FRONTEND_DOMAIN:-}
      BACKEND_DOMAIN: ${BACKEND_DOMAIN:-}
      SHORTLINK_DOMAIN: ${SHORTLINK_DOMAIN:-}
      # 前端默认调用的后端/短链完整地址（可选，不填自动推导）
      BACKEND_URL: ${BACKEND_URL:-}
      SHORTLINK_URL: ${SHORTLINK_URL:-}
      # TLS 证书邮箱（域名模式用）
      ACME_EMAIL: ${ACME_EMAIL:-admin@kejizero.xyz}
    volumes:
      - subhub_data:/data   # 短链 SQLite 数据持久化

volumes:
  subhub_data:
```

启动：

```bash
docker compose up -d
```

访问：

| 服务 | 地址 |
|---|---|
| 前端 | http://本机IP:8080 |
| 后端 | http://本机IP:25500 |
| 短链 | http://本机IP:7999 |

### 方式 2：域名模式（填三个域名，自动 HTTPS）

创建 `.env`（与 docker-compose.yml 同目录）：

```ini
# 三个域名（需已解析 A 记录到服务器）
FRONTEND_DOMAIN=sub.example.com
BACKEND_DOMAIN=api.example.com
SHORTLINK_DOMAIN=short.example.com

# 前端默认调用的后端/短链完整地址（不填自动推导为 https://对应域名）
BACKEND_URL=https://api.example.com
SHORTLINK_URL=https://short.example.com

# TLS 证书邮箱（可选）
ACME_EMAIL=admin@example.com
```

然后：

```bash
docker compose up -d
```

访问：

| 服务 | 地址 |
|---|---|
| 前端 | https://FRONTEND_DOMAIN |
| 后端 | https://BACKEND_DOMAIN |
| 短链 | https://SHORTLINK_DOMAIN |

> 镜像内 Caddy 自动为三个域名申请/续期 Let's Encrypt 证书并反代。

---

## 二、Docker 部署（不用 Compose）

### 方式 1：本机模式（IP+端口访问）

```bash
docker run -d --name kejizero-subhub \
  --restart=always \
  -p 8080:8080 \
  -p 25500:25500 \
  -p 7999:7999 \
  -v subhub_data:/data \
  zhaoweiwen123/subhub:latest
```

访问：

| 服务 | 地址 |
|---|---|
| 前端 | http://本机IP:8080 |
| 后端 | http://本机IP:25500 |
| 短链 | http://本机IP:7999 |

### 方式 2：域名模式（填三个域名，自动 HTTPS）

```bash
docker run -d --name kejizero-subhub \
  --restart=always \
  -p 80:80 \
  -p 443:443 \
  -e FRONTEND_DOMAIN=sub.example.com \
  -e BACKEND_DOMAIN=api.example.com \
  -e SHORTLINK_DOMAIN=short.example.com \
  -e BACKEND_URL=https://api.example.com \
  -e SHORTLINK_URL=https://short.example.com \
  -e ACME_EMAIL=admin@example.com \
  -v subhub_data:/data \
  zhaoweiwen123/subhub:latest
```

访问：

| 服务 | 地址 |
|---|---|
| 前端 | https://sub.example.com |
| 后端 | https://api.example.com |
| 短链 | https://short.example.com |

---

## 三、常用命令

```bash
# 查看日志
docker logs -f kejizero-subhub

# 重启
docker compose restart

# 更新镜像
docker pull zhaoweiwen123/subhub:latest
docker compose up -d

# 停止并删除
docker compose down
```

---

## 四、环境变量说明

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

---

## 五、Docker Hub 镜像

- 镜像名：`zhaoweiwen123/subhub`
- 标签：`latest`
- 构建：GitHub Actions 手动触发（仓库 Actions → Build & Push Docker Image → Run workflow）

## 六、自定义品牌

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
