import java.awt.Font; // for the italic heading face

Table table;

// Rows we actually draw (India / IND filtered out)
java.util.ArrayList<TableRow> drawRows;

// Fonts
PFont bodyFont;
PFont headingFont;
PFont headingItalicFont;

// Page layout (computed in setup once the screen size is known)
float INNER = 60;   // equal inner margin on all four sides
float dividerX, leftColX, leftColRight, rightColX, rightColRight;

// Page theme (beige cloth ground; dark thread for text + lattice)
color BG     = color(235, 226, 202);
color INK    = color(45, 38, 30);
color SUBINK = color(95, 84, 66);

// Ikat border palette (pink)
color IKAT_PINK  = color(224, 66, 140);
color IKAT_LIGHT = color(248, 216, 230);

// One base hue per metric (from the uploaded swatch palette).
// Rural = a darker tone of the hue, Urban = a lighter tone.
color[] metricBase;

color rural(color base) { return lerpColor(base, color(0), 0.30); }   // darker
color urban(color base) { return lerpColor(base, color(255), 0.33); } // lighter

// Stitch segments recorded each frame so we can show a tooltip on hover
class Segment {
  float x1, y1, x2, y2;
  String state, label;
  float value;
  Segment(float x1, float y1, float x2, float y2, String state, String label, float value) {
    this.x1 = x1; this.y1 = y1; this.x2 = x2; this.y2 = y2;
    this.state = state; this.label = label; this.value = value;
  }
}
java.util.ArrayList<Segment> segments = new java.util.ArrayList<Segment>();

void setup() {
  fullScreen();                   // artboard fills the whole screen
  pixelDensity(displayDensity()); // render at the screen's real density (fixes gritty/blurry lines on Retina)
  smooth(8);                      // high-quality anti-aliasing

  // Smooth, anti-aliased fonts (fixes the "gritty" look of the default font)
  bodyFont = createFont("SansSerif", 32, true);
  headingFont = createFont("Serif", 48, true);
  headingItalicFont = new PFont(new Font("Serif", Font.ITALIC, 48), true); // italic serif for "Penn"

  // Two-column layout: text on the left, visualization on the right
  dividerX      = width * 0.40;
  leftColX      = INNER;
  leftColRight  = dividerX - 34;
  rightColX     = dividerX + 34;
  rightColRight = width - INNER;

  // Metric hues (order: literate, schooling, attended, cash, house/land, bank)
  metricBase = new color[6];
  metricBase[0] = color(200, 45, 60);   // red
  metricBase[1] = color(150, 80, 165);  // purple
  metricBase[2] = color(235, 110, 55);  // orange
  metricBase[3] = color(30, 100, 100);  // teal
  metricBase[4] = color(170, 50, 105);  // magenta / wine
  metricBase[5] = color(90, 60, 140);   // indigo

  table = loadTable("Urban Rural Data Cleaned.csv", "header");

  // Build the list of rows to draw, skipping the India / "IND" row
  drawRows = new java.util.ArrayList<TableRow>();
  for (int i = 0; i < table.getRowCount(); i++) {
    TableRow row = table.getRow(i);
    String state = trim(row.getString(0));
    String abbr = row.getString("Abbreviation");
    abbr = (abbr == null) ? "" : trim(abbr);
    if (state.equalsIgnoreCase("India") || abbr.equalsIgnoreCase("IND")) {
      continue; // remove the India box
    }
    drawRows.add(row);
  }
}

void draw() {
  background(BG); // beige cloth background
  segments.clear();
  drawIkatBorder();  // pink ikat frame around the page
  drawHeading();     // left column: title + description
  drawLegend();      // left column: how to read
  drawSections();    // right column: the visualization
  drawTooltip();
}

// ---- Pink ikat border around the page -------------------------------------
void drawIkatBorder() {
  float bw = 30; // band width
  noStroke();
  fill(IKAT_PINK);
  rect(0, 0, width, bw);              // top
  rect(0, height - bw, width, bw);    // bottom
  rect(0, 0, bw, height);             // left
  rect(width - bw, 0, bw, height);    // right

  float d = bw * 0.72; // diamond size
  for (float cx = bw; cx < width - bw + 1; cx += bw) {
    diamond(cx, bw / 2, d);
    diamond(cx, height - bw / 2, d);
  }
  for (float cy = bw; cy < height - bw + 1; cy += bw) {
    diamond(bw / 2, cy, d);
    diamond(width - bw / 2, cy, d);
  }
}

// A light ikat diamond with a small pink core
void diamond(float cx, float cy, float s) {
  noStroke();
  fill(IKAT_LIGHT);
  quad(cx, cy - s / 2, cx + s / 2, cy, cx, cy + s / 2, cx - s / 2, cy);
  fill(IKAT_PINK);
  float t = s * 0.42;
  quad(cx, cy - t / 2, cx + t / 2, cy, cx, cy + t / 2, cx - t / 2, cy);
}

// ---- Left column: title + description --------------------------------------
void drawHeading() {
  float sz = 40;
  float titleY = INNER;
  textAlign(LEFT, TOP);

  // Title: italic "Penn" + regular "-madi"
  fill(INK);
  textFont(headingItalicFont);
  textSize(sz);
  float w1 = textWidth("Penn");
  text("Penn", leftColX, titleY);
  textFont(headingFont);
  textSize(sz);
  text("-madi", leftColX + w1, titleY);

  // Description (edit this text freely)
  String desc =
    "Penn-madi weaves together six measures of women's lives — literacy, years of "
    + "schooling, school attendance, paid work, property ownership, and bank accounts — "
    + "for every state and union territory of India. Each state is a small cloth: horizontal "
    + "threads compare rural and urban, and vertical warp threads cross them, echoing the fine "
    + "Pattamadai pai mats of Tamil Nadu. Hover over any thread to read its value.";
  fill(SUBINK);
  textFont(bodyFont);
  textSize(15);
  text(desc, leftColX, titleY + 52, leftColRight - leftColX, 200);
}

// ---- Left column: how-to-read legend ---------------------------------------
void drawLegend() {
  float lx = leftColX;
  float lw = leftColRight - leftColX;
  float y = height * 0.42;

  fill(INK);
  textAlign(LEFT, TOP);
  textFont(headingFont);
  textSize(22);
  text("how to read", lx, y);
  y += 40;

  textFont(bodyFont);
  fill(SUBINK);
  textSize(13);
  text("Each cell is a state. Every thread is one statistic — the longer the thread, the higher "
    + "the percentage.  Darker tone = rural, lighter tone = urban.", lx, y, lw, 70);
  y += 66;

  fill(INK);
  textSize(13);
  text("Horizontal threads   ·   rural / urban", lx, y); y += 22;
  y = legendRow(lx, y, "Women literate", metricBase[0]);
  y = legendRow(lx, y, "10+ years of schooling", metricBase[1]);
  y = legendRow(lx, y, "Attended school (age 6+)", metricBase[2]);

  y += 12;
  fill(INK);
  text("Vertical threads   ·   rural / urban", lx, y); y += 22;
  y = legendRow(lx, y, "Worked & paid in cash", metricBase[3]);
  y = legendRow(lx, y, "Owns a house / land", metricBase[4]);
  y = legendRow(lx, y, "Bank / savings account", metricBase[5]);

  y += 12;
  fill(SUBINK);
  textSize(12);
  text("Hover over any thread to read its exact value.", lx, y, lw, 40);
}

// One legend row: dark (rural) + light (urban) swatch of a metric hue, then label
float legendRow(float lx, float y, String label, color base) {
  float swLen = 22;
  strokeWeight(3);
  stroke(rural(base));
  line(lx, y + 7, lx + swLen, y + 7);
  stroke(urban(base));
  line(lx + swLen + 6, y + 7, lx + swLen * 2 + 6, y + 7);

  noStroke();
  fill(INK);
  textAlign(LEFT, TOP);
  textSize(13);
  text(label, lx + swLen * 2 + 16, y);
  return y + 21;
}

// ---- The visualization (right column) --------------------------------------
void drawSections() {
  int n = drawRows.size();
  int cols = ceil(sqrt(n));            // arrange into a near-square grid...
  int rows = ceil((float) n / cols);   // ...with no trailing empty cells

  // Fit a square-celled grid into the right column, centered (equal top/bottom)
  float availW = rightColRight - rightColX;
  float y1 = INNER;
  float y2 = height - INNER;
  float availH = y2 - y1;
  float cell = min(availW / cols, availH / rows);

  int cellWidth = (int) cell;
  int cellHeight = (int) cell;
  int startX = (int) (rightColX + (availW - cols * cell) / 2);
  int topMargin = (int) (y1 + (availH - rows * cell) / 2);
  int sectionWidth = cellWidth;
  int sectionHeight = cellHeight;

  // One continuous dashed stitch lattice framing all cells
  drawGrid(startX, topMargin, cols, rows, cellWidth, cellHeight);

  textFont(bodyFont);

  for (int i = 0; i < n; i++) {
    TableRow row = drawRows.get(i);
    int x = startX + (i % cols) * cellWidth;
    int y = topMargin + (i / cols) * cellHeight;
    String stateName = trim(row.getString(0)); // full name (used in tooltip)
    float literateRural = row.getFloat(2);
    float literateUrban = row.getFloat(3);
    float schoolingRural = row.getFloat(4);
    float schoolingUrban = row.getFloat(5);
    float attendedSchoolRural = row.getFloat(6);
    float attendedSchoolUrban = row.getFloat(7);
    float womenWorkedCashRural = row.getFloat(8);
    float womenWorkedCashUrban = row.getFloat(9);
    float womenOwnHouseLandRural = row.getFloat(10);
    float womenOwnHouseLandUrban = row.getFloat(11);
    float womenBankAccountRural = row.getFloat(12);
    float womenBankAccountUrban = row.getFloat (13);

    // Shortened, legible state name at the top of this cell
    drawStateName(displayName(stateName), x, y, sectionWidth);

    // --- Horizontal threads (the "weft"), drawn solid. We also record each
    //     one's y-position and right-end so the vertical threads know where to
    //     interlace over/under. Rural = darker tone, urban = lighter tone. ---
    float xL = x + 10;              // common left start of horizontals
    float yBase = y + sectionHeight - 10; // baseline the verticals rise from
    float[] hY = new float[6];      // y of each horizontal
    float[] hRight = new float[6];  // right-end x of each horizontal

    // Women literate — rural / urban
    float lineYRuralLiterate = y + sectionHeight * 0.24;
    float lineLengthRuralLiterate = map(literateRural, 0, 100, 0, sectionWidth - 20);
    stroke(rural(metricBase[0]));
    dataLine(xL, lineYRuralLiterate, xL + lineLengthRuralLiterate, lineYRuralLiterate,
      stateName, "Women literate (Rural)", literateRural);
    hY[0] = lineYRuralLiterate; hRight[0] = xL + lineLengthRuralLiterate;

    float lineYUrbanLiterate = y + sectionHeight * 0.34;
    float lineLengthUrbanLiterate = map(literateUrban, 0, 100, 0, sectionWidth - 20);
    stroke(urban(metricBase[0]));
    dataLine(xL, lineYUrbanLiterate, xL + lineLengthUrbanLiterate, lineYUrbanLiterate,
      stateName, "Women literate (Urban)", literateUrban);
    hY[1] = lineYUrbanLiterate; hRight[1] = xL + lineLengthUrbanLiterate;

    // 10+ years of schooling — rural / urban
    float lineYRuralSchooling = y + sectionHeight * 0.44;
    float lineLengthRuralSchooling = map(schoolingRural, 0, 100, 0, sectionWidth - 20);
    stroke(rural(metricBase[1]));
    dataLine(xL, lineYRuralSchooling, xL + lineLengthRuralSchooling, lineYRuralSchooling,
      stateName, "10+ yrs of schooling (Rural)", schoolingRural);
    hY[2] = lineYRuralSchooling; hRight[2] = xL + lineLengthRuralSchooling;

    float lineYUrbanSchooling = y + sectionHeight * 0.54;
    float lineLengthUrbanSchooling = map(schoolingUrban, 0, 100, 0, sectionWidth - 20);
    stroke(urban(metricBase[1]));
    dataLine(xL, lineYUrbanSchooling, xL + lineLengthUrbanSchooling, lineYUrbanSchooling,
      stateName, "10+ yrs of schooling (Urban)", schoolingUrban);
    hY[3] = lineYUrbanSchooling; hRight[3] = xL + lineLengthUrbanSchooling;

    // Attended school (age 6+) — rural / urban
    float lineYRuralAttended = y + sectionHeight * 0.64;
    float lineLengthRuralAttended = map(attendedSchoolRural, 0, 100, 0, sectionWidth - 20);
    stroke(rural(metricBase[2]));
    dataLine(xL, lineYRuralAttended, xL + lineLengthRuralAttended, lineYRuralAttended,
      stateName, "Attended school, age 6+ (Rural)", attendedSchoolRural);
    hY[4] = lineYRuralAttended; hRight[4] = xL + lineLengthRuralAttended;

    float lineYUrbanAttended = y + sectionHeight * 0.74;
    float lineLengthUrbanAttended = map(attendedSchoolUrban, 0, 100, 0, sectionWidth - 20);
    stroke(urban(metricBase[2]));
    dataLine(xL, lineYUrbanAttended, xL + lineLengthUrbanAttended, lineYUrbanAttended,
      stateName, "Attended school, age 6+ (Urban)", attendedSchoolUrban);
    hY[5] = lineYUrbanAttended; hRight[5] = xL + lineLengthUrbanAttended;

    // --- Vertical threads (the "warp"), spread across the cell width and
    //     interlaced over/under the horizontals. Rural = darker, urban = lighter. ---
    // Worked & paid in cash
    wovenVertical(x + sectionWidth * 0.15, map(womenWorkedCashRural, 0, 100, 0, sectionHeight - 10), yBase, 0, hY, hRight,
      rural(metricBase[3]), stateName, "Worked & paid in cash (Rural)", womenWorkedCashRural);
    wovenVertical(x + sectionWidth * 0.24, map(womenWorkedCashUrban, 0, 100, 0, sectionHeight - 10), yBase, 1, hY, hRight,
      urban(metricBase[3]), stateName, "Worked & paid in cash (Urban)", womenWorkedCashUrban);

    // Owns a house and/or land
    wovenVertical(x + sectionWidth * 0.46, map(womenOwnHouseLandRural, 0, 100, 0, sectionHeight - 40), yBase, 2, hY, hRight,
      rural(metricBase[4]), stateName, "Owns a house and/or land (Rural)", womenOwnHouseLandRural);
    wovenVertical(x + sectionWidth * 0.55, map(womenOwnHouseLandUrban, 0, 100, 0, sectionHeight - 40), yBase, 3, hY, hRight,
      urban(metricBase[4]), stateName, "Owns a house and/or land (Urban)", womenOwnHouseLandUrban);

    // Bank or savings account
    wovenVertical(x + sectionWidth * 0.77, map(womenBankAccountRural, 0, 100, 0, sectionHeight - 50), yBase, 4, hY, hRight,
      rural(metricBase[5]), stateName, "Bank or savings account (Rural)", womenBankAccountRural);
    wovenVertical(x + sectionWidth * 0.86, map(womenBankAccountUrban, 0, 100, 0, sectionHeight - 50), yBase, 5, hY, hRight,
      urban(metricBase[5]), stateName, "Bank or savings account (Urban)", womenBankAccountUrban);
  }
}

// Shorten the longest names so they stay legible inside the box
String displayName(String full) {
  if (full.indexOf("Andaman") >= 0) return "Andaman";
  if (full.indexOf("Dadra") >= 0) return "Dadra & Nagar Haveli";
  return full;
}

// Draw a metric as a normal solid line AND record it for hover tooltips
void dataLine(float x1, float y1, float x2, float y2, String state, String label, float value) {
  strokeWeight(1);
  line(x1, y1, x2, y2);
  segments.add(new Segment(x1, y1, x2, y2, state, label, value));
}

// Draw a vertical thread that interlaces over/under the horizontal threads.
// At each crossing, plain-weave parity (col + row) decides who goes on top:
// when the horizontal should be on top, we break a small gap in this vertical.
void wovenVertical(float xv, float len, float yBase, int colIndex, float[] hY, float[] hRight,
                   color col, String state, String label, float value) {
  float yBot = yBase;
  float yTop = yBase - len;
  float gapHalf = 2; // half-width of the break where a horizontal rides over

  stroke(col);
  strokeWeight(1);
  float cursor = yTop;
  for (int k = 0; k < hY.length; k++) {          // hY is ordered top->bottom
    boolean crosses = (xv <= hRight[k]) && (hY[k] >= yTop) && (hY[k] <= yBot);
    boolean horizontalOnTop = ((k + colIndex) % 2) == 0;
    if (crosses && horizontalOnTop) {
      float gTop = hY[k] - gapHalf;
      if (gTop > cursor) line(xv, cursor, xv, gTop);
      cursor = max(cursor, hY[k] + gapHalf);
    }
  }
  if (cursor < yBot) line(xv, cursor, xv, yBot);

  // record the full logical thread so hover tooltips still work
  segments.add(new Segment(xv, yTop, xv, yBot, state, label, value));
}

// A dashed running-stitch look: even dashes with small gaps along the segment
void stitchLine(float x1, float y1, float x2, float y2) {
  float d = dist(x1, y1, x2, y2);
  if (d <= 0) return;
  float dash = 4;
  float gap = 2;
  float ux = (x2 - x1) / d;
  float uy = (y2 - y1) / d;
  for (float t = 0; t < d; t += dash + gap) {
    float et = min(t + dash, d);
    line(x1 + ux * t, y1 + uy * t, x1 + ux * et, y1 + uy * et);
  }
}

// One continuous dashed stitch lattice: shared grid lines around every cell (no separate boxes)
void drawGrid(int left, int top, int cols, int rows, int cw, int ch) {
  stroke(INK); // dark thread lattice (reads on the beige ground)
  strokeWeight(0.25);
  int right = left + cols * cw;
  int bottom = top + rows * ch;
  for (int c = 0; c <= cols; c++) {          // vertical stitch lines
    stitchLine(left + c * cw, top, left + c * cw, bottom);
  }
  for (int r = 0; r <= rows; r++) {          // horizontal stitch lines
    stitchLine(left, top + r * ch, right, top + r * ch);
  }
}

// State name on top of the box, shrunk (and wrapped if needed) to fit
void drawStateName(String name, float boxX, float boxY, float boxW) {
  fill(INK);
  textAlign(LEFT, TOP);
  float maxW = boxW - 6;

  // Try to fit on one line, shrinking the size down to a floor
  float ts = 9;
  while (ts > 7) {
    textSize(ts);
    if (textWidth(name) <= maxW) break;
    ts -= 0.5;
  }
  textSize(ts);
  if (textWidth(name) <= maxW) {
    text(name, boxX + 4, boxY + 9);
    return;
  }

  // Still too long: word-wrap onto two lines at the floor size
  textSize(8);
  String[] words = split(name, ' ');
  String line1 = "";
  int i = 0;
  while (i < words.length) {
    String test = (line1.length() == 0) ? words[i] : line1 + " " + words[i];
    if (textWidth(test) > maxW && line1.length() > 0) break;
    line1 = test;
    i++;
  }
  String line2 = "";
  while (i < words.length) {
    line2 = (line2.length() == 0) ? words[i] : line2 + " " + words[i];
    i++;
  }
  text(line1, boxX + 4, boxY + 8);
  if (line2.length() > 0) {
    text(line2, boxX + 4, boxY + 18);
  }
}

// Show a floating tooltip for whichever stitch line the mouse is closest to
void drawTooltip() {
  Segment hit = null;
  float best = 4; // hover tolerance in pixels
  for (Segment s : segments) {
    float dd = pointSegmentDist(mouseX, mouseY, s.x1, s.y1, s.x2, s.y2);
    if (dd <= best) {
      best = dd;
      hit = s;
    }
  }
  if (hit == null) return;

  String l1 = hit.state;
  String l2 = hit.label + ": " + nf(hit.value, 0, 1) + "%";
  textFont(bodyFont);
  textAlign(LEFT, TOP);
  textSize(12);
  float boxW = max(textWidth(l1), textWidth(l2)) + 12;
  float boxH = 38;
  float tx = mouseX + 12;
  float ty = mouseY + 12;
  if (tx + boxW > width) tx = mouseX - boxW - 12;
  if (ty + boxH > height) ty = mouseY - boxH - 12;

  stroke(INK);
  strokeWeight(1);
  fill(250, 244, 232); // soft cloth-colored tooltip
  rect(tx, ty, boxW, boxH);
  fill(INK);
  text(l1, tx + 6, ty + 5);
  text(l2, tx + 6, ty + 20);
}

// Distance from point (px,py) to segment (x1,y1)-(x2,y2)
float pointSegmentDist(float px, float py, float x1, float y1, float x2, float y2) {
  float vx = x2 - x1;
  float vy = y2 - y1;
  float len2 = vx * vx + vy * vy;
  if (len2 == 0) return dist(px, py, x1, y1);
  float t = ((px - x1) * vx + (py - y1) * vy) / len2;
  t = constrain(t, 0, 1);
  return dist(px, py, x1 + t * vx, y1 + t * vy);
}
