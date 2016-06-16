import java.util.Collections;
import java.util.Random;
import processing.video.*;

Capture cam;
Movie movie;
PImage img;
PImage imgResized;

int[] settings;
int[] settingsBoard1 = {109, 137, 81, 255, 0, 255, 126};
int[] settingsBoard2 = {105, 139, 116, 255, 0, 153, 89};
int[] settingsBoard3 = {94, 127, 117, 255, 0, 255, 75};
int[] settingsBoard4 = {95, 133, 63, 255, 0, 255, 96};

void settings() {
  size(1200, 300);
}

void setup() {
  /* INSTRUCTIONS : PLEASE READ CAREFULLY !
   * In order to select the right thresholding parameters,
   * just change the filename of the image to display.
   * If eventually it doesn't work, just apply the correct
   * settings in the following way :
   * 
   * settings = settingsBoardX;
   * 
   * Where the image loaded is ../boardX.jpg (replace X by
   * the corresponding number)
   * 
   * COMMENTS :
   * For some reason, despite having perfect clean edge recognition for images 1,3,4,
   * image 2's edges can't be found. By varying the discretizationStepsPhi variable,
   * we can manage to get some partial results with this image.
   *
   * The computed edges seen on the input images have a little offset to the upper left direction
   * This is probably due to image resizing.
   * 
  */
  
  /*
  ici pour la cameras
  */
  /*String[] cameras = Capture.list();
  if(cameras.length == 0){
    println("there are no cameras available for capture.");
    exit();
  }else{
    println("available cameras :");
    for(int i = 0 ; i < cameras.length; i++){
      println(cameras[i]);
    }
    cam = new Capture(this,cameras[3]);
    cam.start();
  }*/
  
  /*
  ici pour les images.
  */
  
  String imageFileName = "../board2.jpg";
  img = loadImage(imageFileName);
  //imgResized = new PImage(img.width, img.height, RGB);

  switch(imageFileName) {
  case "../board1.jpg":
    settings = settingsBoard1;
    break;

  case "../board2.jpg":
    settings = settingsBoard2;
    break;

  case "../board3.jpg":
    settings = settingsBoard3;
    break;

  case "../board4.jpg":
    settings = settingsBoard4;
    break;

  default:
    settings = settingsBoard1;
    break;
  }
  
  /*movie = new Movie(this, "testvideo.ogg");
  movie.loop();
  settings = settingsBoard1;*/
  
  //while(!movie.available());
  noLoop();
}

void draw() {
  background(color(0, 0, 0));
  
    /*
  ici pour la camera
  */
    
  /*if(cam.available()){
    cam.read();
  }
  img = cam.get();*/
  /*if(movie.available()) {
    System.out.println("Available image");
    movie.read();
  }
  img = movie.get();
  img.loadPixels();
  
  image(img,0,0);
  imgResized = new PImage(img.width, img.height, RGB);
  
  if(img.pixels.length == 0) {
    System.out.println("No image");
  }*/
  
  
  PImage hueFiltered = selHSB(img, settings[0], settings[1], settings[2], settings[3], settings[4], settings[5]);
  PImage smoothedImage = gaussianBlur(hueFiltered, 30);
  PImage intensityFiltered = intensityThreshold(smoothedImage, settings[6]);
  PImage sobelImage = sobel(intensityFiltered, 0.1);

  sobelImage.resize(400, 300);
  sobelImage.updatePixels();
  
  // Get lines, houghImg, intersections and then quads
  ArrayList<PVector> lines = new ArrayList();
  PImage houghImg = hough(sobelImage, lines, 4);
  ArrayList<PVector> intersections = getIntersections(lines);
  
  imgResized = new PImage(img.width, img.height, RGB);
  
  // display everything
  for(int i = 0; i < img.pixels.length; i++) {
    imgResized.pixels[i] = img.pixels[i];
  }
  
  imgResized.resize(400, 300);
  imgResized.updatePixels();
  
  image(imgResized, 0, 0);
  plotLines(lines, 400, 300);
  
  QuadGraph quadgraph = new QuadGraph();
  quadgraph.build(lines, 400, 300);
  quadgraph.findCycles(100, 400);
  
  for (int[] quad : quadgraph.cycles) {
      PVector l1 = lines.get(quad[0]);
      PVector l2 = lines.get(quad[1]);
      PVector l3 = lines.get(quad[2]);
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
      quad(c12.x,c12.y,c23.x,c23.y,c34.x,c34.y,c41.x,c41.y);
  }
    
  plotIntersections(intersections);
  image(houghImg, imgResized.width, 0);
  image(sobelImage, 2*imgResized.width, 0);
  

}

PImage intensityThreshold(PImage img, float threshold) {
  PImage result = new PImage(img.width, img.height, RGB);
  for (int i = 0; i < img.pixels.length; i++) {
    if (brightness(img.pixels[i]) < threshold) {
      result.pixels[i] = color(0);
    } else {
      result.pixels[i] = color(255);
    }
  }

  return result;
}

PImage selHSB(PImage img, float minHue, float maxHue, float minSat, float maxSat, float minBr, float maxBr) {
  PImage result = new PImage(img.width, img.height, RGB);

  for (int i = 0; i < img.pixels.length; i++) {
    int pixel = img.pixels[i];
    float pixelHue = hue(pixel);
    float pixelSat = saturation(pixel);
    float pixelBr = brightness(pixel);

    if (pixelHue >= minHue && pixelHue <= maxHue &&
      pixelSat >= minSat && pixelSat <= maxSat &&
      pixelBr >= minBr && pixelBr <= maxBr) {
      result.pixels[i] = img.pixels[i];
    } else {
      result.pixels[i] = color(0);
    }
  }

  return result;
}

PImage gaussianBlur(PImage src, float weight) {
  float gaussianKernel[][] = {{9, 12, 9}, 
    {12, 15, 12}, 
    {9, 12, 9}};

  return convolute(src, gaussianKernel, weight);
}

PImage sobel(PImage img, float max) {
  float[][] hKernel = { { 0, 1, 0  }, 
    { 0, 0, 0 }, 
    { 0, -1, 0 } };
  float[][] vKernel = { { 0, 0, 0  }, 
    { 1, 0, -1 }, 
    { 0, 0, 0  } };

  PImage result = createImage(img.width, img.height, ALPHA);

  for (int y = 2; y < img.height - 2; y++) {
    // Skip top and bottom edges
    for (int x = 2; x < img.width - 2; x++) {
      float horConv = 0;
      float vertConv = 0;

      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          horConv += brightness(img.pixels[(y+j-1) * img.width + x+i-1]) * hKernel[i][j];
          vertConv += brightness(img.pixels[(y+j-1) * img.width + x+i-1]) * vKernel[i][j];
        }
      }


      // Skip left and right
      if (sqrt(horConv*horConv + vertConv*vertConv) > (int)(max * 255 * 0.3f)) {
        // 30% of the max
        result.pixels[y * img.width + x] = color(255);
      } else {
        result.pixels[y * img.width + x] = color(0);
      }
    }
  }
  return result;
}

private PImage convolute(PImage src, float[][] kernel, float weight) {
  // create a greyscale image (type: ALPHA) for output
  PImage result = createImage(src.width, src.height, ALPHA);

  for (int y =0; y<src.height; y++) {
    for (int x=0; x<src.width; x++) {
      float conv = 0;

      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          if (!(x+i-1 < 0 || x+i-1 > src.width-1 || y+j-1 < 0 || y+j-1 > src.height-1)) {
            conv += brightness(src.pixels[(y+j-1) * src.width + x+i-1]) * kernel[i][j];
          }
        }
      }

      result.pixels[y * src.width + x] = color(conv/weight);
    }
  }

  return result;
}

PImage hough(PImage edgeImg, ArrayList<PVector> lines, int nLines) {
  float discretizationStepsPhi = 0.01f;
  float discretizationStepsR = 2.5f;
  
  // dimensions of the accumulator
  int phiDim = (int) (Math.PI / discretizationStepsPhi);
  int rDim = (int) (((edgeImg.width + edgeImg.height) * 2 + 1) / discretizationStepsR);
  
  // our accumulator (with a 1 pix margin around)
  int[] accumulator = new int[(phiDim + 2) * (rDim + 2)];
  
  // Fill the accumulator: on edge points (ie, white pixels of the edge 
  // image), store all possible (r, phi) pairs describing lines going 
  // through the point.
  for (int y = 0; y < edgeImg.height; y++) {
    for (int x = 0; x < edgeImg.width; x++) {
      // Are we on an edge?
      if (brightness(edgeImg.pixels[y * edgeImg.width + x]) != 0) {
        for (int phi = 0; phi < phiDim; phi++) {
          double phiG = phi*discretizationStepsPhi;
          double r = x*Math.cos(phiG) + y*Math.sin(phiG);
          int rx = (int)((r/discretizationStepsR)+(rDim -1)/2);
          accumulator[(phi+1)*(rDim+2)+rx] += 1;
        }
      }
    }
  }

  PImage houghImg = createImage(rDim + 2, phiDim + 2, ALPHA);
  for (int i = 0; i < accumulator.length; i++) {
    houghImg.pixels[i] = color(min(255, accumulator[i]));
  }
  
  // You may want to resize the accumulator to make it easier to see:
  houghImg.resize(400, 300);
  houghImg.updatePixels();

  ArrayList<Integer> bestCandidates = new ArrayList<Integer>();

  // size of the region we search for a local maximum
  int neighbourhood = 10;
  // only search around lines with more that this amount of votes // (to be adapted to your image)
  int minVotes = 200;
  for (int accR = 0; accR < rDim; accR++) {
    for (int accPhi = 0; accPhi < phiDim; accPhi++) {
      // compute current index in the accumulator
      int idx = (accPhi + 1) * (rDim + 2) + accR + 1;
      if (accumulator[idx] > minVotes) {
        boolean bestCandidate=true;
        // iterate over the neighbourhood
        for (int dPhi=-neighbourhood/2; dPhi < neighbourhood/2+1; dPhi++) { // check we are not outside the image
          if ( accPhi+dPhi < 0 || accPhi+dPhi >= phiDim) continue;
          for (int dR=-neighbourhood/2; dR < neighbourhood/2 +1; dR++) {
            // check we are not outside the image
            if (accR+dR < 0 || accR+dR >= rDim) continue;
            int neighbourIdx = (accPhi + dPhi + 1) * (rDim + 2) + accR + dR + 1;
            if (accumulator[idx] < accumulator[neighbourIdx]) { // the current idx is not a local maximum! 
              bestCandidate=false;
              break;
            }
          }
          if (!bestCandidate) break;
        }
        if (bestCandidate) {
          // the current idx *is* a local maximum 
          bestCandidates.add(idx);
        }
      }
    }
  }
  
  class HoughComparator implements java.util.Comparator<Integer> {
    int[] accumulator;
    public HoughComparator(int[] accumulator) {
      this.accumulator = accumulator;
    }
    @Override
      public int compare(Integer l1, Integer l2) {
      if (accumulator[l1] > accumulator[l2]
        || (accumulator[l1] == accumulator[l2] && l1 < l2)) return -1;
      return 1;
    }
  }
  
  Collections.sort(bestCandidates, new HoughComparator(accumulator)); 
  // bestCandidates is now sorted by most voted lines.
    
  for (int i = 0; i < Math.min(nLines, bestCandidates.size()) ; i++) {
    int index = bestCandidates.get(i);
    int accPhi = (int)(index/(rDim + 2)) - 1;
    int accRayon = index - (accPhi + 1) * (rDim + 2) - 1;
    float rayon = (accRayon - (rDim - 1) * 0.5f) * discretizationStepsR;
    float phi = accPhi * discretizationStepsPhi;
    
    lines.add(new PVector(rayon, phi));
  }
    
  return houghImg;
}

ArrayList<PVector> getIntersections(ArrayList<PVector> lines) {
  ArrayList<PVector> intersections = new ArrayList<PVector>();
  
  for(int i = 0; i < lines.size() - 1; i++) {
    PVector line1 = lines.get(i);
    
    for(int j = i + 1; j < lines.size(); j++) {
      PVector line2 = lines.get(j);
      
      double d = Math.cos(line2.y)*Math.sin(line1.y) - Math.cos(line1.y)*Math.sin(line2.y);
      double x = (line2.x*Math.sin(line1.y) - line1.x*Math.sin(line2.y))/d;
      double y = (-line2.x*Math.cos(line1.y) + line1.x*Math.cos(line2.y))/d;
      
      intersections.add(new PVector((float)x,(float)y));
    }
  }
  
  return intersections;
}

public PVector getIntersection(PVector line1, PVector line2) { 

      double d = Math.cos(line2.y)*Math.sin(line1.y) - Math.cos(line1.y)*Math.sin(line2.y);
      double x = (line2.x*Math.sin(line1.y) - line1.x*Math.sin(line2.y))/d;
      double y = (-line2.x*Math.cos(line1.y) + line1.x*Math.cos(line2.y))/d;

    ellipse((float)x, (float)y, 10, 10);
    fill(255, 128, 0);
    
    return new PVector((float)x, (float)y);
}

void plotLines(ArrayList<PVector> lines, int maxWidth, int maxHeight) {
  for(PVector line : lines) {
      float r = line.x;
      float phi = line.y;
      
      int x0 = 0; 
      int y0 = (int) (r / sin(phi)); 
      int x1 = (int) (r / cos(phi)); 
      int y1 = 0; 
      int x2 = maxWidth; 
      int y2 = (int) (-cos(phi) / sin(phi) * x2 + r / sin(phi)); 
      int y3 = maxWidth; 
      int x3 = (int) (-(y3 - r / sin(phi)) * (sin(phi) / cos(phi))); 
      // Finally, plot the lines
      stroke(204, 102, 0); 
      if (y0 > 0) {
        if (x1 > 0)
          line(x0, y0, x1, y1); 
        else if (y2 > 0)
          line(x0, y0, x2, y2); 
        else
          line(x0, y0, x3, y3);
      } else {
        if (x1 > 0) {
          if (y2 > 0)
            line(x1, y1, x2, y2); 
          else
            line(x1, y1, x3, y3);
        } else
          line(x2, y2, x3, y3);
      }
  }
}

void plotIntersections(ArrayList<PVector> intersections) {
  for(PVector intersection : intersections) {      
      fill(255,128,0);
      ellipse((float)intersection.x,(float)intersection.y,10,10);
  }
}