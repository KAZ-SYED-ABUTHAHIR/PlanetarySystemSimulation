class ArealTriangle {
  PVector[] arealPoints = new PVector[3];
  color drawColor ;
  boolean isDrawn = true;

  ArealTriangle(PVector _vertex1, PVector _vertex2, PVector _vertex3) {
    this.arealPoints[1] = _vertex1;
    this.arealPoints[0] = _vertex2;
    this.arealPoints[2] = _vertex3;
    this.drawColor = color(100, 220, 250, 255);
  }

  float getArea() {
    PVector v1 = arealPoints[0];
    PVector v2 = arealPoints[1];
    PVector v3 = arealPoints[2];

    float area = abs(
      v1.x * (v2.y - v3.y) +
      v2.x * (v3.y - v1.y) +
      v3.x * (v1.y - v2.y)
      ) / 2.0;

    return area;
  }

  private color getRandomColor() {
    float r = random(255);
    float g = random(255);
    float b = random(255);
    return color(r, g, b);
  }

  void show() {
    if (isDrawn) {

      PShape triangleShape = createShape();

      triangleShape.beginShape();
      //triangleShape.fill(drawColor);
      //triangleShape.noStroke();
      for (PVector v : arealPoints) {
        triangleShape.vertex(v.x, v.y);
      }

      triangleShape.endShape(CLOSE);
      shape(triangleShape);
    }
  }

  void show(color _drawColor) {
    if (isDrawn) {
      fill(_drawColor);
      stroke(_drawColor);
      strokeWeight(0);
      beginShape();
      vertex(arealPoints[0].x, arealPoints[0].y);
      vertex(arealPoints[1].x, arealPoints[1].y);
      vertex(arealPoints[2].x, arealPoints[2].y);
      endShape(CLOSE);
    }
  }
  
    void show(color _drawColor, float alpha) {
    if (isDrawn) {
      int r = (int) red(_drawColor);
      int g = (int) green(_drawColor);
      int b = (int) blue(_drawColor);
      color transparentColor = color(r, g, b, alpha);
      fill(transparentColor);
      stroke(transparentColor);
      strokeWeight(3);
      beginShape();
      vertex(arealPoints[0].x, arealPoints[0].y);
      vertex(arealPoints[1].x, arealPoints[1].y);
      vertex(arealPoints[2].x, arealPoints[2].y);
      endShape(CLOSE);
    }
  }
}
