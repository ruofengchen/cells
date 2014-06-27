// need to change Ln data structure

ArrayList<Pt> pts = new ArrayList<Pt>();
ArrayList<Ln> lns = new ArrayList<Ln>();
int d_th = 400; // finger gap threshold for new point or selection recognition
boolean place_new_point = false;
boolean draw_line = false;
int mouse_selected_idx;
boolean drag_point = false;

void setup() {
  size(800, 600);
}

void draw() {
  background(150);
  
  for (int i = 0; i < pts.size(); i++) {
    pts.get(i).plot();
    fill(0);
    text(i, pts.get(i).x, pts.get(i).y-10);
    noFill();
  }
  
  for (int i = 0; i < lns.size(); i++) {
    lns.get(i).plot();
    fill(255);
    text(i, (lns.get(i).s.x+lns.get(i).e.x)/2, (lns.get(i).s.y+lns.get(i).e.y)/2-10);
    noFill();
  }
  
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
      if (lns.get(i).s == pts.get(j)) {
        value.setInt("s_idx", j);
      }
      if (lns.get(i).e == pts.get(j)) {
        value.setInt("e_idx", j);
      } 
    }
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
    Ln ln = new Ln(pts.get(s_idx), pts.get(e_idx));
    lns.add(ln);
  }
}

void mousePressed() {
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

void mouseReleased() {
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
      Ln l = new Ln(pts.get(mouse_selected_idx), pts.get(selected));
      if (!checkIfLineIsInArray(l, lns) && !checkIfLineCrossExistingLine(l, lns))
        lns.add(l);
    }
  }
  
  place_new_point = false;
  
}

void keyPressed() {
  if (key == 's') {
    saveToFile();
  }
  if (key == 'l') {
    loadFromFile();
  }
}
