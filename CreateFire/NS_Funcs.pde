void Boundaries(int b, float[] x){
    for(int i = 1; i < n - 1; i++) {
        x[IndexXY(i, 0)] = b == 2 ? -x[IndexXY(i, 1)] : x[IndexXY(i, 1)];
        x[IndexXY(i, n-1)] = b == 2 ? -x[IndexXY(i, n-2)] : x[IndexXY(i, n-2)];
    }

    for(int j = 1; j < n - 1; j++) {
        x[IndexXY(0, j)] = b == 1 ? -x[IndexXY(1, j)] : x[IndexXY(1, j)];
        x[IndexXY(n-1, j)] = b == 1 ? -x[IndexXY(n-2, j)] : x[IndexXY(n-2, j)];
    }

    x[IndexXY(0, 0)]       = 0.5 * (x[IndexXY(1, 0)] + x[IndexXY(0, 1)]);
    x[IndexXY(0, n-1)]     = 0.5 * (x[IndexXY(1, n-1)] + x[IndexXY(0, n-2)]);
    x[IndexXY(n-1, 0)]     = 0.5 * (x[IndexXY(n-2, 0)] + x[IndexXY(n-1, 1)]);
    x[IndexXY(n-1, n-1)]   = 0.5 * (x[IndexXY(n-2, n-1)] + x[IndexXY(n-1, n-2)]);
}


void SolveLinearEq(int b, float[] x, float[] x0, float a, float c){
  float cRecip = 1.0 / c;
  for (int k = 0; k < iter; k++) {
    for (int j = 1; j < n - 1; j++){
      for (int i = 1; i < n - 1; i++){
        x[IndexXY(i, j)] = (
        x0[IndexXY(i, j)] + a *(
            x[IndexXY(i+1, j)] + x[IndexXY(i-1, j)] + x[IndexXY(i, j+1)] + x[IndexXY(i, j-1)]
        )) * cRecip;
      }
    }
    Boundaries(b, x);
  }
}



void diffuse(int b, float[] x, float[] x0, float diffuse, float dt){
  float a = dt * diffuse * (n-2) * (n-2);
  SolveLinearEq(b, x, x0, a, 1 + (4*a));
}


void project(float[] Vx, float[] Vy, float[] p, float[] div){
  for (int j = 1; j < n - 1; j++) {
    for (int i = 1; i < n - 1; i++) {
      div[IndexXY(i, j)] = -0.5f*(
          Vx[IndexXY(i+1, j)] - Vx[IndexXY(i-1, j)] + Vy[IndexXY(i, j+1)] - Vy[IndexXY(i, j-1)]
      )/n;
      p[IndexXY(i, j)] = 0;
    }
  }
  
  Boundaries(0, div); 
  Boundaries(0, p);
  SolveLinearEq(0, p, div, 1, 4);

  for (int j = 1; j < n - 1; j++) {
    for (int i = 1; i < n - 1; i++) {
      Vx[IndexXY(i, j)] -= 0.5f * (p[IndexXY(i+1, j)] - p[IndexXY(i-1, j)]) * n;
      Vy[IndexXY(i, j)] -= 0.5f * (p[IndexXY(i, j+1)] - p[IndexXY(i, j-1)]) * n;
    }
  }

  Boundaries(1, Vx);
  Boundaries(2, Vy);
}


void advect(int b, float[] d, float[] d0,  float[] Vx, float[] Vy, float dt){
  float i0, i1, j0, j1;
  
  float dtx = dt * (n-2);
  float dty = dt * (n-2);
  
  float s0, s1, t0, t1;
  float tmp1, tmp2, x, y;
  
  float nfloat = n;
  float ifloat, jfloat;
  int i, j;

  for(j = 1, jfloat = 1; j < n - 1; j++, jfloat++) { 
    for(i = 1, ifloat = 1; i < n - 1; i++, ifloat++) {
      tmp1 = dtx * Vx[IndexXY(i, j)];
      tmp2 = dty * Vy[IndexXY(i, j)];
      x = ifloat - tmp1; 
      y = jfloat - tmp2;
      
      if(x < 0.5f) {
        x = 0.5f;
      }
      if(x > nfloat + 0.5f) {
        x = nfloat + 0.5f;
      }
      i0 = floor(x); 
      i1 = i0 + 1.0f;

      
      if(y < 0.5f) {
        y = 0.5f;
      } 
      if(y > nfloat + 0.5f) {
        y = nfloat + 0.5f;
      }
      j0 = floor(y);
      j1 = j0 + 1.0f;

      
      s1 = x - i0; 
      s0 = 1.0 - s1; 
      t1 = y - j0; 
      t0 = 1.0 - t1;
      
      int i0i = int(i0);
      int i1i = int(i1);
      int j0i = int(j0);
      int j1i = int(j1);

      d[IndexXY(i, j)] = s0 * (t0 * d0[IndexXY(i0i, j0i)] + t1 * d0[IndexXY(i0i, j1i)]) +
         s1 * (t0 * d0[IndexXY(i1i, j0i)] + t1 * d0[IndexXY(i1i, j1i)]);
    }
  }
  Boundaries(b, d);
}
