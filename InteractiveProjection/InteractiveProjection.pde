float scale = 1;
float angleX = PI/8;
float angleY = 0;

final int translation = 500;

void settings() {
  size(1000,1000,P2D);
}
void setup(){
}
void draw(){
  background(255,255,255);
  My3DPoint eye = new My3DPoint(0,0,-5000);
  My3DPoint origin = new My3DPoint(-75,-75,-75);
  My3DBox input3DBox = new My3DBox(origin,150,150,150);
  
  //scaled
  float[][] transform4 = scaleMatrix(scale, scale, scale);
  input3DBox = transformBox(input3DBox, transform4);
  //rotated around x
  float[][] transform1 = rotateXMatrix(angleX);
  input3DBox = transformBox(input3DBox, transform1);
  //rotated around y
  float[][] transform2 = rotateYMatrix(angleY);
  input3DBox = transformBox(input3DBox, transform2);
  //translated
  float[][] transform3 = translationMatrix(translation, translation, 0);
  input3DBox = transformBox(input3DBox, transform3);
  projectBox(eye, input3DBox).render();
}

void mouseDragged() {
  scale += (0.01)*(mouseY-pmouseY);
}

void keyPressed() {
  if(key == CODED) {
    if(keyCode == UP) {
      angleX -= PI/64;
    }
    else if(keyCode == DOWN) {
      angleX += PI/64;
    }
    else if(keyCode == LEFT) {
      angleY -= PI/64;
    }
    else if(keyCode == RIGHT) {
      angleY += PI/64;
    }
  }
}
//Part I Perspective Projection ===============================================================================
class My2DPoint{
float x;
float y;
My2DPoint(float x, float y){
  this.x = x;
  this.y = y;
  }
}

class My3DPoint{
  float x;
  float y;
  float z;
  My3DPoint(float x, float y , float z){
    this.x = x;
    this.y = y;
    this.z = z;
  }
}

class My2DBox{
  My2DPoint[] s;
  My2DBox(My2DPoint[] s){
  this.s = s;
  }
  void render(){

    strokeWeight(3);
    stroke(0,255,0);
    line(s[5].x,s[5].y,s[4].x,s[4].y);
    line(s[5].x,s[5].y,s[6].x,s[6].y);
    line(s[7].x,s[7].y,s[4].x,s[4].y);
    line(s[7].x,s[7].y,s[6].x,s[6].y);
    stroke(0,0,255);
    line(s[0].x,s[0].y,s[4].x,s[4].y);
    line(s[2].x,s[2].y,s[6].x,s[6].y);
    line(s[5].x,s[5].y,s[1].x,s[1].y);
    line(s[7].x,s[7].y,s[3].x,s[3].y);
    stroke(255,0,0);
    line(s[0].x,s[0].y,s[1].x,s[1].y);
    line(s[0].x,s[0].y,s[3].x,s[3].y);
    line(s[2].x,s[2].y,s[1].x,s[1].y);
    line(s[2].x,s[2].y,s[3].x,s[3].y);
    stroke(0);    
  }
}

class My3DBox {
        My3DPoint[] p;
        My3DBox(My3DPoint origin, float dimX, float dimY, float dimZ){
          float x = origin.x;
          float y = origin.y;
          float z = origin.z;
          this.p = new My3DPoint[]{new My3DPoint(x,y+dimY,z+dimZ),
                                   new My3DPoint(x,y,z+dimZ),
                                   new My3DPoint(x+dimX,y,z+dimZ),
                                   new My3DPoint(x+dimX,y+dimY,z+dimZ),
                                   new My3DPoint(x,y+dimY,z),
                                   origin,
                                   new My3DPoint(x+dimX,y,z),
                                   new My3DPoint(x+dimX,y+dimY,z)
                                  };
        }
        My3DBox(My3DPoint[] p){
          this.p=p;
        }
}

My2DPoint projectPoint(My3DPoint eye, My3DPoint p){  
  return new My2DPoint((p.x - eye.x)/(-p.z/eye.z + 1),(p.y - eye.y)/(-p.z/eye.z + 1));
}



My2DBox projectBox (My3DPoint eye, My3DBox box){
  My2DPoint[] point = new My2DPoint[box.p.length];
  for(int i = 0; i < box.p.length;i++){
    point[i] = projectPoint(eye,box.p[i]);
  }
  return new My2DBox(point);
}

//Part II transformation ================================================================================================================

float[] homogeneous3DPoint(My3DPoint p){
  float[] result = {p.x,p.y,p.z,1};
  return result;
}

float[][] rotateXMatrix(float angle) {
  return(new float[][]{{1,      0    ,     0    ,0},
                       {0, cos(angle),sin(angle),0},
                       {0,-sin(angle),cos(angle),0},
                       {0,      0    ,     0    ,1}
                      });
}

float[][] rotateYMatrix(float angle){
  return(new float[][]{{cos(angle) , 0 ,-sin(angle),0},
                       {     0     , 1 ,    0     ,0},
                       {sin(angle), 0 ,cos(angle),0},
                       {     0     , 0 ,    0     ,1}
                      });
}

float[][] rotateZMatrix(float angle){
  return(new float[][]{{cos(angle),-sin(angle),0,0},
                       {sin(angle),cos(angle) ,0,0},
                       {    0     ,     0     ,1,0},
                       {    0     ,     0     ,0,1}
                      });
}

float[][] scaleMatrix(float x, float y, float z){
  return(new float[][]{{x,0,0,0},
                       {0,y,0,0},
                       {0,0,z,0},
                       {0,0,0,1}
                      });
}

float[][] translationMatrix(float x, float y, float z){
  return(new float[][]{{1,0,0,x},
                       {0,1,0,y},
                       {0,0,1,z},
                       {0,0,0,1}
                      });
}

float[] matrixProduct(float[][] a, float[] b){
    float[] prod = new float[b.length];
    for(int i = 0 ; i < b.length; i++){
      prod[i] = 0;
    }
      for(int i = 0 ; i < a.length;i++){
        for(int j = 0 ; j < a[i].length;j++){
           prod[i] += a[i][j] * b[j];
        }
      }
  return prod;
}

My3DPoint euclidian3DPoint (float[] a) {
      My3DPoint result = new My3DPoint(a[0]/a[3], a[1]/a[3], a[2]/a[3]);
      return result;
}

My3DBox transformBox(My3DBox box, float[][] transformMatrix){
  My3DPoint[] point = new My3DPoint[box.p.length];
  for(int i = 0 ; i < box.p.length; i++){
    point[i] = euclidian3DPoint(matrixProduct(transformMatrix,homogeneous3DPoint(box.p[i])));
  }
  return new My3DBox(point);
}