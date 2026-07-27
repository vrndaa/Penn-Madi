import java.awt.Font; // for the italic heading face

Table table;

// Rows we actually draw (India / IND filtered out)
java.util.ArrayList<TableRow> drawRows;

// Fonts
PFont bodyFont;
PFont headingFont;
PFont headingItalicFont;

// Which of the two pages is showing. 1 = joined pai (flat hues, stitched lattice),
// 2 = exploratory split boxes (tone-differentiated, separated, small urban/rural stitch).
// Press SPACE (or 1 / 2) to switch — this maps directly to a tab/toggle button on the web.
int page = 1;

// Page layout (computed in setup once the screen size is known)
float INNER = 60;   // equal inner margin on all four sides
float dividerX, leftColX, leftColRight, rightColX, rightColRight;

// Page theme (beige cloth ground; dark thread for text)
color BG     = color(34, 34, 34);
color INK    = color(255, 255, 255);
color SUBINK = color(255, 255, 255);
color BOXLINE = color(203, 189, 152); // faint outline around each state box (page 2 only)
color THREAD  = color(250, 244, 230); // stitching thread color (reads on any fill hue)
color TOOLTIP_INK = color(30, 26, 20); // tooltip text/border stay dark regardless of page theme

// Ikat border palette (brown)
color IKAT_BROWN = color(130, 25, 75);
color IKAT_LIGHT = color(248, 216, 230);

// One hue per measure (order: literate, schooling, attended, cash, house/land, bank)
color[] metricBase;
String[] measureNames = {
  "Women literate", "10+ yrs of schooling", "Attended school (age 6+)",
  "Worked & paid in cash", "Owns a house / land", "Bank / savings account"
};

// Page 2's tone scheme: urban keeps the base hue (same as page 1), rural is a
// lightened version of it. Page 1 uses metricBase directly for both halves.
color lighten(color base) { return lerpColor(base, color(255), 0.42); }

// Filled segments recorded each frame so we can show a tooltip on hover
class Seg {
  float x, y, w, h;
  String state, pop, label;
  float value;
  color col;
  Seg(float x, float y, float w, float h, String state, String pop, String label, float value, color col) {
    this.x = x; this.y = y; this.w = w; this.h = h;
    this.state = state; this.pop = pop; this.label = label; this.value = value; this.col = col;
  }
}
java.util.ArrayList<Seg> segs = new java.util.ArrayList<Seg>();

void setup() {
  fullScreen();                   // artboard fills the whole screen
  pixelDensity(displayDensity()); // render at the screen's real density
  smooth(8);

  bodyFont = createFont("SansSerif", 32, true);
  headingFont = createFont("Serif", 48, true);
  headingItalicFont = new PFont(new Font("Serif", Font.ITALIC, 48), true);

  // Two-column layout: text on the left, visualization on the right
  dividerX      = width * 0.40;
  leftColX      = INNER;
  leftColRight  = dividerX - 34;
  rightColX     = dividerX + 34;
  rightColRight = width - INNER;

  // Measure hues
  metricBase = new color[6];
  metricBase[0] = color(238, 25, 115);  // literate
  metricBase[1] = color(238, 177, 211); // schooling
  metricBase[2] = color(236, 110, 56);  // attended
  metricBase[3] = color(29, 100, 100);  // cash
  metricBase[4] = color(252, 179, 31);  // house
  metricBase[5] = color(91, 60, 141);   // bank

  table = loadTable("Urban Rural Data Cleaned.csv", "header");

  drawRows = new java.util.ArrayList<TableRow>();
  for (int i = 0; i < table.getRowCount(); i++) {
    TableRow row = table.getRow(i);
    String state = trim(row.getString(0));
    String abbr = row.getString("Abbreviation");
    abbr = (abbr == null) ? "" : trim(abbr);
    if (state.equalsIgnoreCase("India") || abbr.equalsIgnoreCase("IND")) continue;
    drawRows.add(row);
  }
}

void keyPressed() {
  if (key == ' ') page = (page == 1) ? 2 : 1;
  else if (key == '1') page = 1;
  else if (key == '2') page = 2;
}

void draw() {
  background(BG);
  segs.clear();
  drawIkatBorder();
  drawHeading();
  drawLegend();
  drawSections();
  drawPageIndicator();
  drawTooltip();
}

// ---- Brown ikat border around the page ------------------------------------
void drawIkatBorder() {
  float bw = 30;
  noStroke();
  fill(IKAT_BROWN);
  rect(0, 0, width, bw);
  rect(0, height - bw, width, bw);
  rect(0, 0, bw, height);
  rect(width - bw, 0, bw, height);

  float d = bw * 0.72;
  for (float cx = bw; cx < width - bw + 1; cx += bw) {
    diamond(cx, bw / 2, d);
    diamond(cx, height - bw / 2, d);
  }
  for (float cy = bw; cy < height - bw + 1; cy += bw) {
    diamond(bw / 2, cy, d);
    diamond(width - bw / 2, cy, d);
  }
}

void diamond(float cx, float cy, float s) {
  noStroke();
  fill(IKAT_LIGHT);
  quad(cx, cy - s / 2, cx + s / 2, cy, cx, cy + s / 2, cx - s / 2, cy);
  fill(IKAT_BROWN);
  float t = s * 0.42;
  quad(cx, cy - t / 2, cx + t / 2, cy, cx, cy + t / 2, cx - t / 2, cy);
}

// Small "page 1/2" pill + toggle hint, top-right inside the border
void drawPageIndicator() {
  float pw = 86, ph = 30;
  float px = width - INNER - pw;
  float py = INNER * 0.4;
  noStroke();
  fill(IKAT_BROWN);
  rect(px, py, pw, ph, ph / 2);
  fill(255);
  textFont(bodyFont);
  textAlign(CENTER, CENTER);
  textSize(14);
  text(page + " / 2", px + pw / 2, py + ph / 2 + 1);

  fill(SUBINK);
  textAlign(CENTER, TOP);
  textSize(10);
  text("space / tap", px + pw / 2, py + ph + 4);
}

// ---- Left column: title + description --------------------------------------
void drawHeading() {
  float sz = 40;
  float titleY = INNER;
  textAlign(LEFT, TOP);

  fill(INK);
  textFont(headingItalicFont);
  textSize(sz);
  float w1 = textWidth("Penn");
  text("Penn", leftColX, titleY);
  textFont(headingFont);
  textSize(sz);
  text("-madi", leftColX + w1, titleY);

  String desc =
    "Penn-madi maps six measures of women's lives — literacy, years of schooling, school "
    + "attendance, paid work, property ownership, and bank accounts — for every state and union "
    + "territory of India. Each box is one state, split down the middle: urban on the left, rural "
    + "on the right. Within each half the six measures are woven together into one cloth. Hover "
    + "over any band to read its value.";
  fill(SUBINK);
  textFont(bodyFont);
  textSize(15);
  text(desc, leftColX, titleY + 92, leftColRight - leftColX, 220);
}

// ---- Left column: how-to-read legend ---------------------------------------
void drawLegend() {
  float lx = leftColX;
  float lw = leftColRight - leftColX;
  float y = height * 0.44;
  boolean page1 = (page == 1);

  fill(INK);
  textAlign(LEFT, TOP);
  textFont(headingFont);
  textSize(22);
  text("how to read", lx, y);
  y += 40;

  textFont(bodyFont);
  fill(SUBINK);
  textSize(13);
  String how = page1
    ? "Every state is a small woven cloth: the left half is urban, the right half is rural, "
      + "joined edge to edge with the rest of the mat. In each half the six measures are stacked "
      + "and normalized to fill it. Hover to see exactly what you're touching."
    : "Each box is one state — the left half is urban, the right half is rural, separated so you "
      + "can explore each one on its own. In each half the six measures are stacked and normalized "
      + "to fill it, so you compare the mix of women's outcomes, urban vs rural.";
  text(how, lx, y, lw, 90);
  y += 88;

  fill(INK);
  textSize(13);
  text(page1 ? "The six measures" : "The six measures   ·   urban / rural tone", lx, y);
  y += 24;
  for (int m = 0; m < 6; m++) y = legendRow(lx, y, measureNames[m], metricBase[m], page1);

  y += 12;
  fill(SUBINK);
  textSize(12);
  text("Hover over any band to read its exact value.", lx, y, lw, 40);
}

float legendRow(float lx, float y, String label, color base, boolean flat) {
  noStroke();
  float textX;
  if (flat) {
    fill(base); rect(lx, y + 1, 16, 12);
    textX = lx + 26;
  } else {
    fill(base);          rect(lx, y + 1, 16, 12);        // urban = base hue = left half
    fill(lighten(base)); rect(lx + 18, y + 1, 16, 12);   // rural = lightened = right half
    textX = lx + 44;
  }
  fill(INK);
  textAlign(LEFT, TOP);
  textSize(13);
  text(label, textX, y);
  return y + 22;
}

// ---- The visualization (right column): a grid of split state boxes ---------
void drawSections() {
  int n = drawRows.size();
  int cols = ceil(sqrt(n));
  int rows = ceil((float) n / cols);

  float availW = rightColRight - rightColX;
  float availH = (height - INNER) - INNER;
  // Fill the whole available region edge-to-edge (no leftover gap between the
  // grid and the border). 36 states = a full 6x6 grid, so cells divide evenly.
  float cellW = availW / cols;
  float cellH = availH / rows;
  float gridX = rightColX;
  float gridY = INNER;

  for (int i = 0; i < n; i++) {
    TableRow row = drawRows.get(i);
    float cx = gridX + (i % cols) * cellW;
    float cy = gridY + (i / cols) * cellH;
    drawStateBox(row, cx, cy, cellW, cellH);
  }

  if (page == 1) {
    drawStitchLattice(gridX, gridY, cols, rows, cellW, cellH);
  }
}

void drawStateBox(TableRow row, float cx, float cy, float cw, float ch) {
  boolean page1 = (page == 1);
  String state = trim(row.getString(0));
  float pad = page1 ? 0 : 3;
  float nameH = page1 ? 0 : 16; // page 2 only: a header strip above the box for the state name
  float bx = cx + pad;
  float by = cy + pad + nameH;
  float bw = cw - pad * 2;
  float bh = ch - pad * 2 - nameH;

  if (!page1) {
    fill(INK);
    textAlign(LEFT, TOP);
    textFont(bodyFont);
    drawFittedName(displayName(state), bx, cy + pad, bw);
  }

  // urban = odd columns (3,5,7,9,11,13), rural = even (2,4,6,8,10,12)
  float[] urbanVals = { row.getFloat(3), row.getFloat(5), row.getFloat(7), row.getFloat(9), row.getFloat(11), row.getFloat(13) };
  float[] ruralVals = { row.getFloat(2), row.getFloat(4), row.getFloat(6), row.getFloat(8), row.getFloat(10), row.getFloat(12) };

  float halfW = bw / 2;
  boolean useTone = !page1; // page 1 = flat hue for both halves; page 2 = urban base / rural lightened
  drawHalf(urbanVals, bx, by, halfW, bh, state, "Urban", useTone);                 // left
  drawHalf(ruralVals, bx + halfW, by, bw - halfW, bh, state, "Rural", useTone);    // right, no gap

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
float ZERO_GAP = 4; // fixed height reserved for a zero-valued measure, painted as background

void drawHalf(float[] vals, float hx, float hy, float hw, float hh, String state, String pop, boolean useTone) {
  float sum = 0;
  int zeroCount = 0;
  for (float v : vals) {
    sum += v;
    if (v <= 0) zeroCount++;
  }
  if (sum <= 0) return;

  float reserved = zeroCount * ZERO_GAP;
  float usableH = hh - reserved;

  float yy = hy;
  noStroke();
  for (int m = 0; m < 6; m++) {
    float segH;
    color c;
    if (vals[m] <= 0) {
      segH = ZERO_GAP;
      c = BG; // zero value: same colour as the page background, not a collapsed 0px band
    } else {
      segH = vals[m] / sum * usableH;
      // page 2: urban = the plain measure hue (same as page 1), rural = a lightened tint of it
      c = useTone ? (pop.equals("Urban") ? metricBase[m] : lighten(metricBase[m])) : metricBase[m];
    }
    fill(c);
    rect(hx, yy, hw, segH);
    segs.add(new Seg(hx, yy, hw, segH, state, pop, measureNames[m], vals[m], c));
    yy += segH;
  }
}

// Page 1: a running-stitch lattice over the shared seams between joined state boxes,
// so the whole grid reads as one stitched mat rather than separate tiles.
void drawStitchLattice(float left, float top, int cols, int rows, float cw, float ch) {
  stroke(THREAD);
  strokeWeight(0.8);
  float right = left + cols * cw;
  float bottom = top + rows * ch;
  for (int c = 0; c <= cols; c++) {
    stitchLine(left + c * cw, top, left + c * cw, bottom, 5, 4);
  }
  for (int r = 0; r <= rows; r++) {
    stitchLine(left, top + r * ch, right, top + r * ch, 5, 4);
  }
}

// A dashed running-stitch line with configurable dash/gap length
void stitchLine(float x1, float y1, float x2, float y2, float dash, float gap) {
  float d = dist(x1, y1, x2, y2);
  if (d <= 0) return;
  float ux = (x2 - x1) / d;
  float uy = (y2 - y1) / d;
  for (float t = 0; t < d; t += dash + gap) {
    float et = min(t + dash, d);
    line(x1 + ux * t, y1 + uy * t, x1 + ux * et, y1 + uy * et);
  }
}

// Page 2 only: shorten the longest names so they stay legible above the box
String displayName(String full) {
  if (full.indexOf("Andaman") >= 0) return "Andaman";
  if (full.indexOf("Dadra") >= 0) return "Dadra & N.H.";
  return full;
}

// Page 2 only: draw a name above the box, shrinking the size until it fits
void drawFittedName(String name, float x, float y, float maxW) {
  float ts = 11;
  while (ts > 7) {
    textSize(ts);
    if (textWidth(name) <= maxW) break;
    ts -= 0.5;
  }
  textSize(ts);
  text(name, x, y);
}

// Tooltip for whichever filled band the mouse is over
void drawTooltip() {
  Seg hit = null;
  for (Seg s : segs) {
    if (mouseX >= s.x && mouseX <= s.x + s.w && mouseY >= s.y && mouseY <= s.y + s.h) {
      hit = s;
      break;
    }
  }
  if (hit == null) return;

  String l1 = hit.state + " · " + hit.pop;
  String l2 = hit.label;
  String l3 = nf(hit.value, 0, 1) + "%";

  textFont(bodyFont);
  textAlign(LEFT, TOP);
  float swatch = 10, gapAfterSwatch = 7;
  textSize(11);
  float w1 = textWidth(l1);
  textSize(13);
  float w2 = swatch + gapAfterSwatch + textWidth(l2 + "   " + l3);

  float padX = 11, padY = 9;
  float boxW = max(w1, w2) + padX * 2;
  float boxH = 42;
  float tx = mouseX + 14;
  float ty = mouseY + 14;
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
