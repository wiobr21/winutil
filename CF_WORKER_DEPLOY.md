# Cloudflare Worker 本地部署说明（WinUtil）

本说明用于将本地 `worker.js` 部署到 Cloudflare Workers，并确保 `irm` 命令可用。

## 1. 准备

- 已安装 Node.js 18+（推荐 LTS）
- 已安装 `npm`（随 Node.js 一起安装）
- 已有 Cloudflare 账号并可创建 Worker

## 2. 目录结构

部署文件为：

- `worker.js`
- `winutil.ps1`（已编译的中文版本，上传到 GitHub 后由 Worker 代理）

## 3. 安装 Wrangler

在当前目录执行：

```powershell
npm install -g wrangler
```

## 4. 登录 Cloudflare

```powershell
wrangler login
```

执行后会打开浏览器进行授权。

## 5. 初始化项目（只需一次）

如果当前目录没有 `wrangler.toml`，执行：

```powershell
wrangler init
```

选择：

- “No” (不创建示例 Worker)
- “Yes” (生成 `wrangler.toml`)

生成后，请确认 `wrangler.toml` 中的入口指向 `worker.js`。

示例：

```toml
name = "winutil-worker"
main = "worker.js"
compatibility_date = "2026-03-27"
```

## 6. 本地预览

```powershell
wrangler dev
```

本地访问：

- `http://localhost:8787`（浏览器：显示中文落地页）
- `irm http://localhost:8787 | iex`（PowerShell 启动测试）

## 7. 部署到云端

```powershell
wrangler deploy
```

部署成功后，Wrangler 会输出 Worker 访问地址。

## 8. 验证

浏览器访问：

```
https://你的worker域名
```

命令行启动：

```powershell
irm https://你的worker域名 | iex
```

备用：

```powershell
irm https://你的worker域名/winutil.ps1 | iex
```

## 9. 常见问题

### 9.1 访问是英文或乱码

- 确认 `worker.js` 中的 HTML 已是中文
- 确认浏览器不是强制翻译扩展导致

### 9.2 `irm` 无法执行

- 确认 PowerShell 允许执行脚本
- 以管理员权限运行 PowerShell
- 先运行：

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

### 9.3 `winutil.ps1` 无法下载

- 确认 `RAW_PS1_URL` 指向你的 GitHub 原始地址
- `winutil.ps1` 文件已推送到 GitHub

## 10. 更新流程

1. 修改并重新编译 `winutil.ps1`
2. 推送到 GitHub
3. Worker 无需修改，访问即生效

---

如需自定义页面文案或主题风格，请直接修改 `worker.js` 中的 HTML/CSS 部分。
