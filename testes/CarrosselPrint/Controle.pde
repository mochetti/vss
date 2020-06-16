// Tolerancia de diferença entre os angulos
float dAng = 15;

void controle(Robo r) {
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
