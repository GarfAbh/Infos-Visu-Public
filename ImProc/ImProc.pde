PImage img;
HScrollbar minHueBar;
HScrollbar maxHueBar;
HScrollbar minBrightnessBar;
HScrollbar maxBrightnessBar;
HScrollbar minSaturationBar;
HScrollbar maxSaturationBar;

void settings() {
  size(1900, 600);
}

void setup() {
  img = loadImage("../board1.jpg");

  minHueBar = new HScrollbar(0, 500, 800, 10);
  maxHueBar = new HScrollbar(0, 515, 800, 10);

  minSaturationBar = new HScrollbar(0, 530, 800, 10);
  maxSaturationBar = new HScrollbar(0, 545, 800, 10);

  minBrightnessBar = new HScrollbar(0, 560, 800, 10);
  maxBrightnessBar = new HScrollbar(0, 575, 800, 10);
}

void draw() {
  background(color(0, 0, 0));

  float maxHue = maxHueBar.getPos()*255;
  float minHue = minHueBar.getPos()*255;
  float minSat = minSaturationBar.getPos()*255;
  float maxSat = maxSaturationBar.getPos()*255;
  float minBr = minBrightnessBar.getPos()*255;
  float maxBr = maxBrightnessBar.getPos()*255;

  PImage hueFiltered = selHSB(img, minHue, maxHue, minSat, maxSat, minBr, maxBr);
  PImage smoothedImage = gaussianBlur(hueFiltered, 30);
  PImage sobelImage = sobel(smoothedImage, 0.1);
  hough(sobelImage);
  
  
  img.resize(400,400);
  sobelImage.resize(400,400);
  //image(hueFiltered, 0, 0);
  image(img,0,0);
  image(sobelImage, 2*img.width, 0);

  minHueBar.display();
  minHueBar.update();

  maxHueBar.display();
  maxHueBar.update();

  minSaturationBar.display();
  minSaturationBar.update();

  maxSaturationBar.display();
  maxSaturationBar.update();

  minBrightnessBar.display();
  minBrightnessBar.update();

  maxBrightnessBar.display();
  maxBrightnessBar.update();
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

void hough(PImage edgeImg) {
  float discretizationStepsPhi = 0.06f;
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
          int rx = (int)(r/discretizationStepsR)+(rDim -1)/2;
          accumulator[phi+1*rDim+2+rx] += 1;
        }
        // ...determine here all the lines (r, phi) passing through
        // pixel (x,y), convert (r,phi) to coordinates in the
        // accumulator, and increment accordingly the accumulator.
        // Be careful: r may be negative, so you may want to center onto
        // the accumulator with something like: r += (rDim - 1) / 2
      }
    }
  }


  PImage houghImg = createImage(rDim + 2, phiDim + 2, ALPHA);
  for (int i = 0; i < accumulator.length; i++) {
    houghImg.pixels[i] = color(min(255, accumulator[i]));
  }
  // You may want to resize the accumulator to make it easier to see:
  houghImg.resize(400, 400);
  houghImg.updatePixels();
  image(houghImg,img.width,0);
}