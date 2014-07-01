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

boolean doIntersect(Ln l1, Ln l2) {
  Pt p1 = l1.S();
  Pt q1 = l1.E();
  Pt p2 = l2.S();
  Pt q2 = l2.E();

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
  for (int i = 0; i < lns.size (); i++) {
    if (doIntersect(l, lns.get(i))) return true;
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

ArrayList<Integer>[] getNeighbors(ArrayList<Ln> lns, ArrayList<Pt> pts) {
  
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

// positive: v1 rotates clockwise to v2
boolean direction(Pt s1, Pt e1, Pt s2, Pt e2) {
  int dx1 = s1.x - e1.x;
  int dy1 = s1.y - e1.y;
  int dx2 = s2.x - e2.x;
  int dy2 = s2.y - e2.y;
  int cross_product = dx1 * dy2 - dx2 * dy1;
  return cross_product > 0;
}

PolyModel getPolys(ArrayList<Integer>[] neighbors, ArrayList<Ln> lns, ArrayList<Pt> pts) {
  ArrayList<boolean[]> polys = new ArrayList<boolean[]>();
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
      poly[l_index] = true;
      edges_in_poly.add(l_index);
      
//      // find a point on top of start----next
//      Pt midPt = new Pt((pts.get(start).x+pts.get(next).x) / 2, (pts.get(start).y+pts.get(next).y) / 2);
//      Pt somePt = new Pt(0, 0);
//      boolean d = direction(somePt, pts.get(start), pts.get(next), pts.get(start));
      
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
        poly[l_index] = true;
        edges_in_poly.add(l_index);
      }
      // if new poly, add to list
      boolean poly_already_exists = false;
      for (int m = 0; m < polys.size(); m++) {
        int identical_count = 0;
        for (int n = 0; n < lns.size(); n++) {
          if (poly[n] == polys.get(m)[n]) {
            identical_count++;
          }
        }
        if (identical_count == lns.size()) {
          poly_already_exists = true;
          break;
        }
      }
      if (!poly_already_exists) {
        polys.add(poly);
        edges.add(edges_in_poly);
      }
    }  
  }
  pm = new PolyModel(polys, edges);
    
  for (int j = 0; j < edges.size(); j++) {
    for (int k = 0; k < edges.get(j).size(); k++) {
      print(edges.get(j).get(k)+","); 
    }
    println();
  } 

  return pm;
}

void processDrawing(ArrayList<Ln> lns, ArrayList<Pt> pts) {
  ArrayList<Integer>[] neighbors = getNeighbors(lns, pts);
  PolyModel pm = getPolys(neighbors, lns, pts);
}
