export function renderDashboard(): string {
  return `<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Stratum | Distributed object storage at the edge</title>
  <meta name="description" content="Stratum is distributed object storage with an S3-compatible API, Cloudflare edge cache, R2 warm storage, and Telegram cold storage.">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
  <style>
    :root {
      color-scheme: dark;
      --bg: #0a0a0a;
      --surface: #111111;
      --surface-2: #151515;
      --border: #222222;
      --text: #e5e5e5;
      --muted: #888888;
      --accent: #f97316;
      --accent-soft: rgba(249, 115, 22, 0.14);
      --ok: #22c55e;
    }
    * { box-sizing: border-box; }
    body {
      margin: 0;
      min-width: 320px;
      background: var(--bg);
      color: var(--text);
      font-family: Inter, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
      letter-spacing: 0;
    }
    a { color: inherit; text-decoration: none; }
    .shell { width: min(1120px, calc(100% - 32px)); margin: 0 auto; }
    header {
      position: sticky;
      top: 0;
      z-index: 5;
      background: rgba(10, 10, 10, 0.86);
      border-bottom: 1px solid var(--border);
      backdrop-filter: blur(16px);
    }
    .nav {
      min-height: 76px;
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 18px;
    }
    .brand { display: flex; align-items: center; gap: 12px; min-width: 0; }
    .logo {
      width: 42px;
      height: 42px;
      display: grid;
      place-items: center;
      border: 1px solid var(--border);
      background: var(--surface);
    }
    .brand h1 { margin: 0; font-size: 18px; line-height: 1.1; }
    .brand p { margin: 4px 0 0; color: var(--muted); font-size: 13px; }
    .actions { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; justify-content: flex-end; }
    .pill, .button {
      border: 1px solid var(--border);
      background: var(--surface);
      color: var(--text);
      min-height: 38px;
      display: inline-flex;
      align-items: center;
      gap: 8px;
      padding: 0 13px;
      font-size: 13px;
      font-weight: 600;
      transition: border-color .2s ease, transform .2s ease, background .2s ease;
    }
    .button:hover { border-color: var(--accent); transform: translateY(-1px); }
    .pill strong { color: var(--accent); font-weight: 800; }
    main { overflow: hidden; }
    .hero {
      min-height: calc(100vh - 76px);
      display: grid;
      align-content: center;
      gap: 28px;
      padding: 72px 0 48px;
    }
    .hero-copy { max-width: 760px; }
    .eyebrow { color: var(--accent); font-size: 13px; font-weight: 800; text-transform: uppercase; }
    .hero h2 {
      margin: 12px 0 12px;
      font-size: clamp(42px, 8vw, 86px);
      line-height: .92;
      max-width: 860px;
    }
    .hero p { color: var(--muted); font-size: clamp(16px, 2.2vw, 20px); line-height: 1.6; margin: 0; }
    .upload-zone {
      border: 1px dashed #343434;
      background: linear-gradient(180deg, rgba(249,115,22,.08), rgba(17,17,17,.92));
      min-height: 220px;
      display: grid;
      place-items: center;
      text-align: center;
      padding: 28px;
      cursor: pointer;
      transition: border-color .2s ease, background .2s ease, transform .2s ease;
    }
    .upload-zone:hover, .upload-zone.dragging {
      border-color: var(--accent);
      background: linear-gradient(180deg, rgba(249,115,22,.14), rgba(17,17,17,.96));
      transform: translateY(-2px);
    }
    .upload-zone.dragging { animation: pulse-border 1.1s ease-in-out infinite; }
    @keyframes pulse-border {
      0%, 100% { box-shadow: 0 0 0 0 rgba(249,115,22,.05); }
      50% { box-shadow: 0 0 0 8px rgba(249,115,22,.13); }
    }
    .upload-zone input { display: none; }
    .upload-inner { display: block; width: min(560px, 100%); }
    .upload-icon {
      width: 58px;
      height: 58px;
      margin: 0 auto 18px;
      display: grid;
      place-items: center;
      border: 1px solid rgba(249,115,22,.35);
      background: var(--accent-soft);
      color: var(--accent);
      font-size: 26px;
      font-weight: 800;
    }
    .upload-title { display: block; font-size: 21px; font-weight: 800; margin-bottom: 8px; }
    .upload-note { display: block; color: var(--muted); font-size: 14px; }
    .progress {
      height: 8px;
      width: 100%;
      margin-top: 18px;
      background: #202020;
      overflow: hidden;
      opacity: 0;
      transition: opacity .2s ease;
    }
    .progress.active { opacity: 1; }
    .progress span { display: block; width: 0; height: 100%; background: var(--accent); transition: width .16s ease; }
    .section-head { display: flex; align-items: flex-end; justify-content: space-between; gap: 16px; margin-top: 8px; }
    .section-head h3 { margin: 0; font-size: 18px; }
    .section-head p { margin: 0; color: var(--muted); font-size: 13px; }
    .file-list {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
      gap: 12px;
      min-height: 96px;
      margin-top: 14px;
    }
    .empty {
      grid-column: 1 / -1;
      color: var(--muted);
      border: 1px solid var(--border);
      background: var(--surface);
      padding: 22px;
      text-align: center;
    }
    .file-card {
      border: 1px solid var(--border);
      background: var(--surface);
      padding: 16px;
      display: grid;
      gap: 14px;
      animation: enter .35s ease both;
      min-width: 0;
    }
    @keyframes enter { from { opacity: 0; transform: translateY(12px); } to { opacity: 1; transform: translateY(0); } }
    .file-top { display: flex; align-items: flex-start; justify-content: space-between; gap: 12px; min-width: 0; }
    .file-name { font-size: 15px; font-weight: 800; overflow-wrap: anywhere; }
    .meta { color: var(--muted); font-size: 12px; display: flex; gap: 8px; flex-wrap: wrap; }
    .tier {
      border: 1px solid rgba(249,115,22,.32);
      color: var(--accent);
      background: var(--accent-soft);
      padding: 5px 8px;
      font-size: 11px;
      font-weight: 800;
      text-transform: uppercase;
      white-space: nowrap;
      transition: color .2s ease, background .2s ease, border-color .2s ease;
    }
    .tier.telegram { color: var(--ok); border-color: rgba(34,197,94,.32); background: rgba(34,197,94,.11); }
    .copy {
      justify-self: start;
      border: 1px solid var(--border);
      background: transparent;
      color: var(--text);
      padding: 8px 10px;
      cursor: pointer;
      font: inherit;
      font-size: 12px;
      font-weight: 700;
      transition: border-color .2s ease, color .2s ease;
    }
    .copy:hover { border-color: var(--accent); color: var(--accent); }
    .architecture { padding: 78px 0 64px; border-top: 1px solid var(--border); }
    .architecture h3 { font-size: clamp(28px, 4vw, 48px); margin: 0 0 14px; }
    .architecture > .shell > p { color: var(--muted); margin: 0 0 24px; font-size: 16px; }
    .tier-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 14px; }
    .tier-card { border: 1px solid var(--border); background: var(--surface); padding: 20px; min-height: 168px; }
    .tier-card .icon { color: var(--accent); font-size: 24px; margin-bottom: 24px; }
    .tier-card h4 { margin: 0 0 8px; font-size: 18px; }
    .tier-card p { margin: 0; color: var(--muted); line-height: 1.55; font-size: 14px; }
    .flow {
      position: relative;
      height: 78px;
      margin: 24px 0 0;
      border: 1px solid var(--border);
      background: repeating-linear-gradient(90deg, #111, #111 24px, #131313 24px, #131313 48px);
      overflow: hidden;
    }
    .flow-line { position: absolute; left: 10%; right: 10%; top: 38px; height: 1px; background: #333; }
    .flow-dot {
      position: absolute;
      top: 28px;
      left: 10%;
      width: 20px;
      height: 20px;
      background: var(--accent);
      animation: move-file 4.2s ease-in-out infinite;
    }
    @keyframes move-file {
      0% { left: 10%; transform: scale(.85); }
      35% { left: calc(50% - 10px); transform: scale(1); }
      70%, 100% { left: calc(90% - 20px); transform: scale(.85); }
    }
    footer { border-top: 1px solid var(--border); color: var(--muted); }
    .foot { min-height: 74px; display: flex; align-items: center; justify-content: space-between; gap: 14px; font-size: 13px; }
    .foot a { color: var(--text); font-weight: 700; }
    @media (max-width: 720px) {
      .nav, .foot, .section-head { align-items: flex-start; flex-direction: column; }
      .actions { justify-content: flex-start; }
      .hero { padding-top: 44px; }
      .tier-grid { grid-template-columns: 1fr; }
      .brand p { max-width: 260px; }
    }
    @media (max-width: 420px) {
      .shell { width: min(100% - 24px, 1120px); }
      .pill, .button { width: 100%; justify-content: center; }
      .actions { width: 100%; }
      .upload-zone { min-height: 190px; padding: 20px; }
      .file-list { grid-template-columns: 1fr; }
    }
  </style>
</head>
<body>
  <header>
    <div class="shell nav">
      <a class="brand" href="/" aria-label="Stratum home">
        <span class="logo" aria-hidden="true">
          <svg width="28" height="28" viewBox="0 0 28 28" fill="none">
            <path d="M4 9L14 4L24 9L14 14L4 9Z" stroke="#f97316" stroke-width="1.6"/>
            <path d="M4 16L14 11L24 16L14 21L4 16Z" stroke="#e5e5e5" stroke-width="1.6"/>
          </svg>
        </span>
        <span><h1>Stratum</h1><p>Distributed object storage. Free, forever, at the edge.</p></span>
      </a>
      <div class="actions">
        <span class="pill" id="stats-pill"><strong>0</strong> files · 0 B</span>
        <a class="button" href="#" aria-label="View Stratum on GitHub">GitHub</a>
      </div>
    </div>
  </header>
  <main>
    <section class="shell hero">
      <div class="hero-copy">
        <div class="eyebrow">S3-compatible storage demo</div>
        <h2>Upload once. Let the tiers do the work.</h2>
        <p>Drop a file into Stratum and watch it land at the edge, warm through R2, and settle into Telegram-backed cold storage.</p>
      </div>
      <label class="upload-zone" id="upload-zone">
        <input id="file-input" type="file">
        <span class="upload-inner">
          <span class="upload-icon">+</span>
          <span class="upload-title">Drop a file here</span>
          <span class="upload-note">or click to choose any file type</span>
          <span class="progress" id="progress"><span></span></span>
        </span>
      </label>
      <div>
        <div class="section-head">
          <h3>Demo bucket files</h3>
          <p>Public uploads are scoped to the <code>demo</code> bucket.</p>
        </div>
        <div class="file-list" id="file-list">
          <div class="empty">No files yet. Drop one above to get started.</div>
        </div>
      </div>
    </section>
    <section class="architecture">
      <div class="shell">
        <h3>Three storage tiers, one endpoint.</h3>
        <p>Stratum keeps the API simple while moving data through faster and cheaper layers behind the scenes.</p>
        <div class="tier-grid">
          <article class="tier-card"><div class="icon">01</div><h4>Edge Cache</h4><p>Cloudflare CDN keeps hot files close to users with sub-10ms access.</p></article>
          <article class="tier-card"><div class="icon">02</div><h4>Warm Storage</h4><p>Cloudflare R2 holds recent files with roughly 40ms access and zero egress fees.</p></article>
          <article class="tier-card"><div class="icon">03</div><h4>Cold Storage</h4><p>Telegram API provides the durable cold tier for unlimited free storage.</p></article>
        </div>
        <div class="flow" aria-hidden="true"><div class="flow-line"></div><div class="flow-dot"></div></div>
      </div>
    </section>
  </main>
  <footer>
    <div class="shell foot">
      <span>Built on Cloudflare Workers · D1 · R2 · Telegram Bot API</span>
      <a href="#">View on GitHub</a>
    </div>
  </footer>
  <script>
    const bucket = 'demo';
    const zone = document.getElementById('upload-zone');
    const input = document.getElementById('file-input');
    const list = document.getElementById('file-list');
    const progress = document.getElementById('progress');
    const progressBar = progress.querySelector('span');
    const statsPill = document.getElementById('stats-pill');

    function humanSize(bytes) {
      if (bytes < 1024) return bytes + ' B';
      if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' KB';
      if (bytes < 1024 * 1024 * 1024) return (bytes / 1048576).toFixed(1) + ' MB';
      return (bytes / 1073741824).toFixed(2) + ' GB';
    }
    function relativeTime(value) {
      const then = new Date(value).getTime();
      if (!Number.isFinite(then)) return 'just now';
      const seconds = Math.max(1, Math.floor((Date.now() - then) / 1000));
      const units = [['year',31536000], ['month',2592000], ['day',86400], ['hour',3600], ['minute',60]];
      for (const [name, size] of units) {
        if (seconds >= size) {
          const n = Math.floor(seconds / size);
          return n + ' ' + name + (n === 1 ? '' : 's') + ' ago';
        }
      }
      return 'just now';
    }
    function objectUrl(key) {
      return location.origin + '/' + bucket + '/' + key.split('/').map(encodeURIComponent).join('/');
    }
    function parseObjects(xmlText) {
      const doc = new DOMParser().parseFromString(xmlText, 'application/xml');
      return [...doc.querySelectorAll('Contents')].map(node => ({
        key: node.querySelector('Key')?.textContent || '',
        size: Number(node.querySelector('Size')?.textContent || 0),
        lastModified: node.querySelector('LastModified')?.textContent || new Date().toISOString(),
      })).filter(item => item.key);
    }
    function renderEmpty() {
      list.innerHTML = '<div class="empty">No files yet. Drop one above to get started.</div>';
    }
    function addCard(file, mode = 'cold') {
      const empty = list.querySelector('.empty');
      if (empty) empty.remove();
      const card = document.createElement('article');
      card.className = 'file-card';
      const tier = mode === 'uploading' ? 'uploading...' : mode === 'warm' ? 'R2' : 'Telegram';
      card.innerHTML = '<div class="file-top"><div><div class="file-name"></div><div class="meta"></div></div><span class="tier"></span></div><button class="copy" type="button">Copy link</button>';
      card.querySelector('.file-name').textContent = file.key;
      card.querySelector('.meta').textContent = humanSize(file.size) + ' · ' + relativeTime(file.lastModified);
      const tierEl = card.querySelector('.tier');
      tierEl.textContent = tier;
      if (mode === 'cold') tierEl.classList.add('telegram');
      card.querySelector('.copy').addEventListener('click', async () => {
        await navigator.clipboard.writeText(objectUrl(file.key));
        card.querySelector('.copy').textContent = 'Copied';
        setTimeout(() => card.querySelector('.copy').textContent = 'Copy link', 1200);
      });
      list.prepend(card);
      return tierEl;
    }
    async function refreshStats() {
      const res = await fetch('/api/stats');
      if (!res.ok) return;
      const stats = await res.json();
      statsPill.innerHTML = '<strong>' + stats.totalFiles + '</strong> files · ' + stats.totalSizeHuman;
    }
    async function loadFiles() {
      const res = await fetch('/' + bucket + '?list-type=2');
      if (!res.ok) { renderEmpty(); return; }
      const files = parseObjects(await res.text());
      list.innerHTML = '';
      if (!files.length) renderEmpty();
      files.reverse().forEach(file => addCard(file, 'cold'));
    }
    function upload(file) {
      const key = file.name || ('upload-' + Date.now());
      const tier = addCard({ key, size: file.size, lastModified: new Date().toISOString() }, 'uploading');
      progress.classList.add('active');
      progressBar.style.width = '0%';
      const xhr = new XMLHttpRequest();
      xhr.open('PUT', '/' + bucket + '/' + key.split('/').map(encodeURIComponent).join('/'));
      xhr.setRequestHeader('content-type', file.type || 'application/octet-stream');
      xhr.upload.onprogress = event => {
        if (event.lengthComputable) progressBar.style.width = Math.round((event.loaded / event.total) * 100) + '%';
      };
      xhr.onload = async () => {
        progressBar.style.width = '100%';
        setTimeout(() => progress.classList.remove('active'), 500);
        if (xhr.status >= 200 && xhr.status < 300) {
          tier.textContent = 'R2';
          setTimeout(() => { tier.textContent = 'Telegram'; tier.classList.add('telegram'); }, 4000);
          await refreshStats();
        } else {
          tier.textContent = 'failed';
        }
      };
      xhr.onerror = () => { progress.classList.remove('active'); tier.textContent = 'failed'; };
      xhr.send(file);
    }
    ['dragenter','dragover'].forEach(type => zone.addEventListener(type, event => { event.preventDefault(); zone.classList.add('dragging'); }));
    ['dragleave','drop'].forEach(type => zone.addEventListener(type, event => { event.preventDefault(); zone.classList.remove('dragging'); }));
    zone.addEventListener('drop', event => { const file = event.dataTransfer.files[0]; if (file) upload(file); });
    input.addEventListener('change', event => { const file = event.target.files[0]; if (file) upload(file); input.value = ''; });
    refreshStats();
    loadFiles();
  </script>
</body>
</html>`;
}
