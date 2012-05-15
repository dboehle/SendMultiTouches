class Finger
{
  public int id;
  public PVector pos;
  public PVector vel;
  public float angle;
  public float majorAxis;
  public float minorAxis;
  public int milliLastTouched;
  
  public static final float fingerScale = 0.007;
  
  public Finger(int id, int time)
  {
    this.id = id;
    this.milliLastTouched = time;
    
    this.pos = new PVector(0.5, 0.5);
    this.vel = new PVector(0.5, 0.5);
    this.angle = 0.0;
    this.majorAxis = 0.0;
    this.minorAxis = 0.0;
  }
  
  public void update(float posX, float posY, float velX, float velY,
    float angle, float majorAxis, float minorAxis, int time)
  {
    this.pos.x = posX;
    this.pos.y = posY;
    this.vel.x = velX;
    this.vel.y = velY;
    this.angle = angle;
    this.majorAxis = majorAxis;
    this.minorAxis = minorAxis;
    this.milliLastTouched = time;
  }
  
  public void render(float width, float height)
  {
    float absX = pos.x * width;
    float absY = height - (pos.y * height);
    
    pushMatrix();
    
    translate(absX, absY);
    
    pushMatrix();
    rotate(radians(-angle));
    
    // draw the fingerprint
    noStroke();
    fill(255, 0, 0);
    ellipse(0.0, 0.0, majorAxis * fingerScale * width, minorAxis * fingerScale * width);
    
    // draw an arrow for its direction
    stroke(0.0);
    fill(0);
    float arrowDist = majorAxis * fingerScale * width * 0.4;
    line(0.0, 0.0, arrowDist, 0.0);
    line(arrowDist, 0.0, 0.75 * arrowDist, 0.25 * arrowDist);
    line(arrowDist, 0.0, 0.75 * arrowDist, -0.25 * arrowDist);
    
    popMatrix();
    
    fill(255);
    text(id, 0.0, 0.0);
    
    popMatrix();
  }
}
