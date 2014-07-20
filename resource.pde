class Resource {
  int centerX;
  int centerY;
  float scale;
  PImage img;
  Resource(int centerX_, int centerY_, float scale_, String filename) {
    img = loadImage(filename);
    centerX = centerX_;
    centerY = centerY_;
    scale = scale_; 
  }
  void plotPt(Pt p) {
    image(img, p.x - centerX * scale, p.y - centerY * scale, img.width * scale, img.height * scale);
  }
  void plotLn(Ln l) {
    Vt v = new Vt(l.S(), l.E());
    float numToPlot = v.norm() / img.height / scale * 2;
    for (int i = 0; i < numToPlot; i++) {
      Pt p = l.S().P(i/numToPlot, l.E());
      image(img, p.x - centerX * scale, p.y - centerY * scale, img.width * scale, img.height * scale);
    }
  }
}
