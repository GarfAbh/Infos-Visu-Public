class Data {
  PVector velocity;
  private float pointsPos;
  private float pointsNeg;

  public Data() {
    
  }

  public void update() {
    
  }
  
  public void pointsGain(float add) {
    pointsPos += add;
  }
  
  public void pointsLose(float lose) {
    pointsNeg += lose;
  }
  
  public float getPoins() {
    return pointsPos - pointsNeg;
  }
  
  public float realToPreview(float p, int w) { // w = 0: on height;;; w = 1: on width
    float ret = 0;
    if (w == 1)
      ret = map(p, - PLATE_WIDTH/2, PLATE_WIDTH/2, 0, TOP_VIEW_WIDTH);
    else
      ret = map(p, - PLATE_DEPTH/2, PLATE_DEPTH/2, 0, TOP_VIEW_WIDTH);
    return ret;
  }
  

  public void display(float ballx, float ballz, ArrayList<Cylinder> cylinders) {
    BACKGROUND_VISUALISATION.beginDraw();
    BACKGROUND_VISUALISATION.background(200, 200, 200);
    BACKGROUND_VISUALISATION.endDraw();
    
    //////////
    
    topView.beginDraw();
    topView.background(0, 0, 255);
    topView.fill(200, 200, 200);
    for (int i = 0; i < cylinders.size(); ++i) {
      topView.ellipse(realToPreview(cylinders.get(i).position.x, 1),
        realToPreview(cylinders.get(i).position.z, 0),
        TOP_VIEW_HOLE_RADIUS, TOP_VIEW_HOLE_RADIUS
      );
    }
    topView.fill(200, 200, 200);
    topView.ellipse(realToPreview(ballx, 1),
      realToPreview(ballz, 0),
      TOP_VIEW_BALL_RADIUS, TOP_VIEW_BALL_RADIUS
    );
    topView.fill(0, 0, 0);
    topView.endDraw();
  }
}