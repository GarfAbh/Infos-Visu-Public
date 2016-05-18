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
  
  minBrightnessBar = new HScrollbar(0,560, 800, 10);
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

  PImage smoothedImage = gaussianBlur(img, 30);
  PImage hueFiltered = selHSB(smoothedImage, minHue, maxHue, minSat, maxSat, minBr, maxBr);
  PImage sobelImage = sobel(hueFiltered, 0.1);

  image(hueFiltered, 0, 0);
  image(sobelImage, img.width, 0);

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
      
      for(int i = 0; i < 3; i++) {
        for(int j = 0; j < 3; j++) {
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