import java.util.Collections;
PImage img;

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
   */

  String imageFileName = "../board4.jpg";
  img = loadImage(imageFileName);

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
}

void draw() {
  background(color(0, 0, 0));

  PImage hueFiltered = selHSB(img, settings[0], settings[1], settings[2], settings[3], settings[4], settings[5]);
  PImage smoothedImage = gaussianBlur(hueFiltered, 30);
  PImage intensityFiltered = intensityThreshold(smoothedImage, settings[6]);
  PImage sobelImage = sobel(intensityFiltered, 0.1);

  img.resize(400, 300);
  image(img, 0, 0);
  hough(sobelImage);
  sobelImage.resize(400, 300);
  image(sobelImage, 2*img.width, 0);
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
          int rx = (int)((r/discretizationStepsR)+(rDim -1)/2);
          accumulator[(phi+1)*(rDim+2)+rx] += 1;
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
  houghImg.resize(400, 300);
  houghImg.updatePixels();
  
  
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

  ArrayList<Integer> bestCandidates = new ArrayList<Integer>();
  // ...
  Collections.sort(bestCandidates, new HoughComparator(accumulator)); 
  // bestCandidates is now sorted by most voted lines.

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
            if (accumulator[idx] < accumulator[neighbourIdx]) { // the current idx is not a local maximum! bestCandidate=false;
              break;
            }
          }
          if (!bestCandidate) break;
        }
        if (bestCandidate) {
          // the current idx *is* a local maximum bestCandidates.add(idx);
        }
      }
    }
  }


  for (int idx = 0; idx < accumulator.length; idx++) {
    if (accumulator[idx] > 200) {
      // first, compute back the (r, phi) polar coordinates:
      int accPhi = (int) (idx / (rDim + 2)) - 1; 
      int accR = idx - (accPhi + 1) * (rDim + 2) - 1; 
      float r = (accR - (rDim - 1) * 0.5f) * discretizationStepsR; 
      float phi = accPhi * discretizationStepsPhi; 
      // Cartesian equation of a line: y = ax + b
      // in polar, y = (-cos(phi)/sin(phi))x + (r/sin(phi))
      // => y = 0 : x = r / cos(phi)
      // => x = 0 : y = r / sin(phi)
      // compute the intersection of this line with the 4 borders of // the image
      int x0 = 0; 
      int y0 = (int) (r / sin(phi)); 
      int x1 = (int) (r / cos(phi)); 
      int y1 = 0; 
      int x2 = edgeImg.width; 
      int y2 = (int) (-cos(phi) / sin(phi) * x2 + r / sin(phi)); 
      int y3 = edgeImg.width; 
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
  image(houghImg, img.width, 0);
}