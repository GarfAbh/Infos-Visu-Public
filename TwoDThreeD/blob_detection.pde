import java.awt.Polygon;
import java.util.ArrayList;
import java.util.List;
import java.util.SortedSet;
import java.util.TreeSet;

class BlobDetection {

  Polygon quad = new Polygon();
  /** Create a blob detection instance with the four corners of the Lego board.
  */
  BlobDetection(PVector c1, PVector c2, PVector c3, PVector c4) {
    quad.addPoint((int) c1.x, (int) c1.y);
    quad.addPoint((int) c2.x, (int) c2.y);
    quad.addPoint((int) c3.x, (int) c3.y);
    quad.addPoint((int) c4.x, (int) c4.y);
  }
  /** Returns true if a (x,y) point lies inside the quad
  */
  boolean isInQuad(int x, int y) {return quad.contains(x, y);}
  PImage findConnectedComponents(PImage input){
    
  // First pass: label the pixels and store labels’ equivalences
  
    int [] labels= new int [input.width*input.height];
    List<TreeSet<Integer>> labelsEquivalences = new ArrayList<TreeSet<Integer>>();
    int currentLabel=1;
    int huepi, huepi1,huepi2,huepi3,huepipred,index;
    
    input.loadPixels();
    
    for(int x = 0 ; x < input.width ; x++){
      for(int y = 0 ; y < input.height ; y++){
        //d'abord on se demande si les pixel de l'image que l'on traite sont bien sur la plaque.
        index = x+(y*input.width);
        labels[index] = 0;
        
        if(isInQuad(x,y)){
          
          huepi = hue(input.pixels[index]);
          huepi1 = hue(input.pixels[index-input.width-1]);
          huepi2 = hue(input.pixels[index-input.width]);
          huepi3 = hue(input.pixels[index-input.width+1]);
          huepipred = hue(input.pixels[index-1]);

          if(huepi == huepi1){
            labels[index] = labels[index-input.width-1];
          }
          if(huepi == huepi2){
            labels[index] = (labels[index] <= labels[index-input.width]) ? labels[index] : labels[index-input.width];
          }
          if(huepi == huepi3){
            labels[index] = (labels[index] <= labels[index-input.width+1]) ? labels[index] : labels[index-input.width+1];
          }
          if(huepi == huepipred){
            labels[index] = (labels[index] <= labels[index-1]) ? labels[index] : labels[index-1];
          }
          if(labels[index] == 0){
            labels[index] = ++currentLabel;
          }
        }
        
        
      }
    }
    
    // TODO!
    
    /*
    FAIRE ATTENTION ICI C'EST L'ETAPE 2 DONC ON FAIT ATTENTION AU VERIFICATION IL FAUT ENCORE CHANGER lE CODE
    EN ATTENTE DE SAVOIR SI ON GERE LES CAS HYPER PARTICULIER.
    */
    for(int x = 0 ; x < input.width ; x++){
      for(int y = 0 ; y < input.height ; y++){
        index = x+(y*input.width);
        labels[index] = 0;
        
        if(isInQuad(x,y)){
          
          huepi = hue(input.pixels[index]);
          huepi1 = hue(input.pixels[index-input.width-1]);
          huepi2 = hue(input.pixels[index-input.width]);
          huepi3 = hue(input.pixels[index-input.width+1]);
          huepipred = hue(input.pixels[index-1]);

          if(huepi == huepi1){
            labels[index] = labels[index-input.width-1];
          }
          if(huepi == huepi2){
            labels[index] = (labels[index] <= labels[index-input.width]) ? labels[index] : labels[index-input.width];
          }
          if(huepi == huepi3){
            labels[index] = (labels[index] <= labels[index-input.width+1]) ? labels[index] : labels[index-input.width+1];
          }
          if(huepi == huepipred){
            labels[index] = (labels[index] <= labels[index-1]) ? labels[index] : labels[index-1];
          }
          if(labels[index] == 0){
            labels[index] = ++currentLabel;
          }
        }
        
        
      }
    }
    // Second pass: re-label the pixels by their equivalent class
    // TODO!
    // Finally, output an image with each blob colored in one uniform color. 
    // TODO!
    }
}