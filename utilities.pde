int INFINITY = 65535;

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

boolean doIntersect(Pt p1, Pt q1, Pt p2, Pt q2) {

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

int checkIfLineIsInArray(Ln l, ArrayList<Ln> lns) {
  for (int i = 0; i < lns.size (); i++) {
    if (l.equal(lns.get(i))) 
      return i;
  }
  return -1;
}

boolean checkIfLineCrossExistingLine(Ln l, ArrayList<Ln> lns) {
  for (int i = 0; i < lns.size(); i++) {
    if (doIntersect(l.S(), l.E(), lns.get(i).S(), lns.get(i).E()))
      return true;
  }
  return false;
}

int getConnectPoint(Ln l1, Ln l2) {
  if (l1.s == l2.s || l1.s == l2.e)
    return l1.s;
  if (l1.e == l2.s || l1.e == l2.e)
    return l1.e;
  else return -1; 
}

ArrayList<Integer>[] getNeighborsOfLines(ArrayList<Ln> lns, ArrayList<Pt> pts) {
  
  // find neighbors
  ArrayList<Integer>[] neighbors = new ArrayList[pts.size()];
  for (int i = 0; i < pts.size(); i++) {
    neighbors[i] = new ArrayList<Integer>();
  }
  for (int i = 0; i < pts.size(); i++) {
    for (int j = i+1; j < pts.size(); j++) {
      Ln l = new Ln(pts, i, j);
      if (checkIfLineIsInArray(l, lns) >= 0) {
        neighbors[i].add(j);
        neighbors[j].add(i);
      }
    }
  }
  
  // sort neighbors by atan
  for (int i = 0; i < pts.size(); i++) {
    float[] angle = new float[neighbors[i].size()];
    for (int j = 0; j < neighbors[i].size(); j++) {
      angle[j] = atan2(pts.get(neighbors[i].get(j)).y - pts.get(i).y, pts.get(neighbors[i].get(j)).x - pts.get(i).x);
    }
    
    // selection sort
    int min_idx;
    for (int j = 0; j < neighbors[i].size(); j++) {
      min_idx = j;
      for (int k = j+1; k < neighbors[i].size(); k++) {
        if (angle[k] < angle[min_idx]) {
          min_idx = k;
        }
      }
      if (min_idx != j) {
        float tmp_angle = angle[min_idx];
        angle[min_idx] = angle[j];
        angle[j] = tmp_angle;
        int tmp_neighbor = neighbors[i].get(min_idx);
        neighbors[i].set(min_idx, neighbors[i].get(j));
        neighbors[i].set(j, tmp_neighbor);
      }
    }
  }

//  for (int i = 0; i < pts.size(); i++) {
//    print(i+":");
//    for (int j = 0; j < neighbors[i].size(); j++) {
//      print(neighbors[i].get(j)+",");
//    }
//    println();
//  }
  return neighbors;
}



ArrayList<ArrayList<Integer>> getEdgesOfPolys(ArrayList<Integer>[] neighbors, ArrayList<Ln> lns, ArrayList<Pt> pts) {
  ArrayList<ArrayList<Integer>> edges = new ArrayList<ArrayList<Integer>>();
  
  for (int i = 0; i < pts.size(); i++) {
    for (int j = 0; j < neighbors[i].size(); j++) {
      boolean[] poly = new boolean[lns.size()];
      ArrayList<Integer> edges_in_poly = new ArrayList<Integer>(); // store edges in a poly clockwise
      
      // build poly and verts
      int start = i;
      int next = neighbors[i].get(j);
      Ln l = new Ln(pts, start, next);
      int l_index = checkIfLineIsInArray(l, lns);
      edges_in_poly.add(l_index);
      
      while (next != i) {
        // find the next radial line
        int k = 0;
        while (neighbors[next].get(k) != start) {
          k = (k + neighbors[next].size() - 1) % neighbors[next].size();
        }
        start = next;
        k = (k + neighbors[next].size() - 1) % neighbors[next].size();
        next = neighbors[next].get(k);
        l = new Ln(pts, start, next);
        l_index = checkIfLineIsInArray(l, lns);
        edges_in_poly.add(l_index);
      }
      // if new poly, add to list
      boolean poly_already_exists = false;
      for (int m = 0; m < edges.size(); m++) {
        if (edges.get(m).size() != edges_in_poly.size())
          continue;
        // find the first alignment
        int iter_start = -1;
        for (int n = 0; n < edges_in_poly.size(); n++) {
          if (edges_in_poly.get(n) == edges.get(m).get(0)) {
            iter_start = n;
            break;
          }
        }
        if (iter_start < 0)
          continue;
        int identical_count = 0;
        for (int n = 0; n < edges_in_poly.size(); n++) {
          if (edges_in_poly.get((n+iter_start)%edges_in_poly.size()) == edges.get(m).get(n)) {
            identical_count++;
          }
        }
        if (identical_count == edges_in_poly.size()) {
          poly_already_exists = true;
          break;
        }
      }
      if (!poly_already_exists) {
        edges.add(edges_in_poly);
      }
    }  
  }
    
//  for (int j = 0; j < edges.size(); j++) {
//    for (int k = 0; k < edges.get(j).size(); k++) {
//      print(edges.get(j).get(k)+","); 
//    }
//    println();
//  } 
  return edges;
}

ArrayList<Integer>[] getNeighborsOfPolys(ArrayList<ArrayList<Integer>> polyes) {

  ArrayList<Integer>[] neighbors = new ArrayList[polyes.size()];
  for (int i = 0; i < polyes.size(); i++) {
    neighbors[i] = new ArrayList<Integer>();
    for (int j = 0; j < polyes.get(i).size(); j++) { // look at edges of a poly in order
      for (int m = 0; m < polyes.size(); m++) {
        if (m != i) {
          for (int n = 0; n < polyes.get(m).size(); n++) {
            if (polyes.get(m).get(n) == polyes.get(i).get(j)) {
              neighbors[i].add(m);
            }
          }
        }
      }
    }
  }
  
//  for (int i = 0; i < polyes.size(); i++) {
//    print(i+":");
//    for (int j = 0; j < neighbors[i].size(); j++) {
//      print(neighbors[i].get(j)+",");
//    }
//    println();
//  }
  
  return neighbors;
}

void processDrawing(ArrayList<Ln> lns, ArrayList<Pt> pts) {
  ArrayList<Integer>[] neighbors = getNeighborsOfLines(lns, pts);
  polyes = getEdgesOfPolys(neighbors, lns, pts);
  polyns = getNeighborsOfPolys(polyes);
  status = 1;
}

int getPolygonPointFallsIn(ArrayList<Integer>[] polyes, Pt p) {
  
  // to-do:
  // 1. remove the big polygon
  // 2. finish this function
  
}
