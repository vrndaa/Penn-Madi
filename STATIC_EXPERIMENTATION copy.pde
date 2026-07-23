Table table;

// Rows we actually draw (India / IND filtered out)
java.util.ArrayList<TableRow> drawRows;

// Fonts
PFont bodyFont;
PFont headingFont;

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
  size(1000, 800);

  // Smooth, anti-aliased fonts (fixes the "gritty" look of the default font)
  bodyFont = createFont("SansSerif", 32, true);
  headingFont = createFont("Serif", 48, true);

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
  fill(255);
  textFont(headingFont);
  textSize(40);
  textAlign(CENTER, CENTER);
  text("Penn-madi", width / 2, 35);
}

void drawSections() {
  int startX = 50;
  int topMargin = 75;    // leaves room for the heading
  int bottomMargin = 35;
  int gap = 16;          // even spacing between boxes

  int n = drawRows.size();
  int cols = ceil(sqrt(n));            // arrange into a near-square grid...
  int rows = ceil((float) n / cols);   // ...with no trailing empty cells
  int cellWidth = (width - 2 * startX) / cols;
  int cellHeight = (height - topMargin - bottomMargin) / rows;
  int sectionWidth = cellWidth - gap;
  int sectionHeight = cellHeight - gap;

  textFont(bodyFont);

  for (int i = 0; i < n; i++) {
    TableRow row = drawRows.get(i);
    int x = startX + (i % cols) * cellWidth + gap / 2;
    int y = topMargin + (i / cols) * cellHeight + gap / 2;
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

    // The box (black, so it blends into the background; the white stitch frame defines it)
    fill(0);
    noStroke();
    rect(x, y, sectionWidth, sectionHeight);

    // White stitch pattern framing the box
    drawStitchBorder(x, y, sectionWidth, sectionHeight);

    // Shortened, legible state name on top
    drawStateName(displayName(stateName), x, y, sectionWidth);

    // Horizontal line: women literate, rural
    float lineYRuralLiterate = y + sectionHeight * 0.22;
    float lineLengthRuralLiterate = map(literateRural, 0, 100, 0, sectionWidth - 20);
    stroke(555, 345, 100);
    dataLine(x + 10, lineYRuralLiterate, x + 10 + lineLengthRuralLiterate, lineYRuralLiterate,
      stateName, "Women literate (Rural)", literateRural);

    // Horizontal line: women literate, urban
    float lineYUrbanLiterate = y + sectionHeight * 0.28;
    float lineLengthUrbanLiterate = map(literateUrban, 0, 100, 0, sectionWidth - 20);
    stroke(100, 555, 100);
    dataLine(x + 10, lineYUrbanLiterate, x + 10 + lineLengthUrbanLiterate, lineYUrbanLiterate,
      stateName, "Women literate (Urban)", literateUrban);

    // Horizontal line: 10+ years of schooling, rural
    float lineYRuralSchooling = y + sectionHeight * 0.40;
    float lineLengthRuralSchooling = map(schoolingRural, 0, 100, 0, sectionWidth - 20);
    stroke(255, 105, 180);
    dataLine(x + 10, lineYRuralSchooling, x + 10 + lineLengthRuralSchooling, lineYRuralSchooling,
      stateName, "10+ yrs of schooling (Rural)", schoolingRural);

    // Horizontal line: 10+ years of schooling, urban
    float lineYUrbanSchooling = y + sectionHeight * 0.46;
    float lineLengthUrbanSchooling = map(schoolingUrban, 0, 100, 0, sectionWidth - 20);
    stroke(220, 150, 255);
    dataLine(x + 10, lineYUrbanSchooling, x + 10 + lineLengthUrbanSchooling, lineYUrbanSchooling,
      stateName, "10+ yrs of schooling (Urban)", schoolingUrban);

    // Horizontal line: attended school age 6+, rural
    float lineYRuralAttended = y + sectionHeight * 0.58;
    float lineLengthRuralAttended = map(attendedSchoolRural, 0, 100, 0, sectionWidth - 20);
    stroke(255, 200, 100);
    dataLine(x + 10, lineYRuralAttended, x + 10 + lineLengthRuralAttended, lineYRuralAttended,
      stateName, "Attended school, age 6+ (Rural)", attendedSchoolRural);

    // Horizontal line: attended school age 6+, urban
    float lineYUrbanAttended = y + sectionHeight * 0.64;
    float lineLengthUrbanAttended = map(attendedSchoolUrban, 0, 100, 0, sectionWidth - 20);
    stroke(100, 200, 255);
    dataLine(x + 10, lineYUrbanAttended, x + 10 + lineLengthUrbanAttended, lineYUrbanAttended,
      stateName, "Attended school, age 6+ (Urban)", attendedSchoolUrban);

    // Vertical line: worked & paid in cash, rural
    float lineXWomenWorkedCashRural = x + 10;
    float lineLengthWomenWorkedCashRural = map(womenWorkedCashRural, 0, 100, 0, sectionHeight - 10);
    stroke(158, 168, 41);
    dataLine(lineXWomenWorkedCashRural, y + sectionHeight - 10, lineXWomenWorkedCashRural, y + sectionHeight - 10 - lineLengthWomenWorkedCashRural,
      stateName, "Worked & paid in cash (Rural)", womenWorkedCashRural);

    // Vertical line: worked & paid in cash, urban
    float lineXWomenWorkedCashUrban = x + 20;
    float lineLengthWomenWorkedCashUrban = map(womenWorkedCashUrban, 0, 100, 0, sectionHeight - 10);
    stroke(158, 168, 41);
    dataLine(lineXWomenWorkedCashUrban, y + sectionHeight - 10, lineXWomenWorkedCashUrban, y + sectionHeight - 10 - lineLengthWomenWorkedCashUrban,
      stateName, "Worked & paid in cash (Urban)", womenWorkedCashUrban);

    // Vertical line: owns a house and/or land, rural
    float lineXWomenOwnHouseLandRural = x + 40;
    float lineLengthWomenOwnHouseLandRural = map(womenOwnHouseLandRural, 0, 100, 0, sectionHeight - 40);
    stroke(110, 84, 15);
    dataLine(lineXWomenOwnHouseLandRural, y + sectionHeight - 10, lineXWomenOwnHouseLandRural, y + sectionHeight - 10 - lineLengthWomenOwnHouseLandRural,
      stateName, "Owns a house and/or land (Rural)", womenOwnHouseLandRural);

    // Vertical line: owns a house and/or land, urban
    float lineXWomenOwnHouseLandUrban = x + 50;
    float lineLengthWomenOwnHouseLandUrban = map(womenOwnHouseLandUrban, 0, 100, 0, sectionHeight - 40);
    stroke(110, 84, 15);
    dataLine(lineXWomenOwnHouseLandUrban, y + sectionHeight - 10, lineXWomenOwnHouseLandUrban, y + sectionHeight - 10 - lineLengthWomenOwnHouseLandUrban,
      stateName, "Owns a house and/or land (Urban)", womenOwnHouseLandUrban);

    // Vertical line: bank or savings account, rural
    float lineXWomenBankAccountRural = x + 70;
    float lineLengthWomenBankAccountRural = map(womenBankAccountRural, 0, 100, 0, sectionHeight - 50);
    stroke(255, 0, 255);
    dataLine(lineXWomenBankAccountRural, y + sectionHeight - 10, lineXWomenBankAccountRural, y + sectionHeight - 10 - lineLengthWomenBankAccountRural,
      stateName, "Bank or savings account (Rural)", womenBankAccountRural);

    // Vertical line: bank or savings account, urban
    float lineXWomenBankAccountUrban = x + 80;
    float lineLengthWomenBankAccountUrban = map(womenBankAccountUrban, 0, 100, 0, sectionHeight - 50);
    stroke(255, 0, 255);
    dataLine(lineXWomenBankAccountUrban, y + sectionHeight - 10, lineXWomenBankAccountUrban, y + sectionHeight - 10 - lineLengthWomenBankAccountUrban,
      stateName, "Bank or savings account (Urban)", womenBankAccountUrban);
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
  strokeWeight(1.5);
  line(x1, y1, x2, y2);
  segments.add(new Segment(x1, y1, x2, y2, state, label, value));
}

// A running-stitch look: short dashes with small gaps along the segment
void stitchLine(float x1, float y1, float x2, float y2) {
  float d = dist(x1, y1, x2, y2);
  if (d <= 0) return;
  float dash = 4;
  float gap = 3;
  float ux = (x2 - x1) / d;
  float uy = (y2 - y1) / d;
  for (float t = 0; t < d; t += dash + gap) {
    float et = min(t + dash, d);
    line(x1 + ux * t, y1 + uy * t, x1 + ux * et, y1 + uy * et);
  }
}

// Thin white running-stitch frame right on the box edge (subtle, not a bold box)
void drawStitchBorder(float x, float y, float w, float h) {
  stroke(255); // white thread
  strokeWeight(0.5);
  stitchLine(x, y, x + w, y);         // top
  stitchLine(x + w, y, x + w, y + h); // right
  stitchLine(x + w, y + h, x, y + h); // bottom
  stitchLine(x, y + h, x, y);         // left
}

// State name on top of the box, shrunk (and wrapped if needed) to fit
void drawStateName(String name, float boxX, float boxY, float boxW) {
  fill(255); // white text
  textAlign(CENTER, TOP);
  float maxW = boxW - 6;

  // Try to fit on one line, shrinking the size down to a floor
  float ts = 13;
  while (ts > 7) {
    textSize(ts);
    if (textWidth(name) <= maxW) break;
    ts -= 0.5;
  }
  textSize(ts);
  if (textWidth(name) <= maxW) {
    text(name, boxX + boxW / 2, boxY + 4);
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
  text(line1, boxX + boxW / 2, boxY + 3);
  if (line2.length() > 0) {
    text(line2, boxX + boxW / 2, boxY + 13);
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
