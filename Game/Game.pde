final int WIDTH = 500;
final int HEIGHT = 500;

final int CAMERA_DEPTH = 750;
final int CAMERA_DEPTH_OBSTACLE = 50;
final int CAMERA_HEIGHT = 500;

final int AXIS_LENGTH = 300;

float angleX = 0;
float angleY = 0;
float angleZ = 0;
float oldAngleX;
float oldAngleY;
float oldAngleZ;

final float MAX_ROTATION = PI/3;
final float MAX_ROTATION_SPEED = 0.05;
final float MIN_ROTATION_SPEED = 0.0001;
final float ROTATION_INCREMENT = 0.001;
float rotationSpeed = 0.005;

float extrude = 20;
float movementScale = 0;

final float G = 0.2;
final float MU = 0.02;

final float PLATE_HEIGHT = 20;
final float PLATE_WIDTH = 300;
final float PLATE_DEPTH = 300;

final float BALL_RADIUS = 10;

final float CYLINDER_RADIUS = 20;
final float CYLINDER_HEIGHT = 50;
final float RECT_MARGIN = 50;

enum Mode {
  JEU, OBSTACLE
};
Mode mode = Mode.JEU;

Mover mover;
int nbCylinder;
ArrayList<Cylinder> cylinders;
Cylinder dummyCylinder;

void settings() {
  size(WIDTH, HEIGHT, P3D);
}

void setup() {
  nbCylinder = 0;
  cylinders = new ArrayList<Cylinder>();
  dummyCylinder = new Cylinder(new PVector(0,0,0));
  mover = new Mover();
}

void draw() {
  /*
    Drawing 3D context
   */

  background(200);
  ambientLight(102, 102, 102);
  fill(255);
  
  if (mode == Mode.JEU) {
    perspective();
    camera(0, -CAMERA_HEIGHT, CAMERA_DEPTH, 0, 0, 0, 0, 1, 0);
    directionalLight(50, 100, 125, 0, 1, 0);
    directionalLight(50, 100, 125, 0, -1, 0);
    
    /*
    angleX = map(mouseY, 0, WIDTH, -PI/3, PI/3);
    angleZ = map(mouseX, 0, HEIGHT, -PI/3, PI/3);
    */
    
    rotateX(-angleX);
    rotateY(angleY);
    rotateZ(angleZ);

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

    noStroke();
    for (int i = 0; i < nbCylinder; ++i){
      cylinders.get(i).display();
    }

    mover.update();
    mover.checkEdges();
    for (int i = 0; i < nbCylinder; ++i){
      mover.checkCylinderCollision(cylinders.get(i).position.get(), cylinders.get(i).cylinderBaseSize);
    }
    fill(0,255,0);
    mover.display();
  } 
  else if (mode == Mode.OBSTACLE) {
    /* In ortho mode, all objects of same size appear the same 
     * size regardless of how far they are from the camera
     */
    ortho(); 
    camera(0, 0, CAMERA_DEPTH_OBSTACLE, 0, 0, 0, 0, 1, 0);
    directionalLight(50, 100, 125, 0, 0, -1);
    
    rotateX(-angleX);
    rotateY(angleY);
    rotateZ(angleZ);
        
    stroke(50,50,50);
    box(PLATE_WIDTH, PLATE_HEIGHT, PLATE_DEPTH); // Draw plate 
    noStroke();
    fill(0,255,0);
    mover.display();

    fill(0,0,255);
    for (int i = 0; i < nbCylinder; ++i){
      cylinders.get(i).display();
    }
    
    /* Display a cylinder under the cursor :
     * We are now in ortho mode, thus, the plate has the same size on screen
     * at any distance in front of the camera.
     */
     
     PVector position = positionOnPlate();
     // The plate is oriented in the x-y plane.
     translate(position.x, -(PLATE_HEIGHT/2 + CYLINDER_HEIGHT), position.y);
     fill(0,0,255);
     dummyCylinder.display();
  }
}

PVector positionOnPlate() {
     float xCursorOnPlate = mouseX - WIDTH/2;
     float yCursorOnPlate = mouseY - HEIGHT/2; //<>//
      //<>//
     if(xCursorOnPlate < -PLATE_WIDTH/2 + CYLINDER_RADIUS) {
       xCursorOnPlate = -PLATE_WIDTH/2 + CYLINDER_RADIUS;
     }
     else if(xCursorOnPlate > PLATE_WIDTH/2 - CYLINDER_RADIUS) {
       xCursorOnPlate = PLATE_WIDTH/2 - CYLINDER_RADIUS;
     }
     
     if(yCursorOnPlate < -PLATE_DEPTH/2 + CYLINDER_RADIUS) {
       yCursorOnPlate = -PLATE_DEPTH/2 + CYLINDER_RADIUS;
     }
     else if(yCursorOnPlate > PLATE_DEPTH/2 - CYLINDER_RADIUS) {
       yCursorOnPlate = PLATE_DEPTH/2 - CYLINDER_RADIUS;
     }
     
     return new PVector(xCursorOnPlate, yCursorOnPlate);
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == LEFT) {
      angleY -= PI/32 + movementScale;
    } else if (keyCode == RIGHT) {
      angleY += PI/32 - movementScale;
    } else if (keyCode == SHIFT){
      mode = Mode.OBSTACLE;
      oldAngleX = angleX;
      oldAngleY = angleY;
      oldAngleZ = angleZ;
      angleX = PI/2;
      angleZ = 0;
    }
  }
}

void keyReleased() {
  if (key == CODED) {
    if (keyCode == SHIFT) {
      if (mode == Mode.OBSTACLE) {
        mode = Mode.JEU;
        angleX = oldAngleX;
        angleY = oldAngleY;
        angleZ = oldAngleZ;
      }
    }
  }
}

void mouseClicked() {
  if (mode == Mode.OBSTACLE) {
    PVector position = positionOnPlate();
    
    cylinders.add(new Cylinder(new PVector(position.x, -(PLATE_HEIGHT/2 + CYLINDER_HEIGHT), position.y)));
    ++nbCylinder;
  }
}

void mouseDragged() {
  if(mode == Mode.JEU) {
    float angleIncrementX = rotationSpeed * (mouseY - pmouseY);
    float angleIncrementZ = rotationSpeed * (mouseX - pmouseX);
    
    if(abs(angleX + angleIncrementX) < MAX_ROTATION) {
       angleX += angleIncrementX;
    }
    
    if(abs(angleZ + angleIncrementZ) < MAX_ROTATION) {
      angleZ += angleIncrementZ;
    }
  }
}

void mouseWheel(MouseEvent event) {
  float newRotSpeed = rotationSpeed + ROTATION_INCREMENT * event.getCount();
  
  if(newRotSpeed > MIN_ROTATION_SPEED && newRotSpeed < MAX_ROTATION_SPEED) {
    rotationSpeed = newRotSpeed;
  }
} //<>//