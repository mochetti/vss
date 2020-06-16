// Classe que gerencia os robos

class Robo {
  PVector pos, vel, obj;
  float ang = 0;
  byte velD, velE;
  // Velocidade maxima do robo
  byte velMax = byte(200);
  int v = 0;
  int index;
  
  Robo(int n) {
    index = n;
    pos = new PVector(blobs.get(n+1).center().x, blobs.get(n+1).center().y);
    vel = new PVector();
    obj = new PVector();
  }
  
  Robo(Robo r) {
    pos = r.pos;
    vel = r.vel;
    ang = r.ang;
    index = r.index;
  }
  
  void setVel(PVector income) {
    vel = income;
  }
  void setVel(float v1, float v2) {
    vel.set(v1, v2);
  }
  
  // Define posicao do objetivo como vetor
  void setObj(PVector income) {
    obj = income;
    //println(velObj);
  }
  
  // Define posicao do objetivo como coordenadas
  void setObj(float x, float y) {
    if(x > width) x = width;
    if(x < 0) x = 0;
    if(y > height) y = height;
    if(y < 0) y = 0;
    
    obj.x = x;
    obj.y = y;
  }
  
  void setEstrategia(int n) {
    estrategia(this, n);
  }
  void setAng(float income) {
    ang = income;
  }
  float getAng(boolean degress) {
    
    switch(index) {
      case 0:    // 1 verde
        ang = atan2(blobs.get(1).center().y - blobs.get(4).center().y, blobs.get(1).center().x - blobs.get(4).center().x) + 3*PI/4;
      break;
      
      case 1:    // 2 verdes
        ang = atan2(blobs.get(2).center().y - blobs.get(5).center().y, blobs.get(2).center().x - blobs.get(5).center().x);
        ang += atan2(blobs.get(2).center().y - blobs.get(6).center().y, blobs.get(2).center().x - blobs.get(6).center().x);
        ang /= 2;
        ang += PI;
      break;
      
      case 2:    // 3 verdes
        ang = atan2(blobs.get(3).center().y - blobs.get(7).center().y, blobs.get(3).center().x - blobs.get(7).center().x);
        ang += atan2(blobs.get(3).center().y - blobs.get(8).center().y, blobs.get(3).center().x - blobs.get(8).center().x);
        ang += atan2(blobs.get(3).center().y - blobs.get(9).center().y, blobs.get(3).center().x - blobs.get(9).center().x);
        ang /= 3;
        ang -= 3*PI/4;
      break;
    }
    while(ang > 2*PI) ang -= 2*PI;
    while(ang < -2*PI) ang += 2*PI;
    if(degress) return degrees(ang);
    return ang;
  }
  
  // Funcoes de debug
  void debugAng() {
    //println(degrees(ang));
    arrow(pos.x, pos.y, pos.x + 50*cos(ang), pos.y + 50*sin(ang));
  }
  void debugObj() {
    arrow(pos.x, pos.y, obj.x, obj.y);
    fill(255, 0, 0);
    ellipse(obj.x, obj.y, 30, 30);
  }
}
