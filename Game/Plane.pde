
class Plane {

  Plane() {
    
  }
  
   /* Display a cylinder under the cursor :
     * We are now in ortho mode, thus, the plate has the same size on screen
     * at any distance in front of the camera.
     */
  PVector positionOnPlate() {
     float xCursorOnPlate = mouseX - WIDTH/2;
     float yCursorOnPlate = mouseY - HEIGHT/2;
     
     if (xCursorOnPlate < -PLATE_WIDTH/2 + CYLINDER_RADIUS) {
       xCursorOnPlate = -PLATE_WIDTH/2 + CYLINDER_RADIUS;
     }
     else if (xCursorOnPlate > PLATE_WIDTH/2 - CYLINDER_RADIUS) {
       xCursorOnPlate = PLATE_WIDTH/2 - CYLINDER_RADIUS;
     }
     
     if (yCursorOnPlate < -PLATE_DEPTH/2 + CYLINDER_RADIUS) {
       yCursorOnPlate = -PLATE_DEPTH/2 + CYLINDER_RADIUS;
     }
     else if (yCursorOnPlate > PLATE_DEPTH/2 - CYLINDER_RADIUS) {
       yCursorOnPlate = PLATE_DEPTH/2 - CYLINDER_RADIUS;
     }
     
     return new PVector(xCursorOnPlate, yCursorOnPlate);
  }
 
  void display() {
    stroke(255, 0, 0);
    line(-AXIS_LENGTH, 0, 0, AXIS_LENGTH, 0, 0);
    pushMatrix();
    translate(AXIS_LENGTH, 0, 0);
    box(extrude, extrude, extrude);
    popMatrix();
    
    stroke(0, 255, 0);
    line(0, -AXIS_LENGTH, 0, 0, AXIS_LENGTH, 0);
    pushMatrix();
    translate(0, AXIS_LENGTH, 0);
    box(extrude, extrude, extrude);
    popMatrix();
    
    stroke(0, 0, 255);
    line(0, 0, -AXIS_LENGTH, 0, 0, AXIS_LENGTH);
    pushMatrix();
    translate(0, 0, AXIS_LENGTH);
    box(extrude, extrude, extrude);
    popMatrix();

    stroke(50, 50, 50);
    box(PLATE_WIDTH, PLATE_HEIGHT, PLATE_DEPTH); // Draw plate
  }
  
}
