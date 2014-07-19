void place_start_point() {
  if (status != 1) return;
  Pt mouse_pt = new Pt(mouseX, mouseY);
  int poly_idx = getPolygonPointFallsIn(polyes, mouse_pt, outsidePoly);
  if (poly_idx != outsidePoly) { // only allow placing inside
    trail.add(mouse_pt);
    path.add(poly_idx);
    lns_used = new boolean[lns.size()];
    status = 2;
  }
}

void move_forward() {
  if (status != 2) return;
  Pt last_pt = trail.get(trail.size()-1);
  Pt mouse_pt = new Pt(mouseX, mouseY);
  int poly_idx = getPolygonPointFallsIn(polyes, mouse_pt, outsidePoly);
  if (poly_idx != outsidePoly && IsPolyNeighborOfPoly(polyns, path.get(path.size()-1), poly_idx)) {
    ArrayList<Integer> crosslns = getCommonLinesOfTwoPolys(polyes, lns, path.get(path.size()-1), poly_idx);
    int l_cross = cutLine(crosslns, mouse_pt);
//    println(l_cross+","+lns_used[l_cross]);
    if (path.size() == 1 || 
    (!lns_used[l_cross] && path.size() > 1 && isTheTwoLinesAdjacent(polyes, path.get(path.size()-1), lns_used, l_cross, path.get(path.size()-2)))) {
      Pt next_pt = calculatePtInNextPoly(polyes, lns, poly_idx, l_cross, mouse_pt);
      lns_used[l_cross] = true;
      
      ArrayList<Pt> added_trail = calculateTrail(polyes, lns, poly_idx, l_cross, last_pt, next_pt);
      for (int i = 0; i < added_trail.size(); i++) {
        trail.add(added_trail.get(i));
      }
      path.add(l_cross);
      path.add(poly_idx);
    }
  }
  
}
