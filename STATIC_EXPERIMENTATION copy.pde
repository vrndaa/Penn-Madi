Table table;
void setup() {
  size(1000, 800);
  table = loadTable("Urban Rural Data Cleaned.csv", "header");
}
void draw() {
  background(255); // Clear the background on each frame drawSections(); // Call the drawSections function in the draw loop
  drawSections();
}

void drawSections() {
  int startX = 50;
  int startY = 50;
  int sectionWidth = (width - 2 * startX) / 8;
  int sectionHeight = (height - 2 * startY) / 5;
  for (int i = 0; i < table.getRowCount(); i++) {
    TableRow row = table.getRow(i);
    int x = startX + (i % 8) * sectionWidth;
    int y = startY + (i / 8) * sectionHeight;
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

    fill(0);
    stroke(4);
    strokeWeight(1.5);
    rect(x, y, sectionWidth, sectionHeight);

    // Add abbreviation text
    fill(255); // White color for text
    textSize(12); // Set text size
    textAlign(RIGHT, TOP); // Align text to the top right
    String abbreviation = row.getString("Abbreviation"); // Get abbreviation from the "Abbreviation" column
    text(abbreviation, x + sectionWidth - 5, y + 5); // Display abbreviation at the top right corner of the state box

    // Draw a horizontal line representing women literate in rural areas
    float lineYRuralLiterate = y + sectionHeight / 6; // Adjusted position to push closer to the top and create a gap
    float lineLengthRuralLiterate = map(literateRural, 0, 100, 0, sectionWidth - 20); // Adjusting for padding
    stroke(555, 345, 100); // Red color for the rural lines strokeWeight(1); // Fixed stroke weight
    line(x + 10, lineYRuralLiterate, x + 10 + lineLengthRuralLiterate, lineYRuralLiterate); // Adjusting for padding and drawing the line

    // Draw a horizontal line representing women literate in urban areas
    float lineYUrbanLiterate = y + sectionHeight / 4; // Adjusted position to create a gap
    float lineLengthUrbanLiterate = map(literateUrban, 0, 100, 0, sectionWidth - 20); // Adjusting for padding
    stroke(100, 555, 100); // Green color for the urban lines
    line(x + 10, lineYUrbanLiterate, x + 10 + lineLengthUrbanLiterate, lineYUrbanLiterate); // Adjusting for padding and drawing the line
    
    //stroke(255);
    //noFill();
    //rect(x+10, lineYRuralLiterate-10, 90, 30);  // drawing box around the first horizontal line
    
    

    // Draw a horizontal line representing women with 10 or more years of schooling in rural areas
    float lineYRuralSchooling = y + sectionHeight * 3 / 6;
    float lineLengthRuralSchooling = map(schoolingRural, 0, 100, 0, sectionWidth - 20); // Adjusting for padding
    stroke(255, 105, 180); // Pink color for the lines representing schooling rural
    line(x + 10, lineYRuralSchooling, x + 10 + lineLengthRuralSchooling, lineYRuralSchooling); // Adjusting for padding

    // Draw a horizontal line representing women with 10 or more years of schooling in urban areas
    float lineYUrbanSchooling = y + sectionHeight * 4 / 7; // Adjusted position to push closer to the bottom and create a gap
    float lineLengthUrbanSchooling = map(schoolingUrban, 0, 100, 0, sectionWidth - 20); // Adjusting for padding
    stroke(220, 150, 255); // Light purple color for the lines representing schooling urban
    line(x + 10, lineYUrbanSchooling, x + 10 + lineLengthUrbanSchooling, lineYUrbanSchooling); // Adjusting for padding

    // Draw a horizontal line representing female population age 6 years and above attended school in rural areas
    float lineYRuralAttended = y + sectionHeight * 4.75 / 6; // Adjusted position to push closer to the bottom and create a gap
    float lineLengthRuralAttended = map(attendedSchoolRural, 0, 100, 0,
      sectionWidth - 20); // Adjusting for padding
    stroke(255, 200, 100); // Yellow color for the lines representing attended school rural
    line(x + 10, lineYRuralAttended, x + 10 + lineLengthRuralAttended, lineYRuralAttended); // Adjusting for padding

    // Draw a horizontal line representing female population age 6 years and above attended school in urban areas
    float lineYUrbanAttended = y + sectionHeight * 6 / 7; // Adjusted position to push closer to the bottom
    float lineLengthUrbanAttended = map(attendedSchoolUrban, 0, 100, 0, sectionWidth - 20); // Adjusting for padding
    stroke(100, 200, 255); // Light blue color for the lines representing attended school urban
    line(x + 10, lineYUrbanAttended, x + 10 + lineLengthUrbanAttended, lineYUrbanAttended); // Adjusting for padding

    // Draw a vertical line representing women who worked and were paid in cash Rural
    float lineXWomenWorkedCashRural = x + 10; // Left aligned with padding
    float lineLengthWomenWorkedCashRural = map(womenWorkedCashRural, 0, 100, 0, sectionHeight - 10); // Adjusting for padding
    stroke(158, 168, 41); // Olive green color for the lines representing women worked and paid in cash rural
    line(lineXWomenWorkedCashRural, y + sectionHeight - 10, lineXWomenWorkedCashRural, y + sectionHeight - 10 - lineLengthWomenWorkedCashRural); // Adjusting for padding and drawing the line

    // Draw a vertical line representing women who worked and were paid in cash Urban
    float lineXWomenWorkedCashUrban = x + 20; // Right aligned with padding
    float lineLengthWomenWorkedCashUrban = map(womenWorkedCashUrban, 0, 100, 0, sectionHeight - 10); // Adjusting for padding
    stroke(158, 168, 41); // Olive green color for the lines representing women worked and paid in cash urban
    line(lineXWomenWorkedCashUrban, y + sectionHeight - 10, lineXWomenWorkedCashUrban, y + sectionHeight - 10 - lineLengthWomenWorkedCashUrban); // Adjusting for padding and drawing the line

    // Draw a vertical line representing women owning a house and/or land Rural
    float lineXWomenOwnHouseLandRural = x + 40; // Left aligned with padding
    float lineLengthWomenOwnHouseLandRural = map(womenOwnHouseLandRural, 0, 100, 0, sectionHeight - 40); // Adjusting for padding
    stroke(110, 84, 15); // Brown color for the lines representing women owning a house and/or land rural
    line(lineXWomenOwnHouseLandRural, y + sectionHeight - 10, lineXWomenOwnHouseLandRural, y + sectionHeight - 10 - lineLengthWomenOwnHouseLandRural); // Adjusting for padding and drawing the line

    // Draw a vertical line representing women owning a house and/or land Urban
    float lineXWomenOwnHouseLandUrban = x + 50; // Right aligned with padding
    float lineLengthWomenOwnHouseLandUrban = map(womenOwnHouseLandUrban, 0, 100, 0, sectionHeight - 40); // Adjusting for padding
    stroke(110, 84, 15); // Brown color for the lines representing women owning a house and/or land urban
    line(lineXWomenOwnHouseLandUrban, y + sectionHeight - 10, lineXWomenOwnHouseLandUrban, y + sectionHeight - 10 - lineLengthWomenOwnHouseLandUrban); // Adjusting for padding and drawing the line

    // Draw a vertical line representing women having a bank or savings account Rural
    float lineXWomenBankAccountRural = x + 70; // Right aligned with padding
    float lineLengthWomenBankAccountRural = map(womenBankAccountRural, 0, 100, 0, sectionHeight - 50); // Adjusting for padding
    stroke(255, 0, 255); // Purple color for the lines representing women having a bank or savings account in rural areas
    line(lineXWomenBankAccountRural, y + sectionHeight - 10, lineXWomenBankAccountRural, y + sectionHeight - 10 - lineLengthWomenBankAccountRural); // Adjusting for padding and drawing the line

    // Draw a vertical line representing women having a bank or savings account Urban
    float lineXWomenBankAccountUrban = x + 80; // Right aligned with padding
    float lineLengthWomenBankAccountUrban = map(womenBankAccountUrban, 0, 100, 0, sectionHeight - 50); // Adjusting for padding
    stroke(255, 0, 255); // Purple color for the lines representing women having a bank or savings account in urban areas
    line(lineXWomenBankAccountUrban, y + sectionHeight - 10, lineXWomenBankAccountUrban, y + sectionHeight - 10 - lineLengthWomenBankAccountUrban); // Adjusting for padding and drawing the line
  }
}
