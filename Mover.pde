class Mover { //<>// //<>// //<>//
  PVector velocity;
  final PVector position;
  final PVector gravityForce;

  final float G = 0.2;
  final float MU = 0.02;

  PVector n = new PVector(0, 0, 0); //for collision with cylinder (avoid multiple creation of a vector).

  public Mover() {
    gravityForce = new PVector(0, 0, 0);
    velocity = new PVector(0, 0, 0);
    position = new PVector(0, -(PLATE_HEIGHT/2 + BALL_RADIUS), 0);
  }

  public void update() {
    /*
    * Compute gravity force and board friction
     */

    gravityForce.x = sin(angleZ) * G;
    gravityForce.z = sin(angleX) * G;

    float normalForce = 1;
    float frictionMagnitude = normalForce * MU;
    PVector friction = velocity.get();
    friction.mult(-1);
    friction.normalize();
    friction.mult(frictionMagnitude);

    /*
      Compute velocity from gravity force, board friction and velocity itself
     */

    velocity.add(gravityForce);
    velocity.add(friction);
    position.add(velocity);
  }

  public void checkEdges() {
    if (position.x + velocity.x > PLATE_WIDTH/2) {
      position.x = PLATE_WIDTH/2 - velocity.x + (PLATE_WIDTH/2 - position.x);
      velocity.x = -velocity.x;
    } else if (position.x + velocity.x < -PLATE_WIDTH/2 ) {
      position.x = -(-PLATE_WIDTH/2 - velocity.x + (PLATE_WIDTH/2 - position.x)); 
      velocity.x = -velocity.x;
    }
    if (position.z + velocity.z > PLATE_DEPTH/2) {
      position.z = PLATE_DEPTH/2 - velocity.z + (PLATE_WIDTH/2 - position.z);
      velocity.z = -velocity.z;
    } else if (position.z + velocity.z < -PLATE_DEPTH/2 ) {
      position.z = -(-PLATE_DEPTH/2 - velocity.z + (PLATE_WIDTH/2 - position.z));
      velocity.z = -velocity.z;
    }
  }


  public void checkCylinderCollision(PVector pos, float r) {
    n = position.get().sub(pos);
    n.y = 0;
    double dist = Math.sqrt( n.dot(n));
    
    if (dist <= BALL_RADIUS + r) { // collision
      n.normalize();
      velocity = velocity.sub( n.mult(2 * velocity.dot(n)) );
    }
  }

  public void display() {
    pushMatrix();
    translate(position.x, position.y, position.z);
    sphere(BALL_RADIUS);
    popMatrix();
  }
}