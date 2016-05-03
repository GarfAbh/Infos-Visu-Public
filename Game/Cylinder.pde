class Cylinder {
  float cylinderBaseSize;
  float cylinderHeight;
  int cylinderResolution;
  PShape openCylinder;
  PShape closeCylinder;
  float[] x;
  float[] z;
  PVector position;
  
  Cylinder(PVector position) {
    this.position = position;
    cylinderBaseSize = CYLINDER_RADIUS;
    cylinderHeight = CYLINDER_HEIGHT;
    cylinderResolution = 40;
    openCylinder = new PShape();
    closeCylinder = new PShape();
    x = new float[cylinderResolution + 1];
    z = new float[cylinderResolution + 1];
    float angle;
    for(int i = 0; i < x.length; i++) {
      angle = (TWO_PI / cylinderResolution) * i;
      x[i] = sin(angle) * cylinderBaseSize;
      z[i] = cos(angle) * cylinderBaseSize;
    }
    openCylinder = createShape();
    openCylinder.beginShape(QUAD_STRIP);
      //draw the border of the cylinder
      for(int i = 0; i < x.length; i++) {
        openCylinder.vertex(x[i], 0, z[i]);
        openCylinder.vertex(x[i], cylinderHeight, z[i]);
      }
    openCylinder.endShape();
    
    closeCylinder = createShape();
    closeCylinder.beginShape(TRIANGLES);
      for (int i = 0; i < x.length; ++i) {
        closeCylinder.vertex(0, 0, 0);
        closeCylinder.vertex(x[i], 0, z[i]);
        closeCylinder.vertex(x[(i+1)%x.length], 0, z[(i+1)%x.length]);
        closeCylinder.vertex(0, cylinderHeight, 0);
        closeCylinder.vertex(x[i], cylinderHeight, z[i]);
        closeCylinder.vertex(x[(i+1)%x.length], cylinderHeight, z[(i+1)%x.length]);
      }
    closeCylinder.endShape();
  }
  
  void display() {
    pushMatrix();
    translate(this.position.x, this.position.y, this.position.z);
    shape(openCylinder);
    shape(closeCylinder);
    popMatrix();
  }
}
