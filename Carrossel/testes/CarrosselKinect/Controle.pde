// Tolerancia de diferença entre os angulos
float dAng = 15;

void alinha(Robo r) {
  // Alinha e chuta
  // Angulo do objetivo
  float ang = atan2(r.obj.x, r.obj.y);
  if((r.getAng(false) - ang) < radians(dAng) && (r.getAng(false) - ang) > radians(-dAng)) {
    // Chuta
    r.velE = r.velMax;
    r.velD = r.velMax;
  }
  else {
    // Alinha
    if((r.getAng(false) - ang) < 0)
      gira(r, byte(100));
    else gira(r, byte(-100));
  }
}

// Gira o robo r no proprio eixo na velocidade v
// v > 0 : gira horário
// v < 0 : gira anti horário
void gira(Robo r, byte v) {
  r.velE = v;
  r.velD = byte(-v);
}

// Método de controle baseado no Craig Reynolds
void arrive(Robo r) {
  // Vetor velocidade desejada
  PVector desVel = PVector.sub(r.pos, r.obj);
  // A velocidade é proporcional à distancia até o objetivo
  float distance = desVel.mag();
  if(distance < 100) {
    float m = map(distance, 0, 100, 0, r.velMax);
    desVel.setMag(m);
  }
  else desVel.setMag(r.velMax);
  
  // Vetor força de steering
  PVector steering = PVector.sub(desVel, r.vel);
  //steering.limit(100);
}

// Método de controle baseado no Craig Reynolds
void seek(Robo r) {
  // Vetor velocidade desejada
  PVector desVel = PVector.sub(r.pos, r.obj);
  desVel.normalize();
  desVel = desVel.mult(r.velMax);
  // Vetor força de steering
  PVector steering = PVector.sub(desVel, r.vel);
  
}
