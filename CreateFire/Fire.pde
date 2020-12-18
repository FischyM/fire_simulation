// get 3D location from 1D array
int IndexXY(int x, int y){  //, int z
  x = constrain(x, 0, n-1);
  y = constrain(y, 0, n-1);
  //z = constrain(z, 0, n-1);
  return (x + n*y);  // + n*n*z
}
  

class Fire {
  float dt;  // time-step
  float diffusion;
  float viscosity;
  
  // current and previous density
  float[] density;
  float[] density0;
  
  // current velocities
  float[] Vx;
  float[] Vy;
  //float[] Vz;

  // previous velocities
  float[] Vx0;
  float[] Vy0;
  //float[] Vz0;
  
  Fire(int size, float dt, float diffusion, float viscosity){
    //int n2 = size * size * size;
    int n2 = size * size;
    this.dt = dt;
    this.diffusion = diffusion;
    this.viscosity = viscosity;
    
    this.density = new float[n2];
    this.density0 = new float[n2];
    
    this.Vx = new float[n2];
    this.Vy = new float[n2];
    //this.Vz = new float[n2];
    
    this.Vx0 = new float[n2];
    this.Vy0 = new float[n2];
    //this.Vz0 = new float[n2];
  }
    
  void ChangeDensity(int x, int y, float change){
    int index = IndexXY(x, y);
    this.density[index] += change;
  }
  
  void ChangeVelocity(int x, int y, float changeX, float changeY){
    int index = IndexXY(x, y);
    this.Vx[index] += changeX;
    this.Vy[index] += changeY;
  }
  
  void SetDensity(int x, int y, float val) {
    int index = IndexXY(x, y);
    this.density[index] = val;
  }
  
  void SetVelocity(int x, int y, float valX, float valY){
    int index = IndexXY(x, y);
    this.Vx[index] = valX;
    this.Vy[index] = valY;
  }
  
  void Flames(){
    for (int i = 0; i < n; i++) {
      for (int j = 0; j < n; j++) {
        float x = i * scale_val;
        float y = j * scale_val;
        float d = this.density[IndexXY(i, j)];
        d = constrain(d, 0, 255);
        if (d > 246) {
          fill(lerpColor(org, red, d/255), d);
        }
        else if (d > 240){
          fill(lerpColor(yel, org, d/255), d);
        }
        else if (d > 233){
          fill(lerpColor(color(255), yel, d/255), d);
        }
        else {
          fill(255,255,255,d);
        }
        square(x, y, 1 * scale_val);
      }
    }
  }
  
  void dissipate() {
    for (int i = 0; i < this.density.length; i++) {
      float d = density[i];
      density[i] = constrain(d-dissipateVal, 0, 255);
    }
  }
    
  void fireStep(){
    diffuse(1, this.Vx0, this.Vx, this.viscosity, this.dt);
    diffuse(2, this.Vy0, this.Vy, this.viscosity, this.dt);
    //diffuse(3, this.Vz0, this.Vz, this.visc, this.dt);
    
    project(Vx0, Vy0, Vx, Vy);
    advect(1, this.Vx, this.Vx0, this.Vx0, this.Vy0, this.dt);
    advect(2, this.Vy, this.Vy0, this.Vx0, this.Vy0, this.dt);
    project(this.Vx, this.Vy, this.Vx0, this.Vy0);
    diffuse(0, this.density0, this.density, this.diffusion, this.dt);
    advect(0, this.density, this.density0, this.Vx, this.Vy, this.dt);
  }
  
}
