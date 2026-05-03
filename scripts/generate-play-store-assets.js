// generate-play-store-assets.js — Renders designed Play Store assets to
// PNG via headless Chromium. Brand-true to CHV's Paprika/Thunder/Salem
// palette. Produces 6 phone screenshots (1080×1920) and a 1024×500
// feature graphic. Output goes to app/store-assets/play-store/.

const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');

const OUT_DIR = path.resolve(__dirname, '..', 'app', 'store-assets', 'play-store');

// Brand
const PAPRIKA = '#93003C';
const THUNDER = '#252122';
const SALEM = '#0F8044';
const CREAM = '#FAF7F2';
const GOLD = '#D4A24C';

// Common phone frame + base CSS shared by every screenshot
function shell(content, { headline, subline, accent = PAPRIKA, bgFrom, bgTo }) {
  const fromColor = bgFrom || THUNDER;
  const toColor = bgTo || PAPRIKA;
  return `<!doctype html>
<html><head><meta charset="utf-8">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700;900&family=Montserrat:wght@400;600;700;900&display=swap" rel="stylesheet">
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  html, body { width: 1080px; height: 1920px; overflow: hidden; }
  body {
    background: linear-gradient(160deg, ${fromColor} 0%, ${toColor} 100%);
    font-family: 'Montserrat', system-ui, sans-serif;
    color: #fff;
    position: relative;
    padding: 80px 60px;
    display: flex;
    flex-direction: column;
    align-items: center;
  }
  body::before {
    content: '';
    position: absolute;
    inset: 0;
    background-image:
      radial-gradient(circle at 85% 15%, rgba(212,162,76,0.18), transparent 40%),
      radial-gradient(circle at 15% 90%, rgba(15,128,68,0.12), transparent 35%);
    pointer-events: none;
  }
  .headline {
    font-family: 'Playfair Display', Georgia, serif;
    font-weight: 900;
    font-size: 96px;
    line-height: 1.05;
    text-align: center;
    margin-bottom: 24px;
    letter-spacing: -1px;
    text-shadow: 0 4px 24px rgba(0,0,0,0.4);
    z-index: 2;
  }
  .headline .accent { color: ${GOLD}; font-style: italic; }
  .subline {
    font-family: 'Montserrat', sans-serif;
    font-weight: 600;
    font-size: 36px;
    line-height: 1.3;
    text-align: center;
    opacity: 0.92;
    margin-bottom: 60px;
    max-width: 900px;
    z-index: 2;
  }
  .phone {
    width: 620px;
    height: 1280px;
    border-radius: 64px;
    background: #000;
    padding: 16px;
    box-shadow: 0 60px 120px rgba(0,0,0,0.5), 0 0 0 4px rgba(255,255,255,0.08);
    position: relative;
    z-index: 2;
  }
  .phone::before {
    content: '';
    position: absolute;
    top: 24px;
    left: 50%;
    transform: translateX(-50%);
    width: 180px;
    height: 32px;
    background: #000;
    border-radius: 16px;
    z-index: 10;
  }
  .screen {
    width: 100%;
    height: 100%;
    border-radius: 50px;
    overflow: hidden;
    background: ${CREAM};
    color: ${THUNDER};
    position: relative;
    font-family: 'Montserrat', sans-serif;
  }
  .footer-tag {
    position: absolute;
    bottom: 50px;
    left: 0;
    right: 0;
    text-align: center;
    font-family: 'Playfair Display', serif;
    font-weight: 700;
    font-style: italic;
    font-size: 28px;
    color: ${GOLD};
    z-index: 2;
    letter-spacing: 2px;
  }
  .badge {
    display: inline-block;
    background: ${accent};
    color: #fff;
    padding: 12px 28px;
    border-radius: 999px;
    font-weight: 700;
    font-size: 24px;
    letter-spacing: 1px;
    text-transform: uppercase;
    margin-bottom: 24px;
    z-index: 2;
  }
</style></head>
<body>
  ${content.badge ? `<div class="badge">${content.badge}</div>` : ''}
  <h1 class="headline">${headline}</h1>
  ${subline ? `<p class="subline">${subline}</p>` : ''}
  <div class="phone"><div class="screen">${content.screen}</div></div>
  <div class="footer-tag">WineBro · Your elder bro in wine</div>
</body></html>`;
}

// ============= Screen content templates =============

const screen1Hero = `
<div style="height:100%; display:flex; flex-direction:column; align-items:center; justify-content:center; padding:60px 40px; text-align:center; background: linear-gradient(180deg, ${CREAM} 0%, #fff 100%);">
  <div style="width:200px; height:200px; border-radius:50%; background:${PAPRIKA}; display:flex; align-items:center; justify-content:center; margin-bottom:48px; box-shadow: 0 20px 40px rgba(147,0,60,0.3);">
    <svg width="120" height="120" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="1.5"><path d="M8 2h8l-1 7c0 2-1.5 4-4 4s-4-2-4-4l1-7zM12 13v7M9 22h6"/></svg>
  </div>
  <h2 style="font-family:'Playfair Display'; font-weight:900; font-size:54px; color:${PAPRIKA}; margin-bottom:16px; letter-spacing:-1px;">WineBro</h2>
  <p style="font-family:'Playfair Display'; font-style:italic; font-size:28px; color:${THUNDER}; opacity:0.7; margin-bottom:60px;">Your elder bro in wine</p>
  <button style="background:${PAPRIKA}; color:white; border:none; padding:24px 80px; border-radius:999px; font-family:'Montserrat'; font-weight:700; font-size:28px; letter-spacing:1px;">Get Started</button>
  <p style="margin-top:48px; font-size:20px; color:${THUNDER}; opacity:0.5;">Wine · Whisky · Gin · Rum · Cocktails</p>
</div>`;

const screen2Quiz = `
<div style="height:100%; display:flex; flex-direction:column; padding:80px 40px 40px; background:${CREAM};">
  <p style="font-size:22px; color:${PAPRIKA}; font-weight:700; letter-spacing:2px; text-transform:uppercase; margin-bottom:12px;">Question 3 of 10</p>
  <h2 style="font-family:'Playfair Display'; font-weight:900; font-size:48px; color:${THUNDER}; margin-bottom:48px; line-height:1.1;">Which best describes your<br/>ideal Sunday afternoon?</h2>
  <div style="display:flex; flex-direction:column; gap:20px;">
    <div style="background:#fff; border:2px solid ${PAPRIKA}; border-radius:24px; padding:28px; box-shadow:0 8px 24px rgba(147,0,60,0.15);">
      <div style="display:flex; align-items:center; gap:20px;"><span style="font-size:36px;">🍷</span><span style="font-size:24px; font-weight:600; color:${THUNDER};">Slow lunch with a bold red</span></div>
    </div>
    <div style="background:#fff; border:2px solid #e0d8d2; border-radius:24px; padding:28px;">
      <div style="display:flex; align-items:center; gap:20px;"><span style="font-size:36px;">🥃</span><span style="font-size:24px; font-weight:600; color:${THUNDER}; opacity:0.7;">Single malt by the window</span></div>
    </div>
    <div style="background:#fff; border:2px solid #e0d8d2; border-radius:24px; padding:28px;">
      <div style="display:flex; align-items:center; gap:20px;"><span style="font-size:36px;">🍸</span><span style="font-size:24px; font-weight:600; color:${THUNDER}; opacity:0.7;">A crisp gin & tonic outdoors</span></div>
    </div>
    <div style="background:#fff; border:2px solid #e0d8d2; border-radius:24px; padding:28px;">
      <div style="display:flex; align-items:center; gap:20px;"><span style="font-size:36px;">🍺</span><span style="font-size:24px; font-weight:600; color:${THUNDER}; opacity:0.7;">Cold beer, no thinking</span></div>
    </div>
  </div>
  <div style="margin-top:auto; padding-top:40px;">
    <div style="background:#e0d8d2; height:8px; border-radius:4px; overflow:hidden;"><div style="background:${PAPRIKA}; height:100%; width:30%;"></div></div>
    <p style="text-align:center; margin-top:16px; font-size:18px; color:${THUNDER}; opacity:0.5;">Building your taste DNA…</p>
  </div>
</div>`;

const screen3Scanner = `
<div style="height:100%; background:#0a0a0a; position:relative; display:flex; flex-direction:column;">
  <div style="height:90px; background:rgba(0,0,0,0.6); display:flex; align-items:center; padding:0 32px;">
    <p style="color:white; font-size:24px; font-weight:600;">📷  Point at a label</p>
  </div>
  <div style="flex:1; background: radial-gradient(ellipse at center, #1a1a1a 0%, #000 100%); display:flex; align-items:center; justify-content:center; position:relative;">
    <div style="width:380px; height:540px; border:3px solid ${GOLD}; border-radius:24px; position:relative;">
      <div style="position:absolute; top:-3px; left:-3px; width:60px; height:60px; border-top:6px solid ${GOLD}; border-left:6px solid ${GOLD}; border-radius:24px 0 0 0;"></div>
      <div style="position:absolute; top:-3px; right:-3px; width:60px; height:60px; border-top:6px solid ${GOLD}; border-right:6px solid ${GOLD}; border-radius:0 24px 0 0;"></div>
      <div style="position:absolute; bottom:-3px; left:-3px; width:60px; height:60px; border-bottom:6px solid ${GOLD}; border-left:6px solid ${GOLD}; border-radius:0 0 0 24px;"></div>
      <div style="position:absolute; bottom:-3px; right:-3px; width:60px; height:60px; border-bottom:6px solid ${GOLD}; border-right:6px solid ${GOLD}; border-radius:0 0 24px 0;"></div>
      <div style="position:absolute; inset:30px; background: linear-gradient(180deg, #2a1010 0%, #5a1a1a 50%, #1a0808 100%); border-radius:12px; display:flex; flex-direction:column; align-items:center; justify-content:center; padding:24px;">
        <p style="font-family:'Playfair Display'; color:${GOLD}; font-size:32px; font-weight:700; text-align:center; line-height:1.2;">PENFOLDS</p>
        <p style="font-family:'Playfair Display'; color:${GOLD}; font-size:20px; opacity:0.8; margin-top:6px;">BIN 389</p>
        <div style="width:60%; height:2px; background:${GOLD}; margin:20px 0; opacity:0.6;"></div>
        <p style="color:white; font-size:14px; opacity:0.7; text-align:center;">Cabernet Shiraz<br/>South Australia</p>
      </div>
    </div>
  </div>
  <div style="background:${PAPRIKA}; padding:32px; display:flex; align-items:center; gap:20px;">
    <span style="font-size:36px;">✨</span>
    <div>
      <p style="color:white; font-weight:700; font-size:22px; margin-bottom:4px;">Recognised in 0.4s</p>
      <p style="color:#fff; opacity:0.85; font-size:18px;">Tap to see pairings →</p>
    </div>
  </div>
</div>`;

const screen4Pairing = `
<div style="height:100%; background:${CREAM}; padding:60px 32px 32px; display:flex; flex-direction:column;">
  <p style="font-size:20px; color:${PAPRIKA}; font-weight:700; letter-spacing:2px; text-transform:uppercase;">Pairing for</p>
  <h2 style="font-family:'Playfair Display'; font-weight:900; font-size:42px; color:${THUNDER}; margin-bottom:32px; line-height:1.1;">Butter Chicken</h2>
  <div style="background:linear-gradient(135deg, ${PAPRIKA} 0%, #6b002a 100%); border-radius:24px; padding:28px; color:white; margin-bottom:20px; box-shadow:0 12px 32px rgba(147,0,60,0.3);">
    <div style="display:flex; align-items:start; gap:16px;">
      <div style="background:${GOLD}; color:${THUNDER}; padding:6px 14px; border-radius:999px; font-weight:700; font-size:16px; letter-spacing:1px;">BRO'S PICK</div>
    </div>
    <h3 style="font-family:'Playfair Display'; font-weight:700; font-size:32px; margin-top:16px;">Sula Rasa Shiraz</h3>
    <p style="font-size:18px; opacity:0.85; margin-top:8px;">Indian · ₹650 · Medium body</p>
    <p style="font-size:18px; line-height:1.5; margin-top:18px; opacity:0.95;">The pepper notes cut through the cream, while the dark fruit echoes the tomato base.</p>
    <div style="display:flex; gap:8px; margin-top:18px;">
      <span style="background:rgba(255,255,255,0.2); padding:8px 16px; border-radius:999px; font-size:16px;">★ 94% match</span>
    </div>
  </div>
  <div style="background:#fff; border-radius:20px; padding:24px; margin-bottom:14px; border:1px solid #e0d8d2;">
    <h4 style="font-family:'Playfair Display'; font-weight:700; font-size:24px; color:${THUNDER};">Jacob's Creek Shiraz Cabernet</h4>
    <p style="font-size:16px; color:${THUNDER}; opacity:0.6; margin-top:6px;">Australian · ₹950 · 88% match</p>
  </div>
  <div style="background:#fff; border-radius:20px; padding:24px; margin-bottom:14px; border:1px solid #e0d8d2;">
    <h4 style="font-family:'Playfair Display'; font-weight:700; font-size:24px; color:${THUNDER};">Old Monk on the rocks</h4>
    <p style="font-size:16px; color:${THUNDER}; opacity:0.6; margin-top:6px;">Indian rum · ₹220 · 81% match</p>
  </div>
  <div style="background:#fff; border-radius:20px; padding:24px; border:1px solid #e0d8d2;">
    <h4 style="font-family:'Playfair Display'; font-weight:700; font-size:24px; color:${THUNDER};">Bombay Sapphire & Tonic</h4>
    <p style="font-size:16px; color:${THUNDER}; opacity:0.6; margin-top:6px;">Gin · ₹180 · 76% match</p>
  </div>
</div>`;

const screen5BroCard = `
<div style="height:100%; background:linear-gradient(180deg, ${THUNDER} 0%, #1a1717 100%); padding:60px 32px; color:white;">
  <p style="font-size:18px; color:${GOLD}; font-weight:700; letter-spacing:3px; text-transform:uppercase;">BroCard #47</p>
  <h2 style="font-family:'Playfair Display'; font-weight:900; font-size:42px; margin:8px 0 4px; line-height:1.1;">Antinori Tignanello</h2>
  <p style="font-size:18px; opacity:0.7; margin-bottom:32px;">Tuscany, Italy · 2019 · ₹12,500</p>
  <div style="background:${PAPRIKA}; border-radius:24px; padding:32px; margin-bottom:24px;">
    <div style="display:flex; justify-content:space-between; align-items:end; margin-bottom:24px;">
      <div>
        <p style="font-size:18px; opacity:0.8;">Your score</p>
        <p style="font-family:'Playfair Display'; font-weight:900; font-size:72px; line-height:1;">9.2</p>
      </div>
      <div style="text-align:right;">
        <p style="font-size:18px; opacity:0.8;">Tasted</p>
        <p style="font-size:24px; font-weight:700;">28 Apr 2026</p>
      </div>
    </div>
    <p style="font-family:'Playfair Display'; font-style:italic; font-size:22px; line-height:1.4; opacity:0.95;">"Layers of dark cherry and tobacco, with that signature Tuscan dusty finish. Drinks like a memory."</p>
  </div>
  <p style="font-size:18px; color:${GOLD}; font-weight:700; letter-spacing:2px; text-transform:uppercase; margin-bottom:14px;">Aromas detected</p>
  <div style="display:flex; flex-wrap:wrap; gap:10px;">
    ${['Dark cherry', 'Tobacco', 'Leather', 'Vanilla', 'Dried herbs', 'Plum', 'Cedar'].map(t => `<span style="background:rgba(255,255,255,0.1); border:1px solid ${GOLD}; padding:10px 18px; border-radius:999px; font-size:18px;">${t}</span>`).join('')}
  </div>
  <div style="display:flex; gap:16px; margin-top:32px;">
    <div style="flex:1; background:rgba(15,128,68,0.15); border:1px solid ${SALEM}; border-radius:16px; padding:20px; text-align:center;">
      <p style="font-size:14px; opacity:0.7; letter-spacing:1px;">PAIRED WITH</p>
      <p style="font-weight:700; font-size:20px; margin-top:6px;">Aged parmesan</p>
    </div>
    <div style="flex:1; background:rgba(212,162,76,0.15); border:1px solid ${GOLD}; border-radius:16px; padding:20px; text-align:center;">
      <p style="font-size:14px; opacity:0.7; letter-spacing:1px;">+250 XP</p>
      <p style="font-weight:700; font-size:20px; margin-top:6px;">Cellar Master Lv4</p>
    </div>
  </div>
</div>`;

const screen6AromaWheel = `
<div style="height:100%; background:${CREAM}; padding:60px 32px; display:flex; flex-direction:column;">
  <p style="font-size:20px; color:${PAPRIKA}; font-weight:700; letter-spacing:2px; text-transform:uppercase;">Your palate</p>
  <h2 style="font-family:'Playfair Display'; font-weight:900; font-size:42px; color:${THUNDER}; margin-bottom:32px; line-height:1.1;">Built from 47 tastings</h2>
  <div style="display:flex; justify-content:center; margin:20px 0 40px;">
    <svg width="440" height="440" viewBox="0 0 200 200">
      <defs>
        <radialGradient id="g1" cx="50%" cy="50%" r="50%"><stop offset="0%" stop-color="${PAPRIKA}" stop-opacity="0.2"/><stop offset="100%" stop-color="${PAPRIKA}" stop-opacity="0.6"/></radialGradient>
      </defs>
      <!-- radar grid -->
      <polygon points="100,20 168,60 168,140 100,180 32,140 32,60" fill="none" stroke="${THUNDER}" stroke-opacity="0.1" stroke-width="0.5"/>
      <polygon points="100,40 152,70 152,130 100,160 48,130 48,70" fill="none" stroke="${THUNDER}" stroke-opacity="0.1" stroke-width="0.5"/>
      <polygon points="100,60 136,80 136,120 100,140 64,120 64,80" fill="none" stroke="${THUNDER}" stroke-opacity="0.1" stroke-width="0.5"/>
      <polygon points="100,80 120,90 120,110 100,120 80,110 80,90" fill="none" stroke="${THUNDER}" stroke-opacity="0.1" stroke-width="0.5"/>
      <!-- user shape -->
      <polygon points="100,30 162,68 158,135 100,168 42,138 38,62" fill="url(#g1)" stroke="${PAPRIKA}" stroke-width="1.5"/>
      <!-- axis labels -->
      <text x="100" y="14" text-anchor="middle" font-family="Montserrat" font-size="9" font-weight="700" fill="${THUNDER}">FRUITY</text>
      <text x="180" y="58" text-anchor="middle" font-family="Montserrat" font-size="9" font-weight="700" fill="${THUNDER}">SMOKY</text>
      <text x="180" y="148" text-anchor="middle" font-family="Montserrat" font-size="9" font-weight="700" fill="${THUNDER}">BOLD</text>
      <text x="100" y="195" text-anchor="middle" font-family="Montserrat" font-size="9" font-weight="700" fill="${THUNDER}">SWEET</text>
      <text x="20" y="148" text-anchor="middle" font-family="Montserrat" font-size="9" font-weight="700" fill="${THUNDER}">CRISP</text>
      <text x="20" y="58" text-anchor="middle" font-family="Montserrat" font-size="9" font-weight="700" fill="${THUNDER}">FLORAL</text>
    </svg>
  </div>
  <div style="display:grid; grid-template-columns:1fr 1fr; gap:14px; margin-bottom:24px;">
    <div style="background:#fff; padding:20px; border-radius:16px; border-left:4px solid ${PAPRIKA};">
      <p style="font-size:14px; color:${THUNDER}; opacity:0.6; letter-spacing:1px;">YOUR LEAN</p>
      <p style="font-family:'Playfair Display'; font-weight:700; font-size:22px; color:${THUNDER}; margin-top:4px;">Bold & Smoky</p>
    </div>
    <div style="background:#fff; padding:20px; border-radius:16px; border-left:4px solid ${SALEM};">
      <p style="font-size:14px; color:${THUNDER}; opacity:0.6; letter-spacing:1px;">LEVEL</p>
      <p style="font-family:'Playfair Display'; font-weight:700; font-size:22px; color:${THUNDER}; margin-top:4px;">Cellar Master</p>
    </div>
  </div>
  <div style="background:${PAPRIKA}; color:white; padding:18px 24px; border-radius:14px; text-align:center; font-weight:700; font-size:18px;">🏆 New badge: "Tuscan Soul"</div>
</div>`;

// ============= Six screenshots =============
const SCREENSHOTS = [
  { name: '01-hero', headline: 'Your elder bro<br/>in <span class="accent">wine</span>', subline: 'Wine, spirits and food pairing for grown-ups.', content: { screen: screen1Hero }, bgFrom: THUNDER, bgTo: PAPRIKA },
  { name: '02-quiz', headline: 'Find your <span class="accent">taste DNA</span>', subline: 'A 6-axis palate quiz that learns what you actually like.', content: { badge: 'Palate Quiz', screen: screen2Quiz }, bgFrom: '#3a0518', bgTo: PAPRIKA },
  { name: '03-scanner', headline: 'Scan any <span class="accent">label</span>', subline: 'Point. Read. Pair. On-device, 0.4 seconds.', content: { badge: 'Label Scanner', screen: screen3Scanner }, bgFrom: '#1a0808', bgTo: '#3a0a0a' },
  { name: '04-pairing', headline: 'What goes with <span class="accent">this?</span>', subline: 'Smart pairing for any dish, occasion or mood.', content: { badge: 'Bro Pairings', screen: screen4Pairing }, bgFrom: PAPRIKA, bgTo: '#5a002a' },
  { name: '05-brocard', headline: 'Every sip,<br/><span class="accent">remembered</span>', subline: 'Tasting journal that builds your palate over time.', content: { badge: 'BroCard Journal', screen: screen5BroCard }, bgFrom: THUNDER, bgTo: '#1a1717' },
  { name: '06-aromawheel', headline: 'Build a <span class="accent">real</span> palate', subline: 'Aroma wheel + radar that grows with every BroCard.', content: { badge: 'Aroma Wheel', screen: screen6AromaWheel }, bgFrom: '#3a2010', bgTo: PAPRIKA },
];

// ============= Feature graphic 1024×500 =============
function featureGraphicHTML() {
  return `<!doctype html><html><head><meta charset="utf-8">
  <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@900&family=Montserrat:wght@600;700&display=swap" rel="stylesheet">
  <style>
    * { box-sizing:border-box; margin:0; padding:0; }
    html, body { width:1024px; height:500px; overflow:hidden; }
    body { background: linear-gradient(120deg, ${THUNDER} 0%, ${PAPRIKA} 70%, #6b002a 100%); position:relative; font-family:'Montserrat', sans-serif; color:white; padding:60px 70px; display:flex; align-items:center; }
    body::before { content:''; position:absolute; inset:0; background-image: radial-gradient(circle at 90% 30%, rgba(212,162,76,0.25), transparent 40%), radial-gradient(circle at 10% 90%, rgba(15,128,68,0.18), transparent 35%); pointer-events:none; }
    .left { flex:1.3; z-index:2; }
    .right { flex:1; z-index:2; display:flex; align-items:center; justify-content:center; }
    h1 { font-family:'Playfair Display', serif; font-weight:900; font-size:88px; line-height:0.95; margin-bottom:20px; letter-spacing:-2px; text-shadow:0 4px 24px rgba(0,0,0,0.4); }
    .accent { color:${GOLD}; font-style:italic; }
    p.tag { font-size:24px; font-weight:600; opacity:0.92; line-height:1.35; max-width:520px; }
    .pill { display:inline-block; background:rgba(255,255,255,0.15); border:1px solid rgba(255,255,255,0.25); padding:10px 22px; border-radius:999px; font-weight:700; font-size:18px; letter-spacing:2px; text-transform:uppercase; margin-top:32px; backdrop-filter:blur(8px); }
    .glass { width:280px; height:380px; }
  </style></head><body>
    <div class="left">
      <h1>Your elder bro<br/>in <span class="accent">wine</span>.</h1>
      <p class="tag">Pair, scan, journal and grow your palate — wine, whisky, gin, rum and cocktails, all in one app.</p>
      <span class="pill">Wine · Spirits · Pairings</span>
    </div>
    <div class="right">
      <svg class="glass" viewBox="0 0 100 140" fill="none">
        <defs>
          <linearGradient id="wine" x1="0" y1="0" x2="0" y2="1"><stop offset="0%" stop-color="#c61856"/><stop offset="100%" stop-color="${PAPRIKA}"/></linearGradient>
          <radialGradient id="rim" cx="50%" cy="0%" r="60%"><stop offset="0%" stop-color="${GOLD}" stop-opacity="0.6"/><stop offset="100%" stop-color="${GOLD}" stop-opacity="0"/></radialGradient>
        </defs>
        <!-- bowl outline -->
        <path d="M 30 10 L 70 10 Q 80 10 80 30 Q 80 60 50 65 Q 20 60 20 30 Q 20 10 30 10 Z" fill="url(#wine)" stroke="${GOLD}" stroke-width="0.8" opacity="0.95"/>
        <!-- rim shine -->
        <ellipse cx="50" cy="14" rx="22" ry="3" fill="url(#rim)"/>
        <!-- stem -->
        <line x1="50" y1="65" x2="50" y2="115" stroke="${GOLD}" stroke-width="2"/>
        <!-- base -->
        <ellipse cx="50" cy="120" rx="22" ry="4" fill="none" stroke="${GOLD}" stroke-width="2"/>
        <!-- vine leaf -->
        <path d="M 75 35 Q 90 40 88 55 Q 85 50 78 50 Q 80 45 75 35 Z" fill="${SALEM}" opacity="0.85"/>
      </svg>
    </div>
  </body></html>`;
}

async function main() {
  if (!fs.existsSync(OUT_DIR)) fs.mkdirSync(OUT_DIR, { recursive: true });
  console.log('[gen] Output:', OUT_DIR);

  const browser = await chromium.launch({ headless: true, args: ['--no-sandbox'] });

  for (const sc of SCREENSHOTS) {
    const page = await browser.newPage({ viewport: { width: 1080, height: 1920 } });
    const html = shell(sc.content, { headline: sc.headline, subline: sc.subline, accent: PAPRIKA, bgFrom: sc.bgFrom, bgTo: sc.bgTo });
    await page.setContent(html, { waitUntil: 'networkidle' });
    // give Google Fonts a beat to apply
    await page.waitForTimeout(800);
    const out = path.join(OUT_DIR, `screenshot-${sc.name}.png`);
    await page.screenshot({ path: out, omitBackground: false, fullPage: false, clip: { x: 0, y: 0, width: 1080, height: 1920 } });
    await page.close();
    console.log('[gen] wrote', out);
  }

  // Feature graphic
  const fgPage = await browser.newPage({ viewport: { width: 1024, height: 500 } });
  await fgPage.setContent(featureGraphicHTML(), { waitUntil: 'networkidle' });
  await fgPage.waitForTimeout(800);
  const fgOut = path.join(OUT_DIR, 'feature-graphic.png');
  await fgPage.screenshot({ path: fgOut, clip: { x: 0, y: 0, width: 1024, height: 500 } });
  await fgPage.close();
  console.log('[gen] wrote', fgOut);

  await browser.close();
  console.log('[gen] Done.');
}

main().catch((e) => { console.error('[gen] FAIL:', e); process.exit(1); });
