Table table;

// Rows we actually draw (India / IND filtered out)
java.util.ArrayList<TableRow> drawRows;

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
  background(255); // Clear the background on each frame
  segments.clear();
  drawSections();
  drawTooltip();
}

void drawSections() {
  int startX = 50;
  int startY = 50;
  int sectionWidth = (width - 2 * startX) / 8;
  int sectionHeight = (height - 2 * startY) / 5;
  for (int i = 0; i < drawRows.size(); i++) {
    TableRow row = drawRows.get(i);
    int x = startX + (i % 8) * sectionWidth;
    int y = startY + (i / 8) * sectionHeight;
    String stateName = trim(row.getString(0)); // Full state name
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

    // The black box
    fill(0);
    stroke(4);
    strokeWeight(1.5);
    rect(x, y, sectionWidth, sectionHeight);

    // Stitch pattern OUTSIDE the box (a running-stitch frame around it)
    drawStitchBorder(x, y, sectionWidth, sectionHeight);

    // Full state name on top, auto-sized to fit within the box
    drawStateName(stateName, x, y, sectionWidth);

    // Draw a horizontal line representing women literate in rural areas
    float lineYRuralLiterate = y + sectionHeight / 6; // Adjusted position to push closer to the top and create a gap
    float lineLengthRuralLiterate = map(literateRural, 0, 100, 0, sectionWidth - 20); // Adjusting for padding
    stroke(555, 345, 100); // Red color for the rural lines
    stitchMetric(x + 10, lineYRuralLiterate, x + 10 + lineLengthRuralLiterate, lineYRuralLiterate,
      stateName, "Women literate (Rural)", literateRural);

    // Draw a horizontal line representing women literate in urban areas
    float lineYUrbanLiterate = y + sectionHeight / 4; // Adjusted position to create a gap
    float lineLengthUrbanLiterate = map(literateUrban, 0, 100, 0, sectionWidth - 20); // Adjusting for padding
    stroke(100, 555, 100); // Green color for the urban lines
    stitchMetric(x + 10, lineYUrbanLiterate, x + 10 + lineLengthUrbanLiterate, lineYUrbanLiterate,
      stateName, "Women literate (Urban)", literateUrban);

    // Draw a horizontal line representing women with 10 or more years of schooling in rural areas
    float lineYRuralSchooling = y + sectionHeight * 3 / 6;
    float lineLengthRuralSchooling = map(schoolingRural, 0, 100, 0, sectionWidth - 20); // Adjusting for padding
    stroke(255, 105, 180); // Pink color for the lines representing schooling rural
    stitchMetric(x + 10, lineYRuralSchooling, x + 10 + lineLengthRuralSchooling, lineYRuralSchooling,
      stateName, "10+ yrs of schooling (Rural)", schoolingRural);

    // Draw a horizontal line representing women with 10 or more years of schooling in urban areas
    float lineYUrbanSchooling = y + sectionHeight * 4 / 7; // Adjusted position to push closer to the bottom and create a gap
    float lineLengthUrbanSchooling = map(schoolingUrban, 0, 100, 0, sectionWidth - 20); // Adjusting for padding
    stroke(220, 150, 255); // Light purple color for the lines representing schooling urban
    stitchMetric(x + 10, lineYUrbanSchooling, x + 10 + lineLengthUrbanSchooling, lineYUrbanSchooling,
      stateName, "10+ yrs of schooling (Urban)", schoolingUrban);

    // Draw a horizontal line representing female population age 6 years and above attended school in rural areas
    float lineYRuralAttended = y + sectionHeight * 4.75 / 6; // Adjusted position to push closer to the bottom and create a gap
    float lineLengthRuralAttended = map(attendedSchoolRural, 0, 100, 0,
      sectionWidth - 20); // Adjusting for padding
    stroke(255, 200, 100); // Yellow color for the lines representing attended school rural
    stitchMetric(x + 10, lineYRuralAttended, x + 10 + lineLengthRuralAttended, lineYRuralAttended,
      stateName, "Attended school, age 6+ (Rural)", attendedSchoolRural);

    // Draw a horizontal line representing female population age 6 years and above attended school in urban areas
    float lineYUrbanAttended = y + sectionHeight * 6 / 7; // Adjusted position to push closer to the bottom
    float lineLengthUrbanAttended = map(attendedSchoolUrban, 0, 100, 0, sectionWidth - 20); // Adjusting for padding
    stroke(100, 200, 255); // Light blue color for the lines representing attended school urban
    stitchMetric(x + 10, lineYUrbanAttended, x + 10 + lineLengthUrbanAttended, lineYUrbanAttended,
      stateName, "Attended school, age 6+ (Urban)", attendedSchoolUrban);

    // Draw a vertical line representing women who worked and were paid in cash Rural
    float lineXWomenWorkedCashRural = x + 10; // Left aligned with padding
    float lineLengthWomenWorkedCashRural = map(womenWorkedCashRural, 0, 100, 0, sectionHeight - 10); // Adjusting for padding
    stroke(158, 168, 41); // Olive green color for the lines representing women worked and paid in cash rural
    stitchMetric(lineXWomenWorkedCashRural, y + sectionHeight - 10, lineXWomenWorkedCashRural, y + sectionHeight - 10 - lineLengthWomenWorkedCashRural,
      stateName, "Worked & paid in cash (Rural)", womenWorkedCashRural);

    // Draw a vertical line representing women who worked and were paid in cash Urban
    float lineXWomenWorkedCashUrban = x + 20; // Right aligned with padding
    float lineLengthWomenWorkedCashUrban = map(womenWorkedCashUrban, 0, 100, 0, sectionHeight - 10); // Adjusting for padding
    stroke(158, 168, 41); // Olive green color for the lines representing women worked and paid in cash urban
    stitchMetric(lineXWomenWorkedCashUrban, y + sectionHeight - 10, lineXWomenWorkedCashUrban, y + sectionHeight - 10 - lineLengthWomenWorkedCashUrban,
      stateName, "Worked & paid in cash (Urban)", womenWorkedCashUrban);

    // Draw a vertical line representing women owning a house and/or land Rural
    float lineXWomenOwnHouseLandRural = x + 40; // Left aligned with padding
    float lineLengthWomenOwnHouseLandRural = map(womenOwnHouseLandRural, 0, 100, 0, sectionHeight - 40); // Adjusting for padding
    stroke(110, 84, 15); // Brown color for the lines representing women owning a house and/or land rural
    stitchMetric(lineXWomenOwnHouseLandRural, y + sectionHeight - 10, lineXWomenOwnHouseLandRural, y + sectionHeight - 10 - lineLengthWomenOwnHouseLandRural,
      stateName, "Owns a house and/or land (Rural)", womenOwnHouseLandRural);

    // Draw a vertical line representing women owning a house and/or land Urban
    float lineXWomenOwnHouseLandUrban = x + 50; // Right aligned with padding
    float lineLengthWomenOwnHouseLandUrban = map(womenOwnHouseLandUrban, 0, 100, 0, sectionHeight - 40); // Adjusting for padding
    stroke(110, 84, 15); // Brown color for the lines representing women owning a house and/or land urban
    stitchMetric(lineXWomenOwnHouseLandUrban, y + sectionHeight - 10, lineXWomenOwnHouseLandUrban, y + sectionHeight - 10 - lineLengthWomenOwnHouseLandUrban,
      stateName, "Owns a house and/or land (Urban)", womenOwnHouseLandUrban);

    // Draw a vertical line representing women having a bank or savings account Rural
    float lineXWomenBankAccountRural = x + 70; // Right aligned with padding
    float lineLengthWomenBankAccountRural = map(womenBankAccountRural, 0, 100, 0, sectionHeight - 50); // Adjusting for padding
    stroke(255, 0, 255); // Purple color for the lines representing women having a bank or savings account in rural areas
    stitchMetric(lineXWomenBankAccountRural, y + sectionHeight - 10, lineXWomenBankAccountRural, y + sectionHeight - 10 - lineLengthWomenBankAccountRural,
      stateName, "Bank or savings account (Rural)", womenBankAccountRural);

    // Draw a vertical line representing women having a bank or savings account Urban
    float lineXWomenBankAccountUrban = x + 80; // Right aligned with padding
    float lineLengthWomenBankAccountUrban = map(womenBankAccountUrban, 0, 100, 0, sectionHeight - 50); // Adjusting for padding
    stroke(255, 0, 255); // Purple color for the lines representing women having a bank or savings account in urban areas
    stitchMetric(lineXWomenBankAccountUrban, y + sectionHeight - 10, lineXWomenBankAccountUrban, y + sectionHeight - 10 - lineLengthWomenBankAccountUrban,
      stateName, "Bank or savings account (Urban)", womenBankAccountUrban);
  }
}

// Draw a metric as a running-stitch line AND record it for hover tooltips
void stitchMetric(float x1, float y1, float x2, float y2, String state, String label, float value) {
  strokeWeight(1.5);
  stitchLine(x1, y1, x2, y2);
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

// Running-stitch frame just outside each box
void drawStitchBorder(float x, float y, float w, float h) {
  stroke(150, 90, 60); // thread color
  strokeWeight(1);
  float o = 3; // how far outside the box
  stitchLine(x - o, y - o, x + w + o, y - o);         // top
  stitchLine(x + w + o, y - o, x + w + o, y + h + o); // right
  stitchLine(x + w + o, y + h + o, x - o, y + h + o); // bottom
  stitchLine(x - o, y + h + o, x - o, y - o);         // left
}

// Full state name on top of the box, shrunk (and wrapped if needed) to fit
void drawStateName(String name, float boxX, float boxY, float boxW) {
  fill(255); // white text on the black box
  textAlign(CENTER, TOP);
  float maxW = boxW - 6;

  // Try to fit on one line, shrinking the size down to a floor
  float ts = 12;
  while (ts > 6) {
    textSize(ts);
    if (textWidth(name) <= maxW) break;
    ts -= 0.5;
  }
  textSize(ts);
  if (textWidth(name) <= maxW) {
    text(name, boxX + boxW / 2, boxY + 3);
    return;
  }

  // Still too long: word-wrap onto up to two lines at the floor size
  textSize(6);
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
  text(line1, boxX + boxW / 2, boxY + 2);
  if (line2.length() > 0) {
    text(line2, boxX + boxW / 2, boxY + 9);
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
