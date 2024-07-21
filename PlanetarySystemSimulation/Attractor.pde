class Attractor {
  PVector position ;
  float mass ;
  String name = "Attractor";
  PImage img ;

  Attractor(PVector _position, float _mass) {
    this.position = _position.copy();
    this.mass = _mass;
    this.img = null;
  }

  Attractor(PVector _position, float _mass, PImage _img) {
    this.position = _position.copy();
    this.mass = _mass;
    this.img = _img;
  }

  Attractor() {
    this.position = new PVector(0, 0);
    this.mass = 2000;
    this.img = null;
  }

  Attractor( PImage _img) {
    this.position = new PVector(0, 0);
    this.mass = 2000;
    this.img = _img;
  }

  void show() {
    if (this.img != null) {
      imageMode(CENTER);
      image(img, this.position.x, this.position.y);
      //image(img, this.position.x-this.img.width / 2, this.position.y-this.img.height / 2);
    } else {
      pushStyle();
      noStroke();
      fill(233, 63, 21, 250);
      ellipse(this.position.x, this.position.y, 100, 100);
      popStyle();
    }
  }
}
