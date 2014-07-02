ArrayList<Integer>[][] AllPairsShortestPaths(ArrayList<Ln> lns, ArrayList<Pt> pts, int[][] dict) 
{
  int N = pts.size();
  int[][] dists = new int[N][N];
  ArrayList<Integer>[][] paths = new ArrayList[N][N];
  for (int i = 0; i < N; i++) {
    for (int j = 0; j < N; j++) {
      paths[i][j] = new ArrayList<Integer>();
    }
  }

  for (int i = 0; i < N; i++) {
    for (int j = i+1; j < N; j++) {
      Ln l = new Ln(pts, i, j);
      if (checkIfLineIsInArray(l, lns) >= 0) {
        dists[i][j] = 1;
        dists[j][i] = 1;
      }
      else {
        dists[i][j] = INFINITY;
        dists[j][i] = INFINITY;
      }
    }
  }

  for (int i = 0; i < N; i++) {
    ArrayList<Integer> curr = new ArrayList<Integer>();
    ArrayList<Integer> next = new ArrayList<Integer>();
    boolean[] visited = new boolean[N];
    for (int j = 0; j < N; j++) {
      visited[j] = false;
    }
    visited[i] = true;
    int visited_count = 1;
    
    curr.add(i);
    
    while (visited_count < N) {
      
      next.clear();
      for (int p = 0; p < curr.size(); p++) {
        for (int j = 0; j < N; j++) {
          if (dists[curr.get(p)][j] == 1 && visited[j] == false) {
            paths[i][j] = new ArrayList<Integer>(paths[i][curr.get(p)]);
            paths[i][j].add(curr.get(p));
            next.add(j);
            visited[j] = true;
            visited_count++;
          }
        }
      }
      curr.clear();
      for (int j = 0; j < next.size(); j++) {
        curr.add(next.get(j));
      }
    }
  }
  
  int prev, next;
  for (int i = 0; i < N; i++) {
    for (int j = 0; j < N; j++) {
      if (i == j) continue;
      for (int k = 0; k < paths[i][j].size()-1; k++) {
        prev = paths[i][j].get(k);
        next = paths[i][j].get(k+1);
        paths[i][j].set(k, dict[prev][next]);
      }
      prev = paths[i][j].get(paths[i][j].size()-1);
      paths[i][j].set(paths[i][j].size()-1, dict[prev][j]);
    }
  }
  
//  for (int i = 0; i < N; i++) {
//    for (int j = 0; j < N; j++) {
//      print(i+"=>"+j+":");
//      for (int k = 0; k < paths[i][j].size(); k++) {
//        print(paths[i][j].get(k)+",");
//      }
//      println("");
//    }
//  }

  return paths;
}

boolean checkPathIntersection(ArrayList<Integer> p1, ArrayList<Integer> p2) {
  if (p1.size() == 0 || p2.size() == 0) return false;
  for (int i = 0; i < p1.size(); i++) {
    for (int j = 0; j < p2.size(); j++) {
      if (p1.get(i) == p2.get(j))
        return false;
    }
  }
  return true;
}

int[][] generatePointsToLineDictionary(ArrayList<Ln> lns, ArrayList<Pt> pts) {
  int[][] dict = new int[pts.size()][pts.size()];
  for (int i = 0; i < pts.size(); i++) {
    for (int j = i+1; j < pts.size(); j++) {
      Ln l = new Ln(pts, i, j);
      dict[i][j] = checkIfLineIsInArray(l, lns);
      dict[j][i] = dict[i][j];
    }
  }
  return dict;
}

ArrayList<boolean[]> AllCycles(ArrayList<Ln> lns, ArrayList<Pt> pts, ArrayList<Integer>[][] paths) {
  int prev, next, l_index;
  ArrayList<boolean[]> cycles = new ArrayList<boolean[]>();
  for (int i = 0; i < pts.size(); i++) {
    for (int j =0; j < lns.size(); j++) {
      int s = lns.get(j).s;
      int e = lns.get(j).e;
      
      if (checkPathIntersection(paths[s][i], paths[i][e])) {
//        println(s+";;"+i+";;"+e);
//        for (int k = 0; k < paths[s][i].size(); k++) {
//          print(paths[s][i].get(k)+"-");
//        }
//        println();
//        for (int k = 0; k < paths[i][e].size(); k++) {
//          print(paths[i][e].get(k)+"-");
//        }
//        println();
        boolean []cycle = new boolean[lns.size()];
        for (int k = 0; k < paths[s][i].size(); k++) {
          l_index = paths[s][i].get(k);
          cycle[l_index] = true;
        }
        
        for (int k = 0; k < paths[i][e].size(); k++) {
          l_index = paths[i][e].get(k);
          cycle[l_index] = true;
        }
        l_index = paths[s][e].get(0);
        cycle[l_index] = true;
        
        // check if this cycle already in the array
        boolean cycle_already_exists = false;
        for (int k = 0; k < cycles.size(); k++) {
          int identical_count = 0;
          for (int l = 0; l < lns.size(); l++) {
            if (cycle[l] == cycles.get(k)[l]) {
              identical_count++;
            }
          }
          if (identical_count == lns.size()) {
            cycle_already_exists = true;
            break;
          }
        }
        if (!cycle_already_exists)
          cycles.add(cycle);
        
      }
    }
  }
  
  boolean[] kill = new boolean[lns.size()];
  for (int i = 0; i < cycles.size(); i++) {
    for (int j = i+1; j < cycles.size(); j++) {
      boolean[] sum = new boolean[lns.size()];
      for (int m = 0; m < lns.size(); m++) {
        sum[m] = cycles.get(i)[m] != cycles.get(j)[m];
      }
//      if (i == 2 && j == 13) {
//        for (int m = 0; m < lns.size(); m++) {
//          print(cycles.get(i)[m]+",");
//        }
//        println();
//        for (int m = 0; m < lns.size(); m++) {
//          print(cycles.get(j)[m]+",");
//        }
//        println();        
//      }
      for (int l = 0; l < cycles.size(); l++) {
        if (kill[l])
          continue;
        if (l != i && l != j) {
          int identical_count = 0;
          for (int m = 0; m < lns.size(); m++) {
//            println(sum[m]+" "+cycles.get(l)[m]);
            if (sum[m] == cycles.get(l)[m]) {
              identical_count++;
            }
          }
          if (identical_count == lns.size())
            kill[l] = true;
//          if (l == 0 && i == 2 && j == 13) {
//            for (int m = 0; m < lns.size(); m++) {
//              print(sum[m]+",");
//            }
//            println();
//            for (int m = 0; m < lns.size(); m++) {
//              print(cycles.get(l)[m]+",");
//            }
//            println();
//          }
        }
      }
    }
  }
  
//  println("cycles:"+cycles.size());
//  for (int i = 0; i < cycles.size(); i++) {
//    for (int z = 0; z < lns.size(); z++) {
//      if (cycles.get(i)[z] == true)
//        print(z+",");
//    }
//    println(" "+kill[i]);
//  }
  
  return cycles;
}

ArrayList<Pt>[] getInnerPoints(ArrayList<boolean[]> polys, ArrayList<Ln> lns, ArrayList<Pt> pts) {
  ArrayList<Pt>[] inpts = new ArrayList[polys.size()];
  for (int i = 0; i < polys.size(); i++) {
    inpts[i] = new ArrayList<Pt>();
    for (int j = 0; j < lns.size(); j++) {
      for (int k = j+1; k < lns.size(); k++) {
        int connectPt = getConnectPoint(lns.get(j), lns.get(k));
        if (connectPt >= 0) {
          int anotherPt = lns.get(j).s;
          if (lns.get(j).s == connectPt)
            anotherPt = lns.get(j).e;
          int yetAnotherPt = lns.get(k).s;
          if (lns.get(k).s == connectPt)
            yetAnotherPt = lns.get(k).e;  
            
          // calculate center of three points
          Pt inpt = new Pt((pts.get(connectPt).x+pts.get(anotherPt).x+pts.get(yetAnotherPt).x)/3, (pts.get(connectPt).y+pts.get(anotherPt).y+pts.get(yetAnotherPt).y)/3);
          if (true) // if this point is inside the poly area
            inpts[i].add(inpt);
        }
      }
        
    }
  }
  return inpts;
}
