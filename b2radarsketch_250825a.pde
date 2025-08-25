import processing.serial.*;
import java.awt.event.KeyEvent;
import java.io.IOException;
import java.util.ArrayList;

Serial myPort;
String angle = "", distance = "", data = "", noObject;
float pixsDistance;
int iAngle, iDistance, index1 = 0;
PFont techFont;

int lastUpdateTime = 0;
boolean isConnected = false;
ArrayList<String> radarLog = new ArrayList<String>();

void setup() {
  size(1920, 1080);
  smooth();
  myPort = new Serial(this, "COM5", 9600);
  myPort.bufferUntil('.');
  techFont = createFont("Consolas", 20);
  textFont(techFont);
}

void draw() {
  fill(0, 4);
  noStroke();
  rect(0, 0, width, height);

  textFont(techFont);
  drawConnectionStatusIcon();
  drawAngleIndicator();
  drawDistanceBar();
  drawRadar();
  drawLine();
  drawObject();
  drawText();
  drawTechnicalPanel();
}

void serialEvent(Serial myPort) {
  data = myPort.readStringUntil('.');
  data = data.substring(0, data.length() - 1);

  index1 = data.indexOf(",");
  angle = data.substring(0, index1);
  distance = data.substring(index1 + 1);

  iAngle = int(angle);
  iDistance = int(distance);

  lastUpdateTime = millis();
  isConnected = true;

  radarLog.add("Angle: " + iAngle + "°, Distance: " + iDistance + "cm");
  if (radarLog.size() > 5) radarLog.remove(0);
}

void drawRadar() {
  pushMatrix();
  translate(960, 700);
  noFill();
  strokeWeight(2);
  stroke(180);
  arc(0, 0, 1200, 1200, PI, TWO_PI);
  arc(0, 0, 900, 900, PI, TWO_PI);
  arc(0, 0, 600, 600, PI, TWO_PI);
  arc(0, 0, 300, 300, PI, TWO_PI);
  line(-600, 0, 600, 0);
  for (int a = 30; a <= 150; a += 30) {
    line(0, 0, -600 * cos(radians(a)), -600 * sin(radians(a)));
  }
  fill(180);
  textSize(16);
  text("10cm", 600, 0);
  text("20cm", 900, 0);
  text("30cm", 1200, 0);
  text("40cm", 1500, 0);
  popMatrix();
}

void drawObject() {
  pushMatrix();
  translate(960, 700);
  strokeWeight(9);
  stroke(255, 10, 10);
  pixsDistance = iDistance * 15.0;
  if (iDistance < 40) {
    line(pixsDistance * cos(radians(iAngle)), -pixsDistance * sin(radians(iAngle)),
         600 * cos(radians(iAngle)), -600 * sin(radians(iAngle)));
    fill(255, 0, 0);
    noStroke();
    ellipse(pixsDistance * cos(radians(iAngle)), -pixsDistance * sin(radians(iAngle)), 10, 10);
  }
  popMatrix();
}

void drawLine() {
  pushMatrix();
  translate(960, 700);
  stroke(255, 80);
  strokeWeight(16);
  line(0, 0, 600 * cos(radians(iAngle)), -600 * sin(radians(iAngle)));
  stroke(255);
  strokeWeight(9);
  line(0, 0, 600 * cos(radians(iAngle)), -600 * sin(radians(iAngle)));
  popMatrix();
}

void drawText() {
  noObject = (iDistance > 40) ? "Out of Range" : "In Range";

  // Sağ üst panel
  fill(30);
  rect(1600, 850, 320, 240); // Panel
  fill(255);
  textSize(60); // Puntosu büyütüldü (önceden 48)
  text("Angle: " + iAngle + "°", 1620, 900);
  text("Distance: " + iDistance + " cm", 1620, 960);
  textSize(36); // Status için biraz büyütüldü (önceden 32)
  text("Status: " + noObject, 1620, 1020);

  // Alt bilgi paneli
  pushMatrix();
  fill(0);
  noStroke();
  rect(0, 950, width, 150);
  fill(255);
  textSize(28);
  text("10cm", 1180, 930);
  text("20cm", 1380, 930);
  text("30cm", 1580, 930);
  text("40cm", 1780, 930);

  textSize(70); // Alt paneldeki ana bilgiler büyütüldü (önceden 55)
  text("Object: " + noObject, 240, 1020);
  text("Angle: " + iAngle + " °", 1050, 1020);
  text("Distance: ", 1380, 1020);
  if (iDistance < 40) {
    text("        " + iDistance + " cm", 1400, 1020);
  }

  // Radar açı etiketleri
  textSize(25);
  fill(255);
  translate(961 + 600 * cos(radians(30)), 682 - 600 * sin(radians(30)));
  rotate(-radians(-60));
  text("30°", 0, 0);
  resetMatrix();
  translate(954 + 600 * cos(radians(60)), 684 - 600 * sin(radians(60)));
  rotate(-radians(-30));
  text("60°", 0, 0);
  resetMatrix();
  translate(945 + 600 * cos(radians(90)), 690 - 600 * sin(radians(90)));
  rotate(radians(0));
  text("90°", 0, 0);
  resetMatrix();
  translate(935 + 600 * cos(radians(120)), 703 - 600 * sin(radians(120)));
  rotate(radians(-30));
  text("120°", 0, 0);
  resetMatrix();
  translate(940 + 600 * cos(radians(150)), 718 - 600 * sin(radians(150)));
  rotate(radians(-60));
  text("150°", 0, 0);
  popMatrix();
}


void drawTechnicalPanel() {
  fill(50);
  rect(20, 20, 320, 400);
  fill(255);
  textSize(22);
  text("TechnLife+", 40, 50);
  text("FPS: " + int(frameRate), 40, 80);
  text("Last Update: " + (millis() - lastUpdateTime) + " ms", 40, 110);
  text("Signal Strength: " + (iDistance < 40 ? int(map(iDistance, 0, 40, 100, 20)) + "%" : "N/A"), 40, 140);
  text("Connection: " + (isConnected ? "Active" : "Waiting..."), 40, 170);

  String currentTime = nf(hour(), 2) + ":" + nf(minute(), 2) + ":" + nf(second(), 2);
  text("Time: " + currentTime, 40, 200);

  textSize(14);
  for (int i = 0; i < radarLog.size(); i++) {
    text(radarLog.get(i), 40, 220 + i * 20);
  }
}

void drawAngleIndicator() {
  fill(30);
  stroke(255);
  strokeWeight(2);
  ellipse(150, 220, 100, 100);
  fill(255);
  textSize(20);
  textAlign(CENTER, CENTER);
  text(iAngle + "°", 150, 220);
}

void drawDistanceBar() {
  fill(30);
  rect(1650, 200, 200, 30);
  if (iDistance < 40) {
    fill(255);
    float barLength = map(iDistance, 0, 40, 0, 200);
    rect(1650, 200, barLength, 30);
  }
  fill(255);
  textSize(18);
  textAlign(LEFT, CENTER);
  text("Distance: " + iDistance + " cm", 1650, 180);
}

void drawConnectionStatusIcon() {
  fill(isConnected ? color(0, 255, 0) : color(255, 0, 0));
  noStroke();
  ellipse(360, 30, 20, 20);
}
