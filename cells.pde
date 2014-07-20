// need to change Ln data structure

ArrayList<Pt> pts = new ArrayList<Pt>();
ArrayList<Ln> lns = new ArrayList<Ln>();
int d_th = 400; // finger gap threshold for new point or selection recognition
boolean place_new_point = false;
boolean draw_line = false;
int mouse_selected_idx;
boolean drag_point = false;

ArrayList<ArrayList<Integer>> polyes; // use negative number to denote corrupted edges
int outsidePoly = -1;
ArrayList<Integer>[] polyns;
int status = 0; // 0: draw, 1: generated models

boolean[] lns_used; // corrupted line indexes
ArrayList<Pt> trail = new ArrayList<Pt>(); // for rendering
ArrayList<Integer> path = new ArrayList<Integer>(); // for calculation

Resource vertex;
Resource edge;
Resource player;
Resource mark;

void setup() {
  size(800, 600);
  vertex = new Resource(51, 132, 0.25, "images/cone.gif");
  edge = new Resource(126, 178, 0.1, "images/bush.gif");
  player = new Resource(80, 370, 0.4, "images/rage.gif");
  mark = new Resource(50, 65, 0.2, "images/poop.gif");
}

void draw() {
  background(150);
  
  for (int i = 0; i < lns.size(); i++) {
    edge.plotLn(lns.get(i));
    fill(255);
    text(i, (lns.get(i).S().x+lns.get(i).E().x)/2, (lns.get(i).S().y+lns.get(i).E().y)/2-10);
    noFill();
  }
  
  for (int i = 0; i < pts.size(); i++) {
    vertex.plotPt(pts.get(i));
    fill(0);
    text(i, pts.get(i).x, pts.get(i).y-10);
    noFill();
  }
  

  
  if (status == 0) { // configure geometry
  
    if (place_new_point) {
      fill(255, 0, 0);
      ellipse(mouseX, mouseY, 20, 20);
      noFill();
    }
    
    if (draw_line) {
      pts.get(mouse_selected_idx).plotLineTo(new Pt(mouseX, mouseY));
    }
    if (drag_point) {
      pts.get(mouse_selected_idx).moveTo(mouseX, mouseY);
    }
  
  }
  
  if (status > 0) { // gameplay
  
    for (int i = 0; i < polyes.size(); i++) {
      Pt p = getPointInsidePoly(polyes, i);
      fill(200, 0 , 0);
      text(i, p.x, p.y);
      noFill();
    }
    
    if (status == 1) { // place starting point
      
    }
    
    if (status == 2) {
      for (int i = 0; i < trail.size()-1; i++) {
        mark.plotPt(trail.get(i));
      }
      player.plotPt(trail.get(trail.size()-1));
      for (int i = 0; i < lns.size(); i++) {
        if (lns_used[i]) {
          fill(255, 255, 0);
          text(i, (lns.get(i).S().x+lns.get(i).E().x)/2, (lns.get(i).S().y+lns.get(i).E().y)/2-10);
          noFill();
        }
      }
    }
  }
  
//  // debug
//  if (inpts != null) {
//    for (int i = 0; i < polys.size(); i++) {
//      for (int j = 0; j < inpts[i].size(); j++) {
//        inpts[i].get(j).plot2();
//      }
//    }
//  }
}

int selectPoint() {
  if (pts.size() == 0) return -1; // negative means new point
  Pt mousePt = new Pt(mouseX, mouseY);
  int dmin = 9999999;
  int argmin = 0;
  for (int i = 0; i < pts.size(); i++) {
    int d = mousePt.dist2(pts.get(i));
    if (d < dmin) {
      dmin = d;
      argmin = i;
    }
  }
  if (dmin < d_th) {
    return argmin;
  }
  else {
    return -1;
  }
}

void saveToFile() {
  JSONArray values = new JSONArray();
  for (int i = 0; i < pts.size(); i++) {
    JSONObject value = new JSONObject();
    value.setInt("x", pts.get(i).x);
    value.setInt("y", pts.get(i).y);
    values.setJSONObject(i, value);
  }
  saveJSONArray(values, "points.json");
  
  values = new JSONArray();
  for (int i = 0; i < lns.size(); i++) {
    JSONObject value = new JSONObject();
    for (int j = 0; j < pts.size(); j++) {
      if (lns.get(i).S() == pts.get(j)) {
        value.setInt("s_idx", j);
      }
      if (lns.get(i).S() == pts.get(j)) {
        value.setInt("e_idx", j);
      } 
    }
    value.setInt("s_idx", lns.get(i).s);
    value.setInt("e_idx", lns.get(i).e);
    values.setJSONObject(i, value);
  }
  saveJSONArray(values, "lines.json");
}

void loadFromFile() {
  JSONArray values = loadJSONArray("points.json");
  for (int i = 0; i < values.size(); i++) {
    JSONObject pt_json = values.getJSONObject(i);
    int x = pt_json.getInt("x");
    int y = pt_json.getInt("y");
    Pt pt = new Pt(x, y);
    pts.add(pt);
  }
  
  values = loadJSONArray("lines.json");
  for (int i = 0; i < values.size(); i++) {
    JSONObject ln_json = values.getJSONObject(i);
    int s_idx = ln_json.getInt("s_idx");
    int e_idx = ln_json.getInt("e_idx");
    Ln ln = new Ln(pts, s_idx, e_idx);
    lns.add(ln);
  }
}

void mousePressed() {
  
  if (status == 0) {
  
    int selected = selectPoint();
    if (selected < 0) {
      place_new_point = true;
      draw_line = false;
    }
    else {
      if (keyPressed == true && key == ' ') {
        drag_point = true;
        mouse_selected_idx = selected;
      }
      else {
        draw_line = true;
        mouse_selected_idx = selected;
      }
    }
  
  }
}

void mouseReleased() {
  
  if (status == 0) {
  
    draw_line = false;
    drag_point = false;
    int selected = selectPoint();
    if (selected < 0) {
      if (place_new_point == true) {
        Pt pt = new Pt(mouseX, mouseY);
        pts.add(pt);
      }
    }
    else {
      if (mouse_selected_idx != selected) {
        Ln l = new Ln(pts, mouse_selected_idx, selected);
        if (checkIfLineIsInArray(l, lns) < 0 && !checkIfLineCrossExistingLine(l, lns))
          lns.add(l);
      }
    }
    
    place_new_point = false;
    return;
  }
  
  if (status == 1) {
    place_start_point();
    println("start point placed.");
    return;
  }
  
  if (status == 2) {
    move_forward();
    return;
  }
  
}

void keyPressed() {
  if (key == 's') {
    saveToFile();
  }
  if (key == 'l') {
    loadFromFile();
  }
  if (key == 't') {
    processDrawing(lns, pts);
  }
}
