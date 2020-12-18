// Final Project: Fire Simulation
// By Mathew Fischbach, fisch872

int iter = 10;
final int n = 100;
float dt = 0.120;
float diffusion = 0.000001;
float viscosity = 0.000001;
color red = color(255,50,0); // red
color org = color(255, 150, 0); // orange
color yel = color(255,255,0); // yellow
float dissipateVal = 0.5;
int scale_val = 4;

//PShader blur;
Fire fire;

void settings() {
  size(n * scale_val, n * scale_val, P2D);
}

void setup(){
  noStroke();
  fire = new Fire(n, dt, diffusion, viscosity);
  //blur = loadShader("data/blur.glsl");
}



void draw(){
  // much faster to use the provided example shader file than the Gaussian blur filter option.
  background(0);
  int cx = int(0.5*width/scale_val);
  int cy = int(0.8*height/scale_val);
  for (int i = -3; i <= 3; i++) {
    for (int j = -1; j <= 1; j++) {
      fire.SetDensity(cx+i, cy+j, random(240, 258));
      fire.SetVelocity(cx+i, cy+j, random(-0.15, 0.15), random(-0.25, 0));
    }
  }
  
  if (mousePressed == true) {
    for (int i = -2; i <= 2; i++) {
      for (int j = -2; j <= 2; j++) {
        fire.SetDensity(mouseX/scale_val+i, mouseY/scale_val+j, random(220, 270));
        fire.SetVelocity(mouseX/scale_val+i, mouseY/scale_val+j, random(-0.15, 0.15), random(-0.25, 0));
      }
    }
    
  }
  
  fire.fireStep();
  fire.Flames();
  fire.dissipate();
  surface.setTitle("Framerate: " + frameRate);
  
  float num = 1.75;
  filter(BLUR, num);
  //if (frameCount % 500 == 0) {
  //  saveFrame("data/current.png");
  //  exit();
  //}
}
