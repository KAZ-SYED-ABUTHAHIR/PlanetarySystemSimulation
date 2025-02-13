//Have to be developed into a potential UI Component in Future.


public class SideBar extends Widget implements Focusable
{

  private final byte TO_LEFT  = -1;
  private final byte TO_RIGHT = +1;
  private final byte TO_REVERSE = -1;

  protected PApplet granny;

  protected float handleWidth; //Width of the handle to pull out the side bar
  protected float animSpeed ;  // Easing speed of the sliding action of the side bar

  protected color handleColor; // Color of the handle

  private boolean latched = true; // Property to keep track of latching condition of the sidebar
  private byte slide = TO_LEFT;   // To determine sliding direction on mouse click multiplied by -1. 
                                  // Hence start with -1 for sliding out
  private float drawWidth;

  SideBar(PApplet _granny) {
    super();
    this.granny = _granny;
    this.granny.registerMethod("draw", this);
    this.granny.registerMethod("mouseEvent", this);

    this.animSpeed = 0.02;
    this.barWidth = 2*width/3;
    this.barHeight = height/2;
    this.handleWidth = 15;
    this.leftPos = -this.barWidth + this.handleWidth;
    this.topPos = height*this.relTopPos;
    this.drawWidth = this.barWidth - this.handleWidth;
    this.barColor = color(10, 25, 10, 32);
    this.handleColor = color(255, 0, 255, 64);
    this.self = createGraphics((int)this.barWidth, (int)this.barHeight);
    this.init();
  }

  SideBar(PApplet _granny, float _topPos, float _barWidth, float _barHeight) {
    super(_topPos, _barWidth, _barHeight);

    this.granny = _granny;
    this.granny.registerMethod("draw", this);
    this.granny.registerMethod("mouseEvent", this);

    this.handleWidth = 15;
    this.leftPos = -this.barWidth + this.handleWidth;
    this.drawWidth = this.barWidth - this.handleWidth;

    this.barColor = color(20, 25, 50, 128);
    this.handleColor = color(255, 0, 255, 16);
    this.self = createGraphics((int)this.barWidth, (int)this.barHeight);
    this.animSpeed = 0.2;

    this.init();
  }

  void init() {
    pushStyle();
    self.smooth(4);
    self.beginDraw();
    self.background(this.barColor); 
    self.noStroke();
    self.fill(this.handleColor);
    //New hande Drawing...
    pushStyle();
    self.noFill();
    //self.strokeJoin(BEVEL);
    float beginX = this.barWidth-this.handleWidth/2-1;

    for (float i=-this.handleWidth/2; i<this.handleWidth/2; i++) {
      self.stroke(red(this.handleColor), green(this.handleColor), blue(this.handleColor)
        , abs(155-abs(map(i, -handleWidth/2, handleWidth/2, -155, 155))));
      this.self.line(beginX+i, 0, beginX+i, this.barHeight);
    }
    popStyle();
    //
    //self.rect(this.barWidth-this.handleWidth, 0, handleWidth, this.barHeight); //Deprecate
    if (this.img != null) {
      pushStyle();
      self.tint(255, 192);

      float imgAspectRatio = float(this.img.width) / float(this.img.height);
      float imgRenderHeight = min(this.barWidth,this.barHeight);
      float imgRenderWidth = imgRenderHeight*imgAspectRatio;

      self.image(this.img, 0, 0, imgRenderWidth ,  imgRenderHeight);
      popStyle();

    }
    self.endDraw();

    popStyle();
    if (this.children.size()>0) {

      for (Widget w : this.children) {
        w.init();
        self.image(w.self, w.leftPos, w.topPos);
      }
    } //is this needed or not SERIOUSLY? in render this is required but not here I hope...
    this.buffer = this.self.get();
  }

  void render() {
    pushMatrix();
     
    if (this.children.size()>0) {
      for (Widget w : this.children) {
        w.render();
      }
    }
    imageMode(CORNER);
    image(this.self, this.leftPos, this.topPos);
    float target = (this.slide<0)?(-this.barWidth+this.handleWidth):(0);
    float diff = abs(target-this.leftPos);
    if (!this.latched) {
      this.leftPos += this.slide*(diff*this.animSpeed);
    }

    float handlePosition = this.leftPos + this.barWidth-this.handleWidth;
    float handlePositionMin = 0;
    float handlePositionMax  = this.barWidth-this.handleWidth;

    if (handlePosition < handlePositionMin) {
      this.latched = true;
      this.leftPos = -this.barWidth+this.handleWidth;
    }

    if (handlePosition > handlePositionMax) {
      this.latched = true;
      this.leftPos = 0;
    }
    popMatrix();
  }

  void slideOut() {
    this.latched = false;
    this.slide = TO_RIGHT;
  }

  void slideIn() {
    this.latched = false;
    this.slide = TO_LEFT;
  }

  void drawHandle() {
    //NEW
    self.noStroke();
    self.fill(this.handleColor);
    self.rect(this.barWidth-this.handleWidth, 0, handleWidth, this.barHeight);
    this.init();
    //NEW
  }

  boolean inFocus() {
    return (
      mouseX > this.leftPos && 
      mouseX < (this.leftPos + this.barWidth ) && 
      mouseY > this.topPos && 
      mouseY < (this.topPos + this.barHeight)) ;
  }




  void addChild(Widget child) {
    this.children.add(child);
    child.setParent(this);
    child.init();
  }

  public void draw() {
    this.render();
  }

  public void mouseEvent(MouseEvent event) {
    //int x = event.getX();
    //int y = event.getY();

    switch (event.getAction()) {
    case MouseEvent.PRESS:
      this.mousePressedHandler();     
      // do something for the mouse being pressed
      break;
    case MouseEvent.RELEASE:
      this.mouseReleasedHandler();
      // do something for mouse released
      break;
    case MouseEvent.CLICK:
      this.mouseClickedHandler();
      // do something for mouse clicked
      break;
    case MouseEvent.DRAG:
      this.mouseDraggedHandler();
      // do something for mouse dragged
      break;
    case MouseEvent.MOVE:
      // do something for mouse moved
      break;
    }
  }

  void mouseDraggedHandler() {
  }

  void mousePressedHandler() {
    if (this.inFocus()) {
      try {
      } 
      catch(Exception e) {
        e.printStackTrace();
      }
      //?????
    }
  }

  void mouseReleasedHandler() {
    if (this.inFocus()) {
      try {
      } 
      catch(Exception e) {
        e.printStackTrace();
      }
      //?????
    }
  }

  void mouseClickedHandler() {
    float handlePosition = this.leftPos + this.barWidth-this.handleWidth;
    if (mouseX > handlePosition && mouseX < handlePosition+this.handleWidth && this.inFocus()) {
      this.latched = false;
      this.slide *= TO_REVERSE;
    }
    try
    {
      for (Widget w : this.children) {
        w.mouseClickedHandler();
      }
    }
    catch(Exception e) {
      println("No Children Yet!");
    }
  }

  //---------------------------------------------------------------------------------------------//
  //-----------------------------------GETTERS & SETTERS-----------------------------------------//

  //----------------------------------------GETTERS----------------------------------------------//

  PApplet getGranny() {
    return this.granny;
  }

  float getHandleWidth() {
    return this.handleWidth;
  }

  float getDrawWidth() {
    return this.drawWidth;
  }

  float getAnimSpeed() {
    return this.animSpeed;
  }

  color getHandleColor() {
    return this.handleColor;
  }

  boolean isLatched() {
    return this.latched;
  }

  //----------------------------------------SETTERS------------------------------------------------//



  void setHandleColor(color c) {
    this.handleColor = color(red(c), green(c), blue(c), 128);
    this.init();
  }

  void setHandleWidth(float _handleWidth) {
    this.handleWidth = _handleWidth;
  }

  void setImage(PImage _image) {
    this.img = _image;
    this.init();
  }
}//EOC
