import java.util.HashMap;
import java.util.Arrays;

Table table;
int numRows = 4;
int numCols = 9;
int sectionWidth;
int sectionHeight;
PImage overlayImage;
PFont playfairRegular;  // Declare the regular font variable globally
PFont playfairBold;     // Declare the bold font variable globally
PFont playfairItalic;

// Tooltip variables
String tooltipText = "";
boolean showTooltip = false;
float tooltipX, tooltipY;

// Rankings for each variable
HashMap<String, Integer>[] rankings;

void setup() {
  size(1440, 800);  // Updated canvas size
  
  playfairRegular = createFont("PlayfairDisplay-Regular.ttf", 24);  
  playfairBold = createFont("PlayfairDisplay-Bold.ttf", 32);  
  playfairItalic = createFont("PlayfairDisplay-Italic.ttf", 24);
  textFont(playfairRegular);  // Set initial font to regular
 
  table = loadTable("Urban Rural Data Cleaned copy.csv", "header");
  sectionWidth = (width - 440) / numCols;  // Adjusted for new canvas width
  sectionHeight = (height - 60) / numRows;
  textSize(12);
  overlayImage = loadImage("overlay.jpg");
  background(245, 245, 220); // Warm beige background
  pixelDensity(2);


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
  background(245, 245, 220);
  fill(0);  // Set text color to black
  textSize(20);  // Optionally set or adjust the text size
  
  //blendMode(DARKEST);
  //image(overlayImage, 0, 0, width, height); // Adjust size and position as needed
 // blendMode(BLEND);
  
  
 drawSections();
  //drawDottedBorder();
  checkForTooltip();
  
  if (showTooltip) {
    textSize(12); // Ensures consistent text sizing
    float tooltipTextWidth = textWidth(tooltipText) + 10;  // Calculate the width of the tooltip text and add some padding
      
    // Calculate the height based on the number of text lines and add some padding
    // Let's assume each line needs about 20 pixels height (arbitrarily chosen for padding and line height)
    float lines = tooltipText.split("\n").length;  // Count the number of lines
    float tooltipTextHeight = lines * 20 + 20;  // 20 pixels per line + 20 pixels padding


    // Ensure the tooltip box does not go outside the canvas boundaries
    float tooltipRectWidth = max(220, tooltipTextWidth);
    float tooltipRectHeight = max(75, tooltipTextHeight);
    float tooltipRectX = tooltipX;
    float tooltipRectY = tooltipY;

    // Adjust tooltip position to avoid drawing outside the window
    if (tooltipRectX + tooltipRectWidth > width) {
      tooltipRectX -= (tooltipRectX + tooltipRectWidth - width);
    }
    if (tooltipRectY + tooltipRectHeight > height) {
      tooltipRectY -= (tooltipRectY + tooltipRectHeight - height);
    }
    fill(255);
    rect(tooltipRectX, tooltipRectY, tooltipRectWidth, tooltipRectHeight);
    fill(0);
    text(tooltipText, tooltipRectX + 5, tooltipRectY + 15, tooltipRectWidth - 10, tooltipRectHeight - 10);
  
  }

  // Draw the header and subtitle on the right
  fill(0);// Set text color to black
  textFont(playfairBold);
  textSize(30); // Set text size for the header
  text("Stitching Statistics", 1080, 80);  // Draw the header at position (1050, 100)
  
  textFont(playfairRegular); // Setting regular font for the subtitle and other texts
  textSize(15); // Set text size for the subtitle
  text("A Tapestry of Urban and Rural Women’s Disparities", 1080, 115);  // Draw the subtitle at position (1050, 140)
  textSize(12);
  text("Vrnda Aiyaswamy", 1080, 750);
  textSize(12);
  text("Information Design Studio 2", 1080, 770);

  textSize(14);
String description = "This interactive visualization presents a comprehensive comparison of urban and rural characteristics across various states, artistically rendered in a quilt-like format.\n\nEach patch of the quilt represents a state, divided into segments that depict key metrics such as population density, economic factors, and social attributes. Users can explore detailed information through tooltips that appear over each state's section, offering insights into specific data points and rankings. \n\nThe visualization not only provides visual comparison across regions but also engages viewers with its unique, dynamic stitching motion, symbolizing the weaving together of diverse urban and rural narratives into a cohesive national tapestry.\nThis approach invites users to uncover the intricate patterns of life across urban and rural landscapes, through visual exploration.";

// Define the area for the description text
float textX = 1080;
float textY = 175;  // Starting below the subtitle
float padding = 50; // Padding on the right side
float textWidth = width - textX - padding;  // Calculate the width considering padding
text(description, textX, textY, textWidth, height - textY);

  
  drawLegend();
  }


void drawSections() {
  int xOffset = 0;  // Adjust the xOffset to move the visualization to the left
  for (int i = 0; i < table.getRowCount(); i++) {
    TableRow row = table.getRow(i);
    int rowIdx = i / numCols;
    int colIdx = i % numCols;
    int x = xOffset + 50 + colIdx * sectionWidth;  // Updated x coordinate
    int y = 30 + rowIdx * sectionHeight;
    drawStateBox(x, y, sectionWidth, sectionHeight, row);
  }
}

void drawStateBox(int x, int y, int w, int h, TableRow row) {
  //fill(#F2E4C9);  // Background fill for the box
  drawDottedRect(x, y, w, h);  // Draw the outline of the box
  int smallCols = 3;
  int smallRows = 4;
  int smallBoxWidth = w / smallCols;
  int smallBoxHeight = h / smallRows;

  for (int i = 0; i < 12; i++) {
    int smallX = x + (i % smallCols) * smallBoxWidth;
    int smallY = y + (i / smallCols) * smallBoxHeight;
    int lines = (int) row.getFloat(i + 2) / 5;

    if (i % 2 == 0) {  // Check if index i is even (0-based)
      stroke(#E366F2);  // Use purple for even-indexed boxes
    } else {  // Otherwise, index i is odd
      stroke(#8B008B);  // Use dark magenta for odd-indexed boxes
    }

    // Determine which type of line pattern to draw based on box index
    if (i < 6) {
      drawSlantingLines(smallX, smallY, smallBoxWidth, smallBoxHeight, lines);
    } else {
      drawSlantingLinesOpposite(smallX, smallY, smallBoxWidth, smallBoxHeight, lines);
    }
  }
}

// Modified to remove the stroke setting
void drawSlantingLines(int x, int y, int w, int h, int lines) {
  strokeWeight(0.5);
  float spacing = (float) w / lines;
  for (int i = 0; i < lines; i++) {
    line(x + i * spacing, y + h, x + w, y + i * spacing);
  }
}

// Modified to remove the stroke setting
void drawSlantingLinesOpposite(float x, float y, float w, float h, int lines) {
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
  strokeWeight(1.5);
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

void drawLegend() { // Legend properties
  int legendX = 1080;  // X position of the legend
  int legendY = 600;   // Initial Y position of the legend, adjusted down
  int legendWidth = 160;  // Width of the legend box, adjusted for 5 boxes
  int legendHeight = 120; // Height of the legend box, adjusted for 5 boxes
  int smallBoxSize = 20;  // Size of the small boxes
  int numLines = 5;  // Number of lines in each small box
  int textOffset = 30;  // Offset for text labels from the boxes

  // Draw the legend background box
  fill(245, 245, 220);  // Same as canvas background
  noStroke();
  rect(legendX, legendY, legendWidth, legendHeight);

  // Define positions for each small box, adjusting for moving boxes up
  int box1X = legendX + 10;
  int box1Y = legendY + 80;  // First box
  int box2X = legendX + 10;
  int box2Y = legendY + 50;   // Second box
  int box3X = legendX + 10;
  int box3Y = legendY + 20;   // Third box
  int box4X = legendX + 10;
  int box4Y = legendY - 5;   // Fourth box, top most

  // Draw the first two boxes with specific colors
  fill(#E366F2);  // Light purple color for the first box
  rect(box1X, box1Y, smallBoxSize, smallBoxSize);
  fill(#8B008B);  // Dark purple color for the second box
  rect(box2X, box2Y, smallBoxSize, smallBoxSize);

  // Draw the last two boxes with white background
  fill(255);  // White boxes for boxes 3 and 4
  rect(box3X, box3Y, smallBoxSize, smallBoxSize);
  rect(box4X, box4Y, smallBoxSize, smallBoxSize);

  // Adding labels next to each box
  fill(0);  // Black text color
  //textFont(playfairItalic);
  textSize(12);  // Text size for labels
  text("Rural Area", box1X + smallBoxSize + textOffset, box1Y + smallBoxSize / 2);
  text("Urban Area", box2X + smallBoxSize + textOffset, box2Y + smallBoxSize / 2);
  text("Economic Empowerment", box3X + smallBoxSize + textOffset, box3Y + smallBoxSize / 2);
  text("Education Factors", box4X + smallBoxSize + textOffset, box4Y + smallBoxSize / 2);

  // Patterns in Box 3 and Box 4
  stroke(0); // Black lines for visibility against white
  strokeWeight(0.75);
  // Opposite slanting lines in Box 3
  for (int i = 0; i < numLines; i++) {
    line(box3X + smallBoxSize, box3Y + smallBoxSize, box3X, box3Y + (i * (smallBoxSize / (numLines - 1))));
  }
  // Slanting lines in Box 4
  for (int i = 0; i < numLines; i++) {
    line(box4X + (i * (smallBoxSize / (numLines - 1))), box4Y + smallBoxSize, box4X + smallBoxSize, box4Y + (i * (smallBoxSize / (numLines - 1))));
  }
}
