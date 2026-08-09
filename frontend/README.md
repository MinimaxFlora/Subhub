# Kejizero订阅转换 前端

基于 [cmliu/sub-web-modify](https://github.com/cmliu/sub-web-modify)（Vue 2 + Element UI）定制的订阅转换前端，
品牌已更换为 **Kejizero订阅转换**。

## 环境变量（.env）

| 变量 | 说明 |
|---|---|
| `VUE_APP_PROJECT` | 项目仓库地址（GitHub 图标链接） |
| `VUE_APP_SUBCONVERTER_DEFAULT_BACKEND` | 默认 subconverter 后端地址 |
| `VUE_APP_MYURLS_DEFAULT_BACKEND` | 短链接服务 |
| `VUE_APP_CONFIG_UPLOAD_BACKEND` | 配置上传服务 |
| `VUE_APP_BOT_LINK` / `VUE_APP_YOUTUBE_LINK` / `VUE_APP_BILIBILI_LINK` | 社交链接（留空自动隐藏按钮） |

## 本地开发

```bash
npm install
npm run serve   # http://localhost:8080
```

## 构建

```bash
npm run build   # 输出 dist/
```

## 自定义品牌

- `public/logo.png` — 页面头部 logo
- `public/favicon.ico` — 浏览器标签图标
- `src/views/Subconverter.vue` — 页面标题、描述、后端选项列表

## License

MIT
