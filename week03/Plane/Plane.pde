
class Plane {
  float edge;
  float extrude;

  Plane() {
    edge = 400;
    extrude = 20;
  }
  
  void display() {
    stroke(255, 0, 0); // red
    line(-500, 0, 0, 500, 0,0);
    pushMatrix();
    translate(500, 0, 0);
    box(extrude, extrude, extrude);
    popMatrix();
    
    stroke(0,255,0); // green
    line(0, -500, 0, 0, 500, 0);
    pushMatrix();
    translate(0, 500, 0);
    box(extrude, extrude, extrude);
    popMatrix();
    
    stroke(0,0,255); // blue
    line(0, 0, -500, 0, 0, 500);
    pushMatrix();
    translate(0, 0, 500);
    box(extrude, extrude, extrude);
    popMatrix();
    
    box(edge, extrude, edge);
  }
  
}