// Penn-madi — p5.js port of STATIC_EXPERIMENTATION copy.pde
// Press SPACE (or 1 / 2), or tap the pill top-right, to switch pages.

let table;
let drawRows = [];
let page = 1;

let INNER = 60; // equal inner margin on all four sides
let dividerX, leftColX, leftColRight, rightColX, rightColRight;

let BG, INK, SUBINK, THREAD, IKAT_BROWN, IKAT_LIGHT;
let TOOLTIP_INK; // tooltip stays dark-on-light regardless of page theme
let metricBase = [];
const measureNames = [
  "Women literate", "10+ yrs of schooling", "Attended school (age 6+)",
  "Worked & paid in cash", "Owns a house / land", "Bank / savings account"
];

// Real embedded font files for the heading — p5's textFont() can silently fail
// on a CSS font-family string that mixes commas and quotes (e.g. 'Georgia,
// "Times New Roman", serif'), falling back to the browser default with no
// warning. Loading actual .ttf files sidesteps that entirely and guarantees
// the same look on every browser, matching the Processing version's real
// italic/regular font objects.
let headingFontRegular, headingFontItalic;
const bodyFont = "Helvetica, Arial, sans-serif";

let segs = [];

function preload() {
  table = loadTable("Urban Rural Data Cleaned.csv", "csv", "header");
  headingFontRegular = loadFont("fonts/PlayfairDisplay-Regular.ttf");
  headingFontItalic = loadFont("fonts/PlayfairDisplay-Italic.ttf");
}

function setup() {
  createCanvas(windowWidth, windowHeight);
  pixelDensity(displayDensity());

  BG = color(235, 226, 202);
  INK = color(45, 38, 30);
  SUBINK = color(95, 84, 66);
  THREAD = color(250, 244, 230);
  IKAT_BROWN = color(224, 66, 140);
  IKAT_LIGHT = color(248, 216, 230);
  TOOLTIP_INK = color(30, 26, 20); // tooltip text/border stay dark regardless of page theme

  metricBase = [
    color(196, 63, 114),   // literate
    color(201, 141, 187),  // schooling
    color(199, 122, 78),   // attended
    color(61, 118, 108),   // cash
    color(201, 149, 76),   // house
    color(92, 78, 130)     // bank
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

// Page 2's tone scheme: urban = a lighter tone of the hue, rural = a darker tone.
// Page 1 uses metricBase directly (flat, same hue for both urban and rural).
function urbanTone(base) { return lerpColor(base, color(255), 0.33); }
function ruralTone(base) { return lerpColor(base, color(0), 0.30); }

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

// ---- Simple double-line border around the page ----------------------------
function drawIkatBorder() {
  const outer = 14;
  stroke(IKAT_BROWN);
  strokeWeight(outer);
  noFill();
  rect(outer / 2, outer / 2, width - outer, height - outer);

  stroke(IKAT_LIGHT);
  strokeWeight(3);
  const inset = 20;
  rect(inset, inset, width - inset * 2, height - inset * 2);
}

// Small "page 1/2" pill + toggle hint, top-right inside the border
function pillBounds() {
  const pw = 56, ph = 26;
  const px = width - INNER - pw;
  const py = INNER * 0.5;
  return { x: px, y: py, w: pw, h: ph };
}

function drawPageIndicator() {
  const p = pillBounds();
  noStroke();
  fill(IKAT_BROWN);
  rect(p.x, p.y, p.w, p.h, p.h / 2);
  fill(255);
  textFont(bodyFont);
  textStyle(NORMAL);
  textAlign(CENTER, CENTER);
  textSize(13);
  text(page + " / 2", p.x + p.w / 2, p.y + p.h / 2 + 1);
}

// ---- Left column: title + description --------------------------------------
function drawHeading() {
  const sz = 40;
  const titleY = INNER;
  textAlign(LEFT, TOP);

  fill(INK);
  textFont(headingFontItalic);
  textSize(sz);
  const w1 = textWidth("Penn");
  text("Penn", leftColX, titleY);
  textFont(headingFontRegular);
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
  text(desc, leftColX, titleY + 92, leftColRight - leftColX, 220);
}

// ---- Left column: how-to-read legend ---------------------------------------
function drawLegend() {
  const lx = leftColX;
  const lw = leftColRight - leftColX;
  let y = height * 0.44;
  const page1 = (page === 1);

  fill(INK);
  textAlign(LEFT, TOP);
  textFont(headingFontRegular);
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
    fill(urbanTone(base)); rect(lx, y + 1, 16, 12);        // urban (lighter) = left half
    fill(ruralTone(base)); rect(lx + 18, y + 1, 16, 12);   // rural (darker) = right half
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
  // Fill the whole available region edge-to-edge (no leftover gap between the
  // grid and the border). 36 states = a full 6x6 grid, so cells divide evenly.
  const cellW = availW / cols;
  const cellH = availH / rows;
  const gridX = rightColX;
  const gridY = INNER;

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
  const pad = page1 ? 0 : 3;
  const bx = cx + pad;
  const by = cy + pad;
  const bw = cw - pad * 2;
  const bh = ch - pad * 2;

  // urban = odd columns (3,5,7,9,11,13), rural = even (2,4,6,8,10,12)
  const urbanVals = [3, 5, 7, 9, 11, 13].map((c) => row.getNum(c));
  const ruralVals = [2, 4, 6, 8, 10, 12].map((c) => row.getNum(c));

  const halfW = bw / 2;
  const useTone = !page1; // page 1 = flat hue for both halves; page 2 = urban lighter / rural darker
  drawHalf(urbanVals, bx, by, halfW, bh, state, "Urban", useTone);
  drawHalf(ruralVals, bx + halfW, by, bw - halfW, bh, state, "Rural", useTone);

  if (!page1) {
    // page 2: boxes are separated — a running-stitch border all the way
    // around each box, plus a small stitch at the urban/rural seam
    stroke(THREAD);
    strokeWeight(0.7);
    stitchLine(bx, by, bx + bw, by, 4, 3);           // top
    stitchLine(bx + bw, by, bx + bw, by + bh, 4, 3); // right
    stitchLine(bx + bw, by + bh, bx, by + bh, 4, 3); // bottom
    stitchLine(bx, by + bh, bx, by, 4, 3);           // left

    strokeWeight(0.6);
    stitchLine(bx + halfW, by, bx + halfW, by + bh, 3, 3);
  }
}

// One half = the six measures stacked and normalized to fill the height.
// useTone: true = page 2's urban-lighter/rural-darker tone; false = page 1's flat metricBase hue.
const ZERO_GAP = 4; // fixed height reserved for a zero-valued measure, painted as background

function drawHalf(vals, hx, hy, hw, hh, state, pop, useTone) {
  let sum = 0;
  let zeroCount = 0;
  for (const v of vals) {
    sum += v;
    if (v <= 0) zeroCount++;
  }
  if (sum <= 0) return;

  const reserved = zeroCount * ZERO_GAP;
  const usableH = hh - reserved;

  let yy = hy;
  noStroke();
  for (let m = 0; m < 6; m++) {
    let segH, c;
    if (vals[m] <= 0) {
      segH = ZERO_GAP;
      c = BG; // zero value: same colour as the page background, not a collapsed 0px band
    } else {
      segH = (vals[m] / sum) * usableH;
      c = useTone ? (pop === "Urban" ? urbanTone(metricBase[m]) : ruralTone(metricBase[m])) : metricBase[m];
    }
    fill(c);
    rect(hx, yy, hw, segH);
    segs.push({ x: hx, y: yy, w: hw, h: segH, state, pop, label: measureNames[m], value: vals[m], col: c });
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
  const l2 = hit.label;
  const l3 = nf(hit.value, 0, 1) + "%";

  textFont(bodyFont);
  textStyle(NORMAL);
  textAlign(LEFT, TOP);
  const swatch = 10, gapAfterSwatch = 7;
  textSize(11);
  const w1 = textWidth(l1);
  textSize(13);
  const w2 = swatch + gapAfterSwatch + textWidth(l2 + "   " + l3);

  const padX = 11, padY = 9;
  const boxW = max(w1, w2) + padX * 2;
  const boxH = 42;
  let tx = mouseX + 14;
  let ty = mouseY + 14;
  if (tx + boxW > width) tx = mouseX - boxW - 14;
  if (ty + boxH > height) ty = mouseY - boxH - 14;

  noStroke();
  fill(0, 0, 0, 60); // soft shadow instead of a hard border
  rect(tx + 2, ty + 3, boxW, boxH, 9);

  fill(250, 245, 236);
  rect(tx, ty, boxW, boxH, 9);

  fill(TOOLTIP_INK);
  textSize(11);
  text(l1, tx + padX, ty + padY - 2);

  noStroke();
  fill(hit.col);
  rect(tx + padX, ty + padY + 15, swatch, swatch, 2);

  fill(TOOLTIP_INK);
  textSize(13);
  text(l2 + "   " + l3, tx + padX + swatch + gapAfterSwatch, ty + padY + 12);
}
