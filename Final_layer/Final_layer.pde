import java.util.HashMap;
import java.util.Arrays;

Table table;
int numRows = 4;
int numCols = 9;
int sectionWidth;
int sectionHeight;

// Tooltip variables
String tooltipText = "";
boolean showTooltip = false;
float tooltipX, tooltipY;

// Rankings for each variable
HashMap<String, Integer>[] rankings;

void setup() {
  size(1000, 800);
  table = loadTable("Urban Rural Data Cleaned.csv", "header");
  sectionWidth = (width - 100) / numCols;
  sectionHeight = (height - 60) / numRows;
  textSize(12);

  rankings = new HashMap[table.getColumnCount()];
  for (int i = 2; i < table.getColumnCount(); i++) {
    rankings[i] = new HashMap<String, Integer>();
    float[] values = new float[table.getRowCount()];
    String[] states = new String[table.getRowCount()];
    for (int j = 0; j < table.getRowCount(); j++) {
      states[j] = table.getString(j, 1);
      values[j] = table.getFloat(j, i);
    }
    Integer[] indices = sortIndices(values);
    for (int j = 0; j < indices.length; j++) {
      rankings[i].put(states[indices[j]], j + 1);
    }
  }
}

void draw() {
  background(#F2E4C9);
  drawSections();
  drawDottedBorder();
  checkForTooltip();
  if (showTooltip) {
    fill(255);
    rect(tooltipX, tooltipY, 220, 75);
    fill(0);
    text(tooltipText, tooltipX + 5, tooltipY + 15);
  }
}

void drawSections() {
  for (int i = 0; i < table.getRowCount(); i++) {
    TableRow row = table.getRow(i);
    int rowIdx = i / numCols;
    int colIdx = i % numCols;
    int x = 50 + colIdx * sectionWidth;
    int y = 30 + rowIdx * sectionHeight;
    drawStateBox(x, y, sectionWidth, sectionHeight, row);
  }
}

void drawStateBox(int x, int y, int w, int h, TableRow row) {
  fill(#F2E4C9);
  drawDottedRect(x, y, w, h);
  int smallCols = 3;
  int smallRows = 4;
  int smallBoxWidth = w / smallCols;
  int smallBoxHeight = h / smallRows;

  for (int i = 0; i < 12; i++) {
    int smallX = x + (i % smallCols) * smallBoxWidth;
    int smallY = y + (i / smallCols) * smallBoxHeight;
    int lines = (int) row.getFloat(i + 2) / 5;
    if (i < 6) {
      drawSlantingLines(smallX, smallY, smallBoxWidth, smallBoxHeight, lines);
    } else {
      drawSlantingLinesOpposite(smallX, smallY, smallBoxWidth, smallBoxHeight, lines);
    }
  }
}

// Define these functions if they're missing
void drawSlantingLines(int x, int y, int w, int h, int lines) {
  stroke(#E366F2);
  strokeWeight(0.5);
  float spacing = (float) w / lines;
  for (int i = 0; i < lines; i++) {
    line(x + i * spacing, y + h, x + w, y + i * spacing);
  }
}

void drawSlantingLinesOpposite(float x, float y, float w, float h, int lines) {
  stroke(#8B008B); // Dark magenta for rural lines
  strokeWeight(0.5);
  float spacing = h / (float) lines;
  for (int i = 0; i < lines; i++) {
    line(x, y + i * spacing, x + w, y + h);
  }
}

void checkForTooltip() {
  showTooltip = false;
  for (int i = 0; i < table.getRowCount(); i++) {
    TableRow row = table.getRow(i);
    int rowIdx = i / numCols;
    int colIdx = i % numCols;
    int x = 50 + colIdx * sectionWidth;
    int y = 30 + rowIdx * sectionHeight;
    int smallCols = 3;
    int smallRows = 4;
    int smallBoxWidth = sectionWidth / smallCols;
    int smallBoxHeight = sectionHeight / smallRows;

    for (int j = 0; j < 12; j++) {
      int smallX = x + (j % smallCols) * smallBoxWidth;
      int smallY = y + (j / smallCols) * smallBoxHeight;

      if (mouseX >= smallX && mouseX <= smallX + smallBoxWidth && mouseY >= smallY && mouseY <= smallY + smallBoxHeight) {
        String varName = table.getColumnTitle(j + 2);
        String stateName = row.getString(1);
        float value = row.getFloat(j + 2);
        int rank = rankings[j + 2].get(stateName);

        tooltipText = "State: " + stateName + "\nVariable: " + varName + "\nValue: " + value + "\nRank: " + rank;
        tooltipX = mouseX;
        tooltipY = mouseY;
        showTooltip = true;
        return;
      }
    }
  }
}

Integer[] sortIndices(float[] values) {
  Integer[] indices = new Integer[values.length];
  for (int i = 0; i < values.length; i++) indices[i] = i;
  Arrays.sort(indices, (a, b) -> Float.compare(values[b], values[a]));
  return indices;
}

void drawDottedRect(int x, int y, int w, int h) {
  stroke(#E366F2);
  strokeWeight(1);
  float dashLength = 4;
  float spaceLength = 4;

  for (float i = x; i < x + w; i += dashLength + spaceLength) {
    line(i, y, i + dashLength, y);
    line(i, y + h, i + dashLength, y + h);
  }

  for (float i = y; i < y + h; i += dashLength + spaceLength) {
    line(x, i, x, i + dashLength);
    line(x + w, i, x + w, i + dashLength);
  }
}

void drawDottedBorder() {
  stroke(#E366F2);
  strokeWeight(1);
  float dashLength = 4;
  float spaceLength = 4;

  for (float i = 50; i <= width - 50; i += dashLength + spaceLength) {
    line(i, 30, i + dashLength, 30);
    line(i, height - 30, i + dashLength, height - 30);
  }

  for (float i = 30; i <= height - 30; i += dashLength + spaceLength) {
    line(50, i, 50, i + dashLength);
    line(width - 50, i, width - 50, i + dashLength);
  }
}
