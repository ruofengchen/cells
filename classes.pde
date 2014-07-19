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
  
  Pt P(float s, Pt end_pt) {
    return new Pt(int(x*(1-s) + end_pt.x*s), int(y*(1-s) + end_pt.y*s));
  }
  
  Pt P(Vt v, float s) {
    Vt u = v.S(s);
    return new Pt(int(x+u.dx), int(y+u.dy));
  }
  
  void plot() {
    fill(0, 255, 0);
    ellipse(x, y, 20, 20);
    noFill();
  }
  void plot2() {
    fill(0, 128, 0);
    ellipse(x, y, 2, 2);
    noFill();
  }
  void plotLineTo(Pt p) {
    fill(0, 0, 255);
    strokeWeight(5);
    line(x, y, p.x, p.y);
    strokeWeight(1);
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
  ArrayList<Pt> pts;
  int s;
  int e;
  Ln(ArrayList<Pt> pts_, int s_, int e_) {
    pts = pts_;
    if (pts.get(s_).x < pts.get(e_).x) {
      s = s_;
      e = e_;
    }
    else if (pts.get(s_).x > pts.get(e_).x) {
      s = e_;
      e = s_;
    }
    else {
      if (pts.get(s_).y < pts.get(e_).y) {
        s = s_;
        e = e_;
      }
      else {
        s = e_;
        e = s_;
      }
    }
  }
  void plot() {
    fill(0, 0, 128);
    strokeWeight(10);
    line(S().x, S().y, E().x, E().y);
    strokeWeight(1);
    noFill();
  }
  
  Pt S() {
    return pts.get(s);
  }
  Pt E() {
    return pts.get(e);
  }
  boolean equal(Ln l) {
    if (l.S().x == S().x && l.S().y == S().y && l.E().x == E().x && l.E().y == E().y)
      return true;
    else
      return false;
  }
};

class Vt {
  float dx;
  float dy;
  Vt(float _dx, float _dy) {
    dx = _dx;
    dy = _dy;
  }
  Vt(Pt p, Pt q) {
    dx = q.x - p.x;
    dy = q.y - p.y;
  }
  
  Vt S(float s) {
    return new Vt(dx*s, dy*s);
  }
  
  Vt rotate90() {
    float dy_ = - dx / dy;
    return new Vt(1., dy_);
  }
  
  float norm() {
    return sqrt(dx*dx+dy*dy);
  }
};
