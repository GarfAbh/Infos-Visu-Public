int width = 500;
int height = 500;
int depth = 1000;

float angleX = 0;
float angleY = 0;
float angleZ = 0;

float movementScale = 0;

Plane plane;


void settings() {
  size(width, height, P3D);
}
void setup() {
  plane = new Plane();
  stroke(102,102,102);
}
void draw() {
  camera(0, 0/*-height/2*/, depth,
    0, 0, 0,
    0, 1, 0);
  directionalLight(50,100,125,0,1,0);
  directionalLight(50,100,125,0,-1,0);
  
  ambientLight(102, 102, 102);  
  background(200);
  
  angleZ = map(mouseX, 0, width, -PI/3, PI/3);
  angleX = map(mouseY, height, 0, -PI/3, PI/3);

  rotateX(angleX);
  rotateY(angleY);
  rotateZ(angleZ);
  
  plane.display();
}

void keyPressed() {
  if(key == CODED) {
   if(keyCode == LEFT) {
     angleY -= PI/32 + movementScale;
   }
   else if(keyCode == RIGHT) {
     angleY += PI/32 - movementScale;
   }
 }
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  //movementScale += e;
}