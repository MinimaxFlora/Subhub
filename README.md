# Kejizero订阅转换

现代化订阅转换 Web 前端 + subconverter 后端，基于 [cmliu/sub-web-modify](https://github.com/cmliu/sub-web-modify) 定制：
更换品牌为 **Kejizero订阅转换**（全新 logo），界面与功能保持原版一致。

## 功能特性

- 🎨 现代化界面设计，亮色/暗色主题自动切换
- 📱 响应式设计，适配桌面端与移动端
- 🔗 多格式订阅转换：Clash、Surge、Sing-Box、V2Ray、Quantumult X、Loon 等
- 🛠 节点筛选（关键字/正则）、批量重命名、Emoji 前缀等高级选项
- 📦 内置大量远程配置模板（ACL4SSR 规则等）
- 🔗 短链接生成、配置上传/解析

## 项目结构

```
kejizero-sub-converter/
├── frontend/          # Vue 前端（基于 sub-web-modify 定制）
│   ├── public/        # logo.png / favicon.ico（品牌图）
│   ├── src/views/Subconverter.vue  # 主页面
│   └── .env           # 构建环境变量（后端地址、链接等）
├── backend/           # subconverter 后端部署
│   ├── README.md
│   └── docker-compose.yml
└── docker-compose.yml # 前后端一键部署
```

## 快速开始（Docker 一键）

```bash
docker compose up -d --build
# 前端: http://localhost:8080
# 后端: http://localhost:25500
```

## 单独部署

### 后端（subconverter）

详见 [backend/README.md](backend/README.md)，或直接：

```bash
docker run -d --restart=always -p 25500:25500 asdlokj1qpi23/subconverter:latest
```

### 前端（Cloudflare Pages / EdgeOne Pages / Vercel / Docker）

1. Fork/上传本仓库
2. 修改 `frontend/.env`：

```ini
# 默认后端地址（改成你部署的 subconverter 地址）
VUE_APP_SUBCONVERTER_DEFAULT_BACKEND=https://your-backend.example.com
```

3. 构建配置：
   - 框架预设：Vue
   - 构建命令：`npm run build`（或 `yarn build`）
   - 输出目录：`dist`
4. 部署完成

> 注意：前端默认 `VUE_APP_SUBCONVERTER_DEFAULT_BACKEND` 为 `http://localhost:25500`，
> 生产环境务必改为你的实际后端域名（后端需支持 CORS，subconverter 默认已开启）。

## 自定义品牌

- `frontend/public/logo.png` — 页面头部 logo
- `frontend/public/favicon.ico` — 浏览器标签图标
- `frontend/.env` — 项目名、链接、后端地址等
- `frontend/src/views/Subconverter.vue` — 页面文案（标题、描述等）

## 致谢

- [cmliu/sub-web-modify](https://github.com/cmliu/sub-web-modify) — 前端基础
- [CareyWang/sub-web](https://github.com/CareyWang/sub-web) — 原始项目
- [asdlokj1qpi233/subconverter](https://github.com/asdlokj1qpi233/subconverter) — 后端

## License

MIT
