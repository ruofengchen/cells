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
  void plot2() {
    fill(0, 128, 0);
    ellipse(x, y, 10, 10);
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
    line(S().x, S().y, E().x, E().y);
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

class PolyModel {
  ArrayList<boolean[]> polys;
  ArrayList<ArrayList<Integer>> edges;
  PolyModel(ArrayList<boolean[]> polys_, ArrayList<ArrayList<Integer>> edges_) {
    polys = polys_;
    edges = edges_;
  }
};
