public class Planet {
  private float preFrameRate;
  private float currentFrameRate;
  private float averageFrameRate;
  private float deltaTime = 1.0f;

  PVector position = new PVector();
  PVector oldPosition = new PVector();     // For Doing Verlet Integration.
  PVector velocity = new PVector();
  PVector acceleration = new PVector();
  PVector initialPosition = new PVector();

  Attractor myAttractor;
  ArrayList<PVector> orbitPoints = new ArrayList<PVector>();
  ArrayList<PolarPoint> orbitPolarPoints = new ArrayList<PolarPoint>();

  float orbitalPeriod=-1;
  float maxRadius = -1;
  float minRadius = 5000000;
  float minAngle = 0;
  float maxAngle = 0;
  int minIndex = 0;
  int maxIndex = 0;
  float orbitalEccentricity = 0;
  float semiMajorAxis = 0;
  float semiMinorAxis = 0;
  PVector apoapsis = new PVector(); //Farthest point from the attractor
  PVector periapsis = new PVector(); //Closest point to the attractor
  PVector orbitCenter = new PVector(); //Center point of the elliptical orbit
  PVector[]  foci;

  String  orbitDescriptor;

  final private float threshold = 0.5;
  final private int minOrbitPointCount = 100;
  final private int maxOrbitPointCount = 50000;

  float mass;
  float size = 60;
  String name;
  color planetColor ;

  Arrow velocityArrow = new Arrow(0, 0, 0, 0);
  Arrow accelerationArrow  = new Arrow(0, 0, 0, 0);
  final static float velocityArrowScale = 40;

  boolean highlighted = false;

  PImage img = null ;

  //Constructors

  Planet(PVector _position, PVector _velocity, float _mass) {
    this.position = _position.copy();
    this.initialPosition = this.position.copy();
    this.oldPosition = this.initialPosition.copy();//???? Will this work?
    this.velocity = _velocity.copy();
    this.velocityArrow = new Arrow(this.position, this.velocity.copy().mult(velocityArrowScale));
    this.mass = _mass;
    this.name = "Planet";
    this.orbitDescriptor = "";
    this.preFrameRate = frameRate;
    this.currentFrameRate = frameRate;
    pushStyle();
    colorMode(HSB);
    this.planetColor = color(random(255), 255, 255, 255);
    popStyle();
  }

  Planet(PVector _position, PVector _velocity, float _mass, PImage _img) {
    this( _position, _velocity, _mass);
    this.img = _img;
  }

  Planet(PVector _position, PVector _velocity, float _mass, Attractor _attractor) {
    this(_position, _velocity, _mass);
    this.myAttractor = _attractor;
    this.initVerlet();
    calcOrbit(_attractor);
  }

  Planet(PVector _position, PVector _velocity, float _mass, Attractor _attractor, PImage _img) {
    this(_position, _velocity, _mass, _attractor);
    this.img = _img;
  }

  Planet(PVector _position, float _mass) {
    this.position = _position.copy();
    this.initialPosition = this.position.copy();
    this.oldPosition = this.initialPosition.copy();
    this.velocity = PVector.random2D();
    this.velocityArrow = new Arrow(this.position, this.velocity.copy().mult(velocityArrowScale));
    this.mass = _mass;
    this.name = "Planet";
    pushStyle();
    colorMode(HSB);
    this.planetColor = color(random(255), 255, 255, 255);
    popStyle();
  }

  Planet(PVector _position, float _mass, PImage _img) {
    this( _position,  _mass);
    this.img = _img;
  }

  Planet() {
    this.position.x = random(width);
    this.position.y = random(height);
    this.initialPosition = this.position.copy();
    this.oldPosition = this.initialPosition.copy();
    this.velocity = PVector.random2D();
    this.velocity.setMag(random(0.5, 5.0));
    this.velocityArrow = new Arrow(this.position, this.velocity.copy().mult(velocityArrowScale));
    this.mass = random(0.05, 0.5);
    this.name = "Planet";
    pushStyle();
    colorMode(HSB);
    this.planetColor = color(random(255), 255, 255, 255);
    popStyle();
  }


  //Displayer
  void show() {
    if (this.img != null) {
      // Calculate the angle to the target
      float angle = atan2(this.myAttractor.position.y - this.position.y, this.myAttractor.position.x - this.position.x);

      // Apply transformations to rotate the image
      pushMatrix();
      translate(this.position.x, this.position.y);

      imageMode(CENTER);
      rotate(angle+1.6);
      image(this.img, 0, 0);
      //imageMode(CORNER);

      popMatrix();
    } else {
      pushStyle();
      fill(this.planetColor);
      noStroke();
      ellipse(this.position.x, this.position.y, this.size, this.size);
      if (this.highlighted) {
        pushStyle();
        float beginRed = red(this.planetColor);
        float beginGreen = green(this.planetColor);
        float beginBlue = blue(this.planetColor);
        float endRed = 255-red(this.planetColor);
        float endGreen = 255-green(this.planetColor);
        float endBlue = 255-blue(this.planetColor);
        color beginColor = color(beginRed, beginGreen, beginBlue);
        color endColor = color(endRed, endGreen, endBlue);
        noFill();
        strokeWeight(3);
        for (float i=0; i<=1; i+=0.05) {
          stroke(lerpColor(beginColor, endColor, i), map(i, 0, 1, 100, 255));
          ellipse(this.position.x, this.position.y, this.size+50*i, this.size+50*i);
        }
        popStyle();
      }
      popStyle();
    }
  }

  void initVerlet() {
    //What is wrong?
    //float deltaTime = 1.0f; //60/frameRate; Haa ! Verlet integration can't have variable deltaTime It is not simplectic?
    try {
      this.calcForce(this.myAttractor);
      PVector tempOldPosition = this.oldPosition.copy();
      this.position = tempOldPosition.add(this.velocity.mult(this.deltaTime)).add(this.acceleration.mult(0.5*deltaTime*this.deltaTime));
    }
    catch(Exception e) {
      e.printStackTrace();
    }
  }

  //Update : Do Physics...Verlet Integration to be implemented in future. NOW: 14.07.2018
  void update() {
    //NEW VERLET
    verletIntegrate(this.deltaTime);

    velocityArrow.setArrow(this.position, this.velocity.copy().mult(velocityArrowScale));
    accelerationArrow.setArrow(this.position, this.acceleration.copy().mult(velocityArrowScale*30));
    this.acceleration.setMag(0);
  }

  void linearIntegrate(float deltaTime) {
    this.velocity.add(PVector.mult(this.acceleration, deltaTime));
    this.position.add(PVector.mult(this.velocity, deltaTime));
  }

  void verletIntegrate(float deltaTime) {
    PVector tempPosition = this.position.copy();
    PVector tempAcceleration = this.acceleration.copy();

    this.position.mult(2).sub(this.oldPosition).add(tempAcceleration.mult(deltaTime*deltaTime));
    this.oldPosition = tempPosition.copy();
    this.velocity = PVector.sub(this.position, this.oldPosition).mult(1/deltaTime);
  }

  //CalcForce : Calculate Force using Newton's Law of Gravitation. The Great Inverse Square Law.
  void calcForce(Attractor attractor) {
    float dist = PVector.dist(this.position, attractor.position);
    PVector radialVector = PVector.sub(attractor.position, this.position).setMag(1);
    acceleration.set(radialVector).setMag(G*attractor.mass*this.mass/(dist*dist));
  }

  //Orbit calculations. Pretty messy now but works good...
  void calcOrbit(Attractor attractor) {
    PVector radial = PVector.sub(this.position, attractor.position);
    float initHeading = radial.heading()*180/PI+180.0f;
    float heading;
    float magnitude;
    int count = 0;
    
    do {
      PVector pos = this.position.copy();
      this.orbitPoints.add(pos);
      // this.calcForce(attractor);
      // this.update();

      radial = PVector.sub(this.position, attractor.position);
      magnitude = radial.mag();
      heading = radial.heading()*180/PI+180.0f;

      this.orbitPolarPoints.add(new PolarPoint(magnitude, heading));

      this.calcForce(attractor);
      this.update();


      if (magnitude>this.maxRadius) {
        this.maxRadius = magnitude;
        this.maxAngle = heading-180.0f;
        this.maxIndex = count;
      }
      if (magnitude<this.minRadius) {
        this.minRadius = magnitude;
        this.minAngle = heading-180.0f;
        this.minIndex = count;
      }
      count++;
    } while ((abs(heading-initHeading)>this.threshold || count < this.minOrbitPointCount) && !(count>this.maxOrbitPointCount));

    if (orbitPoints.size()<maxOrbitPointCount) {
      this.orbitalPeriod = (orbitPoints.size())*(1.0f/30.0f);
    }

    this.orbitalEccentricity = (this.maxRadius-this.minRadius)/(this.maxRadius+this.minRadius);
    this.apoapsis = orbitPoints.get(maxIndex);
    this.periapsis = orbitPoints.get(minIndex);
    this.orbitCenter = PVector.lerp(this.apoapsis, this.periapsis, 0.5);
    this.semiMajorAxis = PVector.sub(this.periapsis, this.apoapsis).mag()/2;
    this.semiMinorAxis = this.semiMajorAxis*sqrt(1-this.orbitalEccentricity*this.orbitalEccentricity);
    this.foci = calculateFoci();
    float kepler_aCubeByTSquare = pow(this.semiMajorAxis, 3)/pow(this.orbitalPeriod, 2);

    this.orbitDescriptor += "Orbital Parameters\n";
    this.orbitDescriptor += "Orbital Period          : "+String.format("%.02f", this.orbitalPeriod)+ " Sec\n";
    this.orbitDescriptor += "Eccentricity            : "+String.format("%.02f", this.orbitalEccentricity)+ "\n";
    this.orbitDescriptor += "Semi Major Axis         : "+String.format("%.02f", this.semiMajorAxis) + "\n";
    this.orbitDescriptor += "Semi Minor Axis         : "+String.format("%.02f", this.semiMinorAxis) + "\n";
    this.orbitDescriptor += "Kepler III Law Constant : "+String.format("%.02f", kepler_aCubeByTSquare) + "\n";
    this.orbitDescriptor += "Max Radius              : "+String.format("%.02f", this.maxRadius) + "\n";
    this.orbitDescriptor += "Min Radius              : "+String.format("%.02f", this.minRadius) + "\n";

    this.orbitDescriptor += "Max Angle               : "+String.format("%.02f", this.maxAngle) + "\u00B0" + "\n"; // "\u00B0" ---> Degree Symbol
    this.orbitDescriptor += "Min Angle               : "+String.format("%.02f", this.minAngle) + "\u00B0" + "\n";
    //this.orbitPoints.clear(); //If you need orbitPoints don't clear it !!!
  }
  
  private PVector[] calculateFoci() {
  PVector center = this.orbitCenter;
  
  float a = this.semiMajorAxis;
  float b = this.semiMinorAxis;
  
  //c is the distance from the center to the foci
  float c = sqrt(sq(a) - sq(b));
  
  // Find the unit direction vector along the major axis
  PVector u = PVector.sub(apoapsis, periapsis);
  u.normalize();
  
  // Calculate the foci
  PVector f1 = PVector.sub(center, PVector.mult(u, c));
  PVector f2 = PVector.add(center, PVector.mult(u, c));
  
  // Return the foci as an array of PVectors
  return new PVector[]{f1, f2};
}


  void showOrbit(boolean showPoints) {
    pushStyle();
    strokeWeight(2);
    stroke(this.planetColor);
    noFill();
    pushMatrix();
    translate(this.orbitCenter.x, this.orbitCenter.y);
    rotate(radians(this.minAngle));
    ellipse(0, 0, 2*this.semiMajorAxis, 2*this.semiMinorAxis);
    popMatrix();
    try {
      if (showPoints) {
        stroke(0, 0, 255, 255);
        strokeWeight(20);
        point(orbitPoints.get(minIndex).x, orbitPoints.get(minIndex).y);
        stroke(255, 100, 0, 255);
        point(orbitPoints.get(maxIndex).x, orbitPoints.get(maxIndex).y);
        stroke(255, 100, 255, 255);
        point(this.orbitCenter.x, this.orbitCenter.y);
        stroke(0, 255, 255, 255);
        point(this.foci[0].x, this.foci[0].y);
        point(this.foci[1].x, this.foci[1].y);
        popStyle();
      }
    }
    catch(Exception e) {
      e.printStackTrace();
    }
  }

  void showRadial(Attractor a) {
    pushStyle();
    stroke(this.planetColor);
    line(a.position.x, a.position.y, this.position.x, this.position.y);
    popStyle();
  }

  void showVelocity() {
    this.velocityArrow.show();
  }

  void showAcceleration() {
    this.accelerationArrow.show();
  }

  void showVelocity(PVector anchor) {
    velocityArrow.setArrow(anchor, this.velocity.copy().mult(velocityArrowScale));
    this.velocityArrow.show();
  }

  void setHighlighted(boolean _highlighted) {
    this.highlighted = _highlighted;
  }
}//CLASS_END
