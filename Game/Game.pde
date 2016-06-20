final int WIDTH = 1200; //<>// //<>//
final int HEIGHT = 800;

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
final float MIN_ROTATION = -PI/3;
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
Plane plane;

final float BALL_RADIUS = 10;

final float CYLINDER_RADIUS = 20;
final float CYLINDER_HEIGHT = 50;
final float RECT_MARGIN = 50;

final int DATA_HEIGHT = 150;
final int DATA_WIDTH = width;
//
final int TOP_VIEW_MARGIN = 5; // POUR LA MARGE DANS LA BARRE D'INFO
final int TOP_VIEW_HEIGHT = DATA_HEIGHT - 2 * TOP_VIEW_MARGIN;
final int TOP_VIEW_WIDTH = TOP_VIEW_HEIGHT;
final float TOP_VIEW_BALL_RADIUS = BALL_RADIUS / PLATE_WIDTH * TOP_VIEW_WIDTH;
final float TOP_VIEW_HOLE_RADIUS = CYLINDER_RADIUS / PLATE_WIDTH * TOP_VIEW_WIDTH;
//
final int SCORE_MARGIN = 3;
final int SCORE_HEIGHT = DATA_HEIGHT - 2 * SCORE_MARGIN;
final int SCORE_WIDTH = 100;

final int VIDEO_WIDTH = 320;
final int VIDEO_HEIGHT = 240;


//CST pour la transcription de l'image jusqu'au jeu.
PGraphics video;

TwoDThreeD converter;
PVector curr = new PVector(0, 0, 0);
PVector old1 = new PVector(0, 0, 0);
PVector old2 = new PVector(0, 0, 0);
PVector avg = new PVector(0, 0, 0);


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
  video = createGraphics(VIDEO_WIDTH, VIDEO_HEIGHT, P2D);

  nbCylinder = 0;
  cylinders = new ArrayList<Cylinder>();
  dummyCylinder = new Cylinder(new PVector(0, 0, 0));
  mover = new Mover();
  plane = new Plane();

  movie = new Movie(this, "testvideo.mp4");
  movie.loop();
  settings = settingsBoard1;
}

void draw() {
  /*
    Drawing 3D context
   */

  if (movie.available()) {
    movie.read();
  }
  img = movie.get();
  img.loadPixels();

  converter = new TwoDThreeD(img.width, img.height);

  imgResized = new PImage(img.width, img.height, RGB);

  PImage hueFiltered = selHSB(img, settings[0], settings[1], settings[2], settings[3], settings[4], settings[5]);
  PImage smoothedImage = gaussianBlur(hueFiltered, 30);
  PImage intensityFiltered = intensityThreshold(smoothedImage, settings[6]);
  PImage sobelImage = sobel(intensityFiltered, 0.1);

  // Get lines, houghImg, intersections and then quads
  ArrayList<PVector> lines = new ArrayList();
  PImage houghImg = hough(sobelImage, lines, 4);
  ArrayList<PVector> intersections = getIntersections(lines);



  background(200);
  ambientLight(102, 102, 102);
  fill(255);

  if (mode == Mode.JEU) {
    perspective();
    pushMatrix(); // POUR LA BARRE D'INFORMATIONS
    camera(0, -CAMERA_HEIGHT, CAMERA_DEPTH, 0, 0, 0, 0, 1, 0);
    directionalLight(50, 100, 125, 0, 1, 0);
    directionalLight(50, 100, 125, 0, -1, 0);

    translate(0, -100, 0);

    if (!intersections.isEmpty() && intersections.size() == 4) {
      old2 = old1;
      old1 = curr;
      curr = converter.get3DRotations(intersections);
    }


    if (old2.x != 0 && old2.y != 0 && old2.z != 0) {
      avg = old2.add(old1.add(curr)).div(3.0);
      angleX = constrain(avg.x, MIN_ROTATION, MAX_ROTATION);
      angleY = constrain(avg.z, MIN_ROTATION, MAX_ROTATION);
      angleZ = constrain(avg.y, MIN_ROTATION, MAX_ROTATION);
    }

    //ici il faut que nos angle soit puisse pas aller au dela de certaine valeur.
    rotateX(-angleX);
    rotateY(angleY);
    rotateZ(angleZ);

    plane.display();

    noStroke();
    fill(0, 0, 255);
    for (int i = 0; i < nbCylinder; ++i) {
      cylinders.get(i).display();
    }

    mover.update();

    fill(0, 255, 0);
    mover.display();

    popMatrix();

    for (int i = 0; i < img.pixels.length; i++) {
      imgResized.pixels[i] = img.pixels[i];
    }

    imgResized.resize(VIDEO_WIDTH, VIDEO_HEIGHT);
    imgResized.updatePixels();

    fill(255);
    video.beginDraw();
    video.image(imgResized, 0, 0);
    plotLines(video, lines, VIDEO_WIDTH, VIDEO_HEIGHT, 2);
    plotIntersections(video, intersections, 2);
    video.endDraw();

    image(video, 0, 0);
  } else if (mode == Mode.OBSTACLE) {
    /* In ortho mode, all objects of same size appear the same 
     * size regardless of how far they are from the camera
     */
    pushMatrix();
    ortho();
    camera(0, 0, CAMERA_DEPTH_OBSTACLE, 0, 0, 0, 0, 1, 0);
    directionalLight(50, 100, 125, 0, 0, -1);

    rotateX(-angleX);
    rotateY(angleY);
    rotateZ(angleZ);

    stroke(50, 50, 50);
    box(PLATE_WIDTH, PLATE_HEIGHT, PLATE_DEPTH); // Draw plate 
    noStroke();
    fill(0, 255, 0);
    mover.display();

    fill(0, 0, 255);
    for (int i = 0; i < nbCylinder; ++i) {
      cylinders.get(i).display();
    }

    PVector position = plane.positionOnPlate();
    // The plate is oriented in the x-y plane.
    translate(position.x, -(PLATE_HEIGHT/2 + CYLINDER_HEIGHT), position.y);
    fill(0, 0, 255);
    dummyCylinder.display();
    popMatrix();
  }

  // display everything

  QuadGraph quadgraph = new QuadGraph();
  quadgraph.build(lines, 400, 300);
  quadgraph.findCycles(100, 400);

  for (int[] quad : quadgraph.cycles) {
    PVector l1 = lines.get(quad[0]);
    PVector l2 = lines.get(quad[1]);
    PVector l3 = lines.get(quad[2]); //<>//
    PVector l4 = lines.get(quad[3]);

    // (intersection() is a simplified version of the
    // intersections() method you wrote last week, that simply
    // return the coordinates of the intersection between 2 lines)
    PVector c12 = getIntersection(l1, l2);
    PVector c23 = getIntersection(l2, l3);
    PVector c34 = getIntersection(l3, l4);
    PVector c41 = getIntersection(l4, l1);
    // Choose a random, semi-transparent colour
    Random random = new Random();
    fill(color(min(255, random.nextInt(300)), 
      min(255, random.nextInt(300)), 
      min(255, random.nextInt(300)), 50));
    quad(c12.x, c12.y, c23.x, c23.y, c34.x, c34.y, c41.x, c41.y);
  }
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == LEFT) {
      angleY -= PI/32 + movementScale;
    } else if (keyCode == RIGHT) {
      angleY += PI/32 - movementScale;
    } else if (keyCode == SHIFT) {
      mode = Mode.OBSTACLE;
      movie.pause();
      oldAngleX = angleX;
      oldAngleY = angleY;
      oldAngleZ = angleZ;
      angleX = PI/2;
      angleZ = 0;
      angleY = 0;
    }
  }
}

void keyReleased() {
  if (key == CODED) {
    if (keyCode == SHIFT) {
      if (mode == Mode.OBSTACLE) {
        mode = Mode.JEU;
        movie.play();
        angleX = oldAngleX;
        angleY = oldAngleY;
        angleZ = oldAngleZ;
      }
    }
  }
}

void mouseClicked() {
  if (mode == Mode.OBSTACLE) {
    PVector position = plane.positionOnPlate();
    cylinders.add(new Cylinder(new PVector(position.x, -(PLATE_HEIGHT/2 + CYLINDER_HEIGHT), position.y)));
    ++nbCylinder;
  }
}

void mouseDragged() {
  if (mode == Mode.JEU) {
    float angleIncrementX = rotationSpeed * (mouseY - pmouseY); //<>//
    float angleIncrementZ = rotationSpeed * (mouseX - pmouseX);

    if (abs(angleX + angleIncrementX) < MAX_ROTATION) {
      angleX += angleIncrementX;
    }

    if (abs(angleZ + angleIncrementZ) < MAX_ROTATION) {
      angleZ += angleIncrementZ;
    }
  }
}

void mouseWheel(MouseEvent event) {
  float newRotSpeed = rotationSpeed + ROTATION_INCREMENT * event.getCount();

  if (newRotSpeed > MIN_ROTATION_SPEED && newRotSpeed < MAX_ROTATION_SPEED) {
    rotationSpeed = newRotSpeed;
  }
}