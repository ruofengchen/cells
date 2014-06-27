class Pt {
  int x;
  int y;
  
  Pt(Pt p) {
    x = p.x;
    y = p.y;
  }
  Pt(int x_, int y_) {
    x = x_;
    y = y_;
  }
  void plot() {
    fill(0, 255, 0);
    ellipse(x, y, 20, 20);
    noFill();
  }
  void plotLineTo(Pt p) {
    fill(0, 0, 255);
    line(x, y, p.x, p.y);
    noFill();
  }
  int dist2(Pt p) {
    int dx = p.x - x;
    int dy = p.y - y;
    return dx*dx+dy*dy;
  }
  void moveTo(int x_, int y_) {
    x = x_;
    y = y_;
  }
};

class Ln {
  Pt s;
  Pt e;
  Ln(Pt s_, Pt e_) {
    s = s_;
    e = e_;
  }
  void plot() {
    fill(0, 0, 128);
    line(s.x, s.y, e.x, e.y);
    noFill();
  }

}


