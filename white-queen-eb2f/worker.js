/**
 * Cloudflare Worker for WinUtil
 * - Browser访问根路径返回中文介绍页
 * - PowerShell/脚本访问返回启动脚本
 * - /winutil.ps1 代理 GitHub 原始脚本
 */

const RAW_PS1_URL = 'https://raw.githubusercontent.com/wiobr21/winutil/main/winutil.ps1';

function isBrowser(request) {
  const accept = request.headers.get('accept') || '';
  const ua = request.headers.get('user-agent') || '';
  const isCli = /PowerShell|curl|Wget|wget|HTTPie|WinHTTP|aria2|OpenAI|okhttp/i.test(ua);
  return accept.includes('text/html') && !isCli;
}

function htmlPage(origin) {
  const cmd = `irm ${origin} | iex`;
  const alt = `irm ${origin}/winutil.ps1 | iex`;

  return `<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>WinUtil 中文一键入口</title>
  <style>
    :root {
      --bg: #0b0f1a;
      --panel: rgba(20, 26, 40, 0.88);
      --ink: #eaf2ff;
      --muted: #9aa6bf;
      --accent: #5ee7ff;
      --accent-2: #ff7ad9;
      --accent-3: #ffd479;
      --ring: rgba(94, 231, 255, 0.35);
      --grid: rgba(255, 255, 255, 0.04);
    }

    * { box-sizing: border-box; }
    body {
      margin: 0;
      font-family: "Microsoft YaHei UI", "Noto Sans SC", "PingFang SC", "Hiragino Sans GB", "Source Han Sans SC", sans-serif;
      color: var(--ink);
      background:
        radial-gradient(1200px 600px at 80% -10%, rgba(94,231,255,0.18), transparent 60%),
        radial-gradient(900px 500px at -10% 10%, rgba(255,122,217,0.16), transparent 55%),
        var(--bg);
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 40px 16px;
      position: relative;
      overflow: hidden;
    }

    body::before {
      content: "";
      position: fixed;
      inset: 0;
      background-image:
        linear-gradient(transparent 95%, var(--grid) 95%),
        linear-gradient(90deg, transparent 95%, var(--grid) 95%);
      background-size: 38px 38px;
      opacity: 0.35;
      pointer-events: none;
    }

    body::after {
      content: "";
      position: fixed;
      inset: -20%;
      background:
        radial-gradient(circle at 20% 30%, rgba(255,255,255,0.08), transparent 35%),
        radial-gradient(circle at 70% 20%, rgba(255,255,255,0.06), transparent 40%),
        radial-gradient(circle at 50% 80%, rgba(255,255,255,0.05), transparent 45%);
      filter: blur(1px);
      pointer-events: none;
      animation: drift 18s linear infinite;
    }

    .wrap {
      width: min(960px, 100%);
      display: grid;
      gap: 16px;
      animation: rise 600ms ease-out;
      position: relative;
    }

    .hero {
      background: linear-gradient(145deg, rgba(20,26,40,0.95), rgba(20,26,40,0.75));
      border: 1px solid rgba(255,255,255,0.08);
      border-radius: 20px;
      padding: 28px 26px 22px;
      box-shadow: 0 30px 80px rgba(0,0,0,0.45);
      position: relative;
      overflow: hidden;
    }

    .hero::after {
      content: "";
      position: absolute;
      inset: 0;
      background:
        linear-gradient(120deg, transparent 0%, rgba(94,231,255,0.08) 40%, transparent 70%),
        linear-gradient(300deg, transparent 0%, rgba(255,122,217,0.1) 40%, transparent 70%);
      opacity: 0.6;
      pointer-events: none;
    }

    .title {
      font-size: clamp(26px, 4vw, 36px);
      font-weight: 700;
      margin: 0 0 8px 0;
      letter-spacing: 0.5px;
    }

    .subtitle {
      color: var(--muted);
      font-size: 15px;
      margin: 0;
      line-height: 1.7;
    }

    .grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
      gap: 12px;
    }

    .card {
      background: var(--panel);
      border-radius: 16px;
      border: 1px solid rgba(255,255,255,0.08);
      padding: 16px;
      backdrop-filter: blur(6px);
    }

    .card h3 {
      margin: 0 0 8px 0;
      font-size: 16px;
      font-weight: 600;
      color: var(--accent);
    }

    .card p {
      margin: 0;
      color: var(--muted);
      font-size: 14px;
      line-height: 1.7;
    }

    .code {
      margin-top: 14px;
      background: rgba(8, 12, 20, 0.95);
      border: 1px solid rgba(94,231,255,0.15);
      border-radius: 12px;
      padding: 14px;
      font-family: "Cascadia Mono", "Consolas", "Menlo", monospace;
      font-size: 14px;
      color: #e6f6ff;
      word-break: break-all;
    }

    .actions {
      margin-top: 12px;
      display: flex;
      gap: 10px;
      flex-wrap: wrap;
    }

    button {
      border: 1px solid rgba(255,255,255,0.12);
      background: rgba(255,255,255,0.02);
      color: var(--ink);
      border-radius: 10px;
      padding: 8px 12px;
      cursor: pointer;
      transition: 150ms ease;
    }

    button.primary {
      background: linear-gradient(120deg, var(--accent), var(--accent-2) 60%, var(--accent-3));
      color: #0b0f14;
      border: none;
      box-shadow: 0 10px 20px var(--ring);
    }

    button:hover {
      transform: translateY(-1px);
    }

    footer {
      text-align: center;
      color: var(--muted);
      font-size: 12px;
    }

    @keyframes rise {
      from { transform: translateY(8px); opacity: 0; }
      to { transform: translateY(0); opacity: 1; }
    }

    @keyframes drift {
      0% { transform: translateY(0); opacity: 0.5; }
      50% { transform: translateY(-12px); opacity: 0.75; }
      100% { transform: translateY(0); opacity: 0.5; }
    }
  </style>
</head>
<body>
  <main class="wrap">
    <section class="hero">
      <h1 class="title">WinUtil · 中文一键入口</h1>
      <p class="subtitle">简洁、科技、二次元氛围。浏览器访问显示说明页，命令行访问自动返回启动脚本。</p>
      <div class="code" id="cmd">${cmd}</div>
      <div class="actions">
        <button class="primary" onclick="copyCmd()">复制一行命令</button>
        <button onclick="toggleAlt()">显示备用命令</button>
      </div>
      <div class="code" id="alt" style="display:none;">${alt}</div>
    </section>

    <section class="grid">
      <div class="card">
        <h3>一行启动</h3>
        <p>在 PowerShell 中直接运行上面的命令即可启动中文界面。需要管理员权限时请右键以管理员运行。</p>
      </div>
      <div class="card">
        <h3>中文内容</h3>
        <p>GUI 已完成简体中文翻译，应用列表描述也已中文化，便于快速理解与选择。</p>
      </div>
      <div class="card">
        <h3>持续更新</h3>
        <p>你更新 GitHub 上的 <code>winutil.ps1</code> 后，入口命令无需改动即可生效。</p>
      </div>
    </section>

    <footer>WinUtil 自部署入口 · 你的专属 Cloudflare Worker</footer>
  </main>

  <script>
    function copyCmd() {
      const text = document.getElementById('cmd').innerText;
      navigator.clipboard.writeText(text);
    }
    function toggleAlt() {
      const el = document.getElementById('alt');
      el.style.display = el.style.display === 'none' ? 'block' : 'none';
    }
  </script>
</body>
</html>`;
}

function loaderScript(origin) {
  const scriptUrl = `${origin}/winutil.ps1`;
  return `# WinUtil Loader (Chinese)\n` +
    `$ErrorActionPreference = 'Stop'\n` +
    `[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12\n` +
    `$scriptUrl = '${scriptUrl}'\n` +
    `$content = irm $scriptUrl\n` +
    `$text = if ($content -is [byte[]]) { [Text.Encoding]::UTF8.GetString($content) } else { [string]$content }\n` +
    `if ($text.Length -gt 0 -and $text[0] -eq [char]0xFEFF) { $text = $text.Substring(1) }\n` +
    `iex $text\n`;
}

async function proxyPs1() {
  const response = await fetch(RAW_PS1_URL);
  if (!response.ok) {
    return new Response('无法从上游获取 winutil.ps1', { status: 502 });
  }
  return new Response(response.body, {
    status: response.status,
    headers: {
      'Content-Type': 'text/plain; charset=utf-8',
      'Cache-Control': 'no-cache, no-store, must-revalidate',
    },
  });
}

export default {
  async fetch(request) {
    const url = new URL(request.url);
    const origin = url.origin;

    if (url.pathname.toLowerCase() === '/winutil.ps1') {
      return proxyPs1();
    }

    if ((isBrowser(request) || url.searchParams.has('html')) && !url.searchParams.has('raw')) {
      return new Response(htmlPage(origin), {
        headers: {
          'Content-Type': 'text/html; charset=utf-8',
          'Cache-Control': 'no-cache, no-store, must-revalidate',
        },
      });
    }

    return new Response(loaderScript(origin), {
      headers: {
        'Content-Type': 'text/plain; charset=utf-8',
        'Cache-Control': 'no-cache, no-store, must-revalidate',
      },
    });
  },
};
