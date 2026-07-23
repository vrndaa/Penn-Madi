import java.awt.Font; // for the italic heading face

Table table;

// Rows we actually draw (India / IND filtered out)
java.util.ArrayList<TableRow> drawRows;

// Fonts
PFont bodyFont;
PFont headingFont;
PFont headingItalicFont;

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
  background(0); // black background
  segments.clear();
  drawHeading();
  drawSections();
  drawTooltip();
}

void drawHeading() {
  float leftMargin = 55;
  float sz = 40;
  float titleY = 40;
  textAlign(LEFT, TOP);

  // Title: italic "Penn" + regular "-madi", top-left
  fill(255);
  textFont(headingItalicFont);
  textSize(sz);
  float w1 = textWidth("Penn");
  text("Penn", leftMargin, titleY);
  textFont(headingFont);
  textSize(sz);
  text("-madi", leftMargin + w1, titleY);

  // Description under the title (edit this text freely)
  String desc =
    "Penn-madi weaves together six measures of women's lives — literacy, years of "
    + "schooling, school attendance, paid work, property ownership, and bank accounts — "
    + "across every state and union territory of India. Each cell is one state: the horizontal "
    + "threads compare rural and urban, and the vertical warp threads cross them like a "
    + "traditional pai mat. Hover over any thread to read its value.";
  fill(190);
  textFont(bodyFont);
  textSize(15);
  text(desc, leftMargin, titleY + 52, min(width - 2 * leftMargin, 900), 110);
}

void drawSections() {
  int startX = 50;
  int topMargin = 200;   // leaves room for the heading + description
  int bottomMargin = 35;

  int n = drawRows.size();
  int cols = ceil(sqrt(n));            // arrange into a near-square grid...
  int rows = ceil((float) n / cols);   // ...with no trailing empty cells
  int cellWidth = (width - 2 * startX) / cols;
  int cellHeight = (height - topMargin - bottomMargin) / rows;
  int sectionWidth = cellWidth;        // cells tile edge-to-edge (shared lattice, no separate boxes)
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
    //     interlace over/under. ---
    float xL = x + 10;              // common left start of horizontals
    float yBase = y + sectionHeight - 10; // baseline the verticals rise from
    float[] hY = new float[6];      // y of each horizontal
    float[] hRight = new float[6];  // right-end x of each horizontal

    // Horizontal line: women literate, rural
    float lineYRuralLiterate = y + sectionHeight * 0.24;
    float lineLengthRuralLiterate = map(literateRural, 0, 100, 0, sectionWidth - 20);
    stroke(555, 345, 100);
    dataLine(xL, lineYRuralLiterate, xL + lineLengthRuralLiterate, lineYRuralLiterate,
      stateName, "Women literate (Rural)", literateRural);
    hY[0] = lineYRuralLiterate; hRight[0] = xL + lineLengthRuralLiterate;

    // Horizontal line: women literate, urban
    float lineYUrbanLiterate = y + sectionHeight * 0.34;
    float lineLengthUrbanLiterate = map(literateUrban, 0, 100, 0, sectionWidth - 20);
    stroke(100, 555, 100);
    dataLine(xL, lineYUrbanLiterate, xL + lineLengthUrbanLiterate, lineYUrbanLiterate,
      stateName, "Women literate (Urban)", literateUrban);
    hY[1] = lineYUrbanLiterate; hRight[1] = xL + lineLengthUrbanLiterate;

    // Horizontal line: 10+ years of schooling, rural
    float lineYRuralSchooling = y + sectionHeight * 0.44;
    float lineLengthRuralSchooling = map(schoolingRural, 0, 100, 0, sectionWidth - 20);
    stroke(255, 105, 180);
    dataLine(xL, lineYRuralSchooling, xL + lineLengthRuralSchooling, lineYRuralSchooling,
      stateName, "10+ yrs of schooling (Rural)", schoolingRural);
    hY[2] = lineYRuralSchooling; hRight[2] = xL + lineLengthRuralSchooling;

    // Horizontal line: 10+ years of schooling, urban
    float lineYUrbanSchooling = y + sectionHeight * 0.54;
    float lineLengthUrbanSchooling = map(schoolingUrban, 0, 100, 0, sectionWidth - 20);
    stroke(220, 150, 255);
    dataLine(xL, lineYUrbanSchooling, xL + lineLengthUrbanSchooling, lineYUrbanSchooling,
      stateName, "10+ yrs of schooling (Urban)", schoolingUrban);
    hY[3] = lineYUrbanSchooling; hRight[3] = xL + lineLengthUrbanSchooling;

    // Horizontal line: attended school age 6+, rural
    float lineYRuralAttended = y + sectionHeight * 0.64;
    float lineLengthRuralAttended = map(attendedSchoolRural, 0, 100, 0, sectionWidth - 20);
    stroke(255, 200, 100);
    dataLine(xL, lineYRuralAttended, xL + lineLengthRuralAttended, lineYRuralAttended,
      stateName, "Attended school, age 6+ (Rural)", attendedSchoolRural);
    hY[4] = lineYRuralAttended; hRight[4] = xL + lineLengthRuralAttended;

    // Horizontal line: attended school age 6+, urban
    float lineYUrbanAttended = y + sectionHeight * 0.74;
    float lineLengthUrbanAttended = map(attendedSchoolUrban, 0, 100, 0, sectionWidth - 20);
    stroke(100, 200, 255);
    dataLine(xL, lineYUrbanAttended, xL + lineLengthUrbanAttended, lineYUrbanAttended,
      stateName, "Attended school, age 6+ (Urban)", attendedSchoolUrban);
    hY[5] = lineYUrbanAttended; hRight[5] = xL + lineLengthUrbanAttended;

    // --- Vertical threads (the "warp"), spread across the cell width and
    //     interlaced over/under the horizontals ---
    // Worked & paid in cash, rural / urban
    wovenVertical(x + sectionWidth * 0.15, map(womenWorkedCashRural, 0, 100, 0, sectionHeight - 10), yBase, 0, hY, hRight,
      158, 168, 41, stateName, "Worked & paid in cash (Rural)", womenWorkedCashRural);
    wovenVertical(x + sectionWidth * 0.24, map(womenWorkedCashUrban, 0, 100, 0, sectionHeight - 10), yBase, 1, hY, hRight,
      158, 168, 41, stateName, "Worked & paid in cash (Urban)", womenWorkedCashUrban);

    // Owns a house and/or land, rural / urban
    wovenVertical(x + sectionWidth * 0.46, map(womenOwnHouseLandRural, 0, 100, 0, sectionHeight - 40), yBase, 2, hY, hRight,
      110, 84, 15, stateName, "Owns a house and/or land (Rural)", womenOwnHouseLandRural);
    wovenVertical(x + sectionWidth * 0.55, map(womenOwnHouseLandUrban, 0, 100, 0, sectionHeight - 40), yBase, 3, hY, hRight,
      110, 84, 15, stateName, "Owns a house and/or land (Urban)", womenOwnHouseLandUrban);

    // Bank or savings account, rural / urban
    wovenVertical(x + sectionWidth * 0.77, map(womenBankAccountRural, 0, 100, 0, sectionHeight - 50), yBase, 4, hY, hRight,
      255, 0, 255, stateName, "Bank or savings account (Rural)", womenBankAccountRural);
    wovenVertical(x + sectionWidth * 0.86, map(womenBankAccountUrban, 0, 100, 0, sectionHeight - 50), yBase, 5, hY, hRight,
      255, 0, 255, stateName, "Bank or savings account (Urban)", womenBankAccountUrban);
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
                   int r, int g, int b, String state, String label, float value) {
  float yBot = yBase;
  float yTop = yBase - len;
  float gapHalf = 2; // half-width of the break where a horizontal rides over

  stroke(r, g, b);
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
  stroke(255); // white thread
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
  fill(255); // white text
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

  stroke(0);
  strokeWeight(1);
  fill(255, 250, 235); // soft cloth-colored tooltip
  rect(tx, ty, boxW, boxH);
  fill(0);
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
