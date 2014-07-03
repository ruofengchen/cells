void place_start_point() {
  if (status != 1) return;
  Pt mouse_pt = new Pt(mouseX, mouseY);
  int poly_idx = getPolygonPointFallsIn(polyes, mouse_pt, outsidePoly);
  if (poly_idx != outsidePoly) { // only allow placing inside
    trail.add(mouse_pt);
    path.add(poly_idx);
    status = 2;
  }
}

void move_forward() {
  if (status != 2) return;
  Pt last_pt = trail.get(trail.size()-1);
  Pt mouse_pt = new Pt(mouseX, mouseY);
  int poly_idx = getPolygonPointFallsIn(polyes, mouse_pt, outsidePoly);
  if (IsPolyNeighborOfPoly(polyns, path.get(path.size()-1), poly_idx)) {
    println("valid move");
    trail.add(mouse_pt);
    int next_l_idx = cutLine(polyes, lns, poly_idx, mouse_pt);
    path.add(next_l_idx);
    path.add(poly_idx);
  }
  else {
    println("invalid move");
  }
  
}
