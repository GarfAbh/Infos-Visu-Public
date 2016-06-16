class Data {
  PVector velocity;
  private float pointsPos;
  private float pointsNeg;

  public Data() {
    pointsPos = 0;
    pointsNeg = 0;
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
      ret = map(p, - PLATE_WIDTH/2, PLATE_WIDTH/2, TOP_VIEW_MARGIN, TOP_VIEW_WIDTH - TOP_VIEW_MARGIN);
    else
      ret = map(p, - PLATE_DEPTH/2, PLATE_DEPTH/2, TOP_VIEW_MARGIN, TOP_VIEW_WIDTH - TOP_VIEW_MARGIN);
    return ret;
  }
  

  public void display(float ballx, float ballz, float ballv, ArrayList<Cylinder> cylinders) {
    BACKGROUND_VISUALISATION.beginDraw();
    BACKGROUND_VISUALISATION.fill(204, 102, 0);
    BACKGROUND_VISUALISATION.background(204, 102, 0);
    BACKGROUND_VISUALISATION.endDraw();
    
    ////////// topView
    
    topView.beginDraw();
    topView.background(65, 105, 225);
    topView.fill(255, 165, 0);
    for (int i = 0; i < cylinders.size(); ++i) {
      topView.ellipse(realToPreview(cylinders.get(i).position.x, 1),
        realToPreview(cylinders.get(i).position.z, 0),
        TOP_VIEW_HOLE_RADIUS*2, TOP_VIEW_HOLE_RADIUS*2
      );
    }
    topView.fill(200, 200, 200);
    topView.ellipse(realToPreview(ballx, 1),
      realToPreview(ballz, 0),
      TOP_VIEW_BALL_RADIUS * 2, TOP_VIEW_BALL_RADIUS * 2
    );
    topView.endDraw();
    
    ///////// score
    
    String s1 = "Total Score:";
    String s2 = "Velocity";
    String s3 = "Last Score";
    score.fill(0);
    score.beginDraw();
    score.background(200);    
    score.text(s1, 10, 10, 70, 90);
    score.text(Float.toString(getPoins()), 10, 25, 70, 90);
    score.text(s2, 10, 45, 70, 90);
    score.text(Float.toString(ballv), 10, 60, 70, 90);
    score.text(s3, 10, 80, 70, 90);
    score.endDraw();
    
  }
}