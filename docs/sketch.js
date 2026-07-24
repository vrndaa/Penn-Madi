// Penn-madi — p5.js port of STATIC_EXPERIMENTATION copy.pde
// Press SPACE (or 1 / 2), or tap the pill top-right, to switch pages.

let table;
let drawRows = [];
let page = 1;

let INNER = 60; // equal inner margin on all four sides
let dividerX, leftColX, leftColRight, rightColX, rightColRight;

let BG, INK, SUBINK, BOXLINE, THREAD, IKAT_PINK, IKAT_LIGHT;
let metricBase = [];
const measureNames = [
  "Women literate", "10+ yrs of schooling", "Attended school (age 6+)",
  "Worked & paid in cash", "Owns a house / land", "Bank / savings account"
];

const headingFont = 'Georgia, "Times New Roman", serif';
const bodyFont = 'Helvetica, Arial, sans-serif';

let segs = [];

function preload() {
  table = loadTable("Urban Rural Data Cleaned.csv", "csv", "header");
}

function setup() {
  createCanvas(windowWidth, windowHeight);
  pixelDensity(displayDensity());

  BG = color(235, 226, 202);
  INK = color(45, 38, 30);
  SUBINK = color(95, 84, 66);
  BOXLINE = color(203, 189, 152);
  THREAD = color(250, 244, 230);
  IKAT_PINK = color(224, 66, 140);
  IKAT_LIGHT = color(248, 216, 230);

  metricBase = [
    color(200, 45, 60),   // literate  - red
    color(150, 80, 165),  // schooling - purple
    color(235, 110, 55),  // attended  - orange
    color(30, 100, 100),  // cash      - teal
    color(170, 50, 105),  // house     - wine
    color(90, 60, 140)    // bank      - indigo
  ];

  computeLayout();
  buildRows();
}

function windowResized() {
  resizeCanvas(windowWidth, windowHeight);
  computeLayout();
}

function computeLayout() {
  dividerX      = width * 0.40;
  leftColX      = INNER;
  leftColRight  = dividerX - 34;
  rightColX     = dividerX + 34;
  rightColRight = width - INNER;
}

function buildRows() {
  drawRows = [];
  for (let i = 0; i < table.getRowCount(); i++) {
    const row = table.getRow(i);
    const state = (row.getString(0) || "").trim();
    let abbr = row.getString("Abbreviation");
    abbr = abbr ? abbr.trim() : "";
    if (state.toLowerCase() === "india" || abbr.toLowerCase() === "ind") continue;
    drawRows.push(row);
  }
}

// Page 2's tone scheme: rural = darker tone, urban = lighter tone.
// Page 1 uses metricBase directly (flat, same hue for both urban and rural).
function rural(base) { return lerpColor(base, color(0), 0.30); }
function urban(base) { return lerpColor(base, color(255), 0.33); }

function keyPressed() {
  if (key === " ") page = (page === 1) ? 2 : 1;
  else if (key === "1") page = 1;
  else if (key === "2") page = 2;
}

function mousePressed() {
  const p = pillBounds();
  if (mouseX >= p.x && mouseX <= p.x + p.w && mouseY >= p.y && mouseY <= p.y + p.h) {
    page = (page === 1) ? 2 : 1;
  }
}

function draw() {
  background(BG);
  segs = [];
  drawIkatBorder();
  drawHeading();
  drawLegend();
  drawSections();
  drawPageIndicator();
  drawTooltip();
}

// ---- Pink ikat border around the page -------------------------------------
function drawIkatBorder() {
  const bw = 30;
  noStroke();
  fill(IKAT_PINK);
  rect(0, 0, width, bw);
  rect(0, height - bw, width, bw);
  rect(0, 0, bw, height);
  rect(width - bw, 0, bw, height);

  const d = bw * 0.72;
  for (let cx = bw; cx < width - bw + 1; cx += bw) {
    diamond(cx, bw / 2, d);
    diamond(cx, height - bw / 2, d);
  }
  for (let cy = bw; cy < height - bw + 1; cy += bw) {
    diamond(bw / 2, cy, d);
    diamond(width - bw / 2, cy, d);
  }
}

function diamond(cx, cy, s) {
  noStroke();
  fill(IKAT_LIGHT);
  quad(cx, cy - s / 2, cx + s / 2, cy, cx, cy + s / 2, cx - s / 2, cy);
  fill(IKAT_PINK);
  const t = s * 0.42;
  quad(cx, cy - t / 2, cx + t / 2, cy, cx, cy + t / 2, cx - t / 2, cy);
}

// Small "page 1/2" pill + toggle hint, top-right inside the border
function pillBounds() {
  const pw = 86, ph = 30;
  const px = width - INNER - pw;
  const py = INNER * 0.4;
  return { x: px, y: py, w: pw, h: ph };
}

function drawPageIndicator() {
  const p = pillBounds();
  noStroke();
  fill(IKAT_PINK);
  rect(p.x, p.y, p.w, p.h, p.h / 2);
  fill(255);
  textFont(bodyFont);
  textStyle(NORMAL);
  textAlign(CENTER, CENTER);
  textSize(14);
  text(page + " / 2", p.x + p.w / 2, p.y + p.h / 2 + 1);

  fill(SUBINK);
  textAlign(CENTER, TOP);
  textSize(10);
  text("space / tap", p.x + p.w / 2, p.y + p.h + 4);
}

// ---- Left column: title + description --------------------------------------
function drawHeading() {
  const sz = 40;
  const titleY = INNER;
  textAlign(LEFT, TOP);

  fill(INK);
  textFont(headingFont);
  textStyle(ITALIC);
  textSize(sz);
  const w1 = textWidth("Penn");
  text("Penn", leftColX, titleY);
  textStyle(NORMAL);
  text("-madi", leftColX + w1, titleY);

  const desc =
    "Penn-madi maps six measures of women's lives — literacy, years of schooling, school " +
    "attendance, paid work, property ownership, and bank accounts — for every state and union " +
    "territory of India. Each box is one state, split down the middle: urban on the left, rural " +
    "on the right. Within each half the six measures are woven together into one cloth. Hover " +
    "over any band to read its value.";
  fill(SUBINK);
  textFont(bodyFont);
  textSize(15);
  text(desc, leftColX, titleY + 52, leftColRight - leftColX, 220);
}

// ---- Left column: how-to-read legend ---------------------------------------
function drawLegend() {
  const lx = leftColX;
  const lw = leftColRight - leftColX;
  let y = height * 0.44;
  const page1 = (page === 1);

  fill(INK);
  textAlign(LEFT, TOP);
  textFont(headingFont);
  textStyle(NORMAL);
  textSize(22);
  text("how to read", lx, y);
  y += 40;

  textFont(bodyFont);
  fill(SUBINK);
  textSize(13);
  const how = page1
    ? "Every state is a small woven cloth: the left half is urban, the right half is rural, " +
      "joined edge to edge with the rest of the mat. In each half the six measures are stacked " +
      "and normalized to fill it. Hover to see exactly what you're touching."
    : "Each box is one state — the left half is urban, the right half is rural, separated so you " +
      "can explore each one on its own. In each half the six measures are stacked and normalized " +
      "to fill it, so you compare the mix of women's outcomes, urban vs rural.";
  text(how, lx, y, lw, 90);
  y += 88;

  fill(INK);
  textSize(13);
  text(page1 ? "The six measures" : "The six measures   ·   urban / rural tone", lx, y);
  y += 24;
  for (let m = 0; m < 6; m++) y = legendRow(lx, y, measureNames[m], metricBase[m], page1);

  y += 12;
  fill(SUBINK);
  textSize(12);
  text("Hover over any band to read its exact value.", lx, y, lw, 40);
}

function legendRow(lx, y, label, base, flat) {
  noStroke();
  let textX;
  if (flat) {
    fill(base); rect(lx, y + 1, 16, 12);
    textX = lx + 26;
  } else {
    fill(urban(base)); rect(lx, y + 1, 16, 12);       // urban (lighter) = left half
    fill(rural(base)); rect(lx + 18, y + 1, 16, 12);   // rural (darker) = right half
    textX = lx + 44;
  }
  fill(INK);
  textAlign(LEFT, TOP);
  textSize(13);
  text(label, textX, y);
  return y + 22;
}

// ---- The visualization (right column): a grid of split state boxes ---------
function drawSections() {
  const n = drawRows.length;
  const cols = ceil(sqrt(n));
  const rows = ceil(n / cols);

  const availW = rightColRight - rightColX;
  const availH = (height - INNER) - INNER;
  // Cells stay square — take the tighter of the two fits, then center the
  // grid in whichever direction has leftover room (fixes stretched boxes
  // when the browser window's aspect ratio doesn't match a 6-ish-by-6 grid).
  const cellSize = min(availW / cols, availH / rows);
  const cellW = cellSize;
  const cellH = cellSize;
  const gridX = rightColX + (availW - cols * cellSize) / 2;
  const gridY = INNER + (availH - rows * cellSize) / 2;

  for (let i = 0; i < n; i++) {
    const row = drawRows[i];
    const cx = gridX + (i % cols) * cellW;
    const cy = gridY + floor(i / cols) * cellH;
    drawStateBox(row, cx, cy, cellW, cellH);
  }

  if (page === 1) {
    drawStitchLattice(gridX, gridY, cols, rows, cellW, cellH);
  }
}

function drawStateBox(row, cx, cy, cw, ch) {
  const page1 = (page === 1);
  const state = (row.getString(0) || "").trim();
  const nameH = 15;
  const pad = page1 ? 0 : 3;
  const bx = cx + pad;
  const by = cy + nameH;
  const bw = cw - pad * 2;
  const bh = ch - nameH - pad;

  // name above the box
  fill(INK);
  textAlign(LEFT, TOP);
  textFont(bodyFont);
  textStyle(NORMAL);
  drawFittedName(displayName(state), bx, cy + 1, bw);

  // urban = odd columns (3,5,7,9,11,13), rural = even (2,4,6,8,10,12)
  const urbanVals = [3, 5, 7, 9, 11, 13].map((c) => row.getNum(c));
  const ruralVals = [2, 4, 6, 8, 10, 12].map((c) => row.getNum(c));

  const halfW = bw / 2;
  const useTone = !page1; // page 1 = flat hue for both halves; page 2 = urban lighter / rural darker
  drawHalf(urbanVals, bx, by, halfW, bh, state, "Urban", useTone);
  drawHalf(ruralVals, bx + halfW, by, bw - halfW, bh, state, "Rural", useTone);

  if (!page1) {
    // page 2: boxes are separated — faint outline, plus a small stitch at the urban/rural seam
    noFill();
    stroke(BOXLINE);
    strokeWeight(1);
    rect(bx, by, bw, bh);

    stroke(THREAD);
    strokeWeight(0.6);
    stitchLine(bx + halfW, by, bx + halfW, by + bh, 3, 3);
  }
}

// One half = the six measures stacked and normalized to fill the height.
// useTone: true = page 2's urban-lighter/rural-darker tone; false = page 1's flat metricBase hue.
function drawHalf(vals, hx, hy, hw, hh, state, pop, useTone) {
  let sum = 0;
  for (const v of vals) sum += v;
  if (sum <= 0) return;

  let yy = hy;
  noStroke();
  for (let m = 0; m < 6; m++) {
    const segH = (vals[m] / sum) * hh;
    const c = useTone ? (pop === "Urban" ? urban(metricBase[m]) : rural(metricBase[m])) : metricBase[m];
    fill(c);
    rect(hx, yy, hw, segH);
    segs.push({ x: hx, y: yy, w: hw, h: segH, state, pop, label: measureNames[m], value: vals[m] });
    yy += segH;
  }
}

// Page 1: a running-stitch lattice over the shared seams between joined state boxes,
// so the whole grid reads as one stitched mat rather than separate tiles.
function drawStitchLattice(left, top, cols, rows, cw, ch) {
  stroke(THREAD);
  strokeWeight(0.8);
  const right = left + cols * cw;
  const bottom = top + rows * ch;
  for (let c = 0; c <= cols; c++) {
    stitchLine(left + c * cw, top, left + c * cw, bottom, 5, 4);
  }
  for (let r = 0; r <= rows; r++) {
    stitchLine(left, top + r * ch, right, top + r * ch, 5, 4);
  }
}

// A dashed running-stitch line with configurable dash/gap length
function stitchLine(x1, y1, x2, y2, dash, gap) {
  const d = dist(x1, y1, x2, y2);
  if (d <= 0) return;
  const ux = (x2 - x1) / d;
  const uy = (y2 - y1) / d;
  for (let t = 0; t < d; t += dash + gap) {
    const et = min(t + dash, d);
    line(x1 + ux * t, y1 + uy * t, x1 + ux * et, y1 + uy * et);
  }
}

// Shorten the longest names so they stay legible above the box
function displayName(full) {
  if (full.indexOf("Andaman") >= 0) return "Andaman";
  if (full.indexOf("Dadra") >= 0) return "Dadra & N.H.";
  return full;
}

// Draw a name, shrinking the size until it fits the box width
function drawFittedName(name, x, y, maxW) {
  let ts = 9.5;
  while (ts > 6) {
    textSize(ts);
    if (textWidth(name) <= maxW) break;
    ts -= 0.5;
  }
  textSize(ts);
  text(name, x, y);
}

// Tooltip for whichever filled band the mouse (or a touch) is over
function drawTooltip() {
  let hit = null;
  for (const s of segs) {
    if (mouseX >= s.x && mouseX <= s.x + s.w && mouseY >= s.y && mouseY <= s.y + s.h) {
      hit = s;
      break;
    }
  }
  if (!hit) return;

  const l1 = hit.state + " · " + hit.pop;
  const l2 = hit.label + ": " + nf(hit.value, 0, 1) + "%";
  textFont(bodyFont);
  textStyle(NORMAL);
  textAlign(LEFT, TOP);
  textSize(12);
  const boxW = max(textWidth(l1), textWidth(l2)) + 12;
  const boxH = 38;
  let tx = mouseX + 12;
  let ty = mouseY + 12;
  if (tx + boxW > width) tx = mouseX - boxW - 12;
  if (ty + boxH > height) ty = mouseY - boxH - 12;

  stroke(INK);
  strokeWeight(1);
  fill(250, 244, 232);
  rect(tx, ty, boxW, boxH);
  fill(INK);
  text(l1, tx + 6, ty + 5);
  text(l2, tx + 6, ty + 20);
}
