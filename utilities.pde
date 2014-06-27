boolean onSegment(Pt p, Pt q, Pt r)
{
    if (q.x < max(p.x, r.x) && q.x > min(p.x, r.x) &&
        q.y < max(p.y, r.y) && q.y > min(p.y, r.y))
       return true;
    return false;
}

int orientation(Pt p, Pt q, Pt r)
{
    // See 10th slides from following link for derivation of the formula
    // http://www.dcs.gla.ac.uk/~pat/52233/slides/Geometry1x1.pdf
    int val = (q.y - p.y) * (r.x - q.x) -
              (q.x - p.x) * (r.y - q.y);
 
    if (val == 0) return 0;  // colinear
 
    return (val > 0)? 1: 2; // clock or counterclock wise
}

boolean doIntersect(Ln l1, Ln l2) {
  Pt p1 = l1.s;
  Pt q1 = l1.e;
  Pt p2 = l2.s;
  Pt q2 = l2.e;
  
  // if they share the same point, they don't intersect
  if (p1 == p2 || p1 == q2 || q1 == q2 || q1 == p2)
    return false;
  
  // Find the four orientations needed for general and
  // special cases
  int o1 = orientation(p1, q1, p2);
  int o2 = orientation(p1, q1, q2);
  int o3 = orientation(p2, q2, p1);
  int o4 = orientation(p2, q2, q1);
   
  // General case
  if (o1 != o2 && o3 != o4)
      return true;
   
  // Special Cases
  // p1, q1 and p2 are colinear and p2 lies on segment p1q1
  if (o1 == 0 && onSegment(p1, p2, q1)) return true;
   
  // p1, q1 and p2 are colinear and q2 lies on segment p1q1
  if (o2 == 0 && onSegment(p1, q2, q1)) return true;
   
  // p2, q2 and p1 are colinear and p1 lies on segment p2q2
  if (o3 == 0 && onSegment(p2, p1, q2)) return true;
   
   // p2, q2 and q1 are colinear and q1 lies on segment p2q2
  if (o4 == 0 && onSegment(p2, q1, q2)) return true;
   
  return false; // Doesn't fall in any of the above cases
}

boolean checkIfLineIsInArray(Ln l, ArrayList<Ln> lns) {
  for (int i = 0; i < lns.size(); i++) {
    if (lns.get(i).s.x == l.s.x && lns.get(i).s.y == l.s.y && lns.get(i).e.x == l.e.x && lns.get(i).e.y == l.e.y) return true;
    if (lns.get(i).e.x == l.s.x && lns.get(i).e.y == l.s.y && lns.get(i).s.x == l.e.x && lns.get(i).s.y == l.e.y) return true;
  }
  return false;
}

boolean checkIfLineCrossExistingLine(Ln l, ArrayList<Ln> lns) {
  for (int i = 0; i < lns.size(); i++) {
    if (doIntersect(l, lns.get(i))) return true;
  }
  return false;
}

ArrayList<Pt> getPointsThePointIsOn(Pt p, ArrayList<Ln> lns) {
  ArrayList<Pt> filtered_pts = new ArrayList<Pt>();
  for (int i = 0; i < lns.size(); i++) {
    if (lns.get(i).s == p) {
      filtered_pts.add(lns.get(i).e);
    }
    if (lns.get(i).e == p) {
      filtered_pts.add(lns.get(i).s);
    }
  }
  return filtered_pts;
}

void getPolygons(ArrayList<Ln> lns, ArrayList<Pt> pts) {
  Pt p = pts.get(0);
  ArrayList<Pt> connected_pts = getPointsThePointIsOn(p, lns);
  
}
