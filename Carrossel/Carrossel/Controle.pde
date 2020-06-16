// Tolerancia de diferença entre os angulos em graus
float tolAng = 10;
// Velocidade inicial de giro
//byte velGiro = 30;
// Velocidade inicial para andar reto
byte velViagem = 30;

// Alinha e anda
void alinhaAnda(Robo r) {

  // Verifica se a bola está perto
  //if (distSq(r.getPos(), bola) < 15*15) {
  //  gira(r, true);
  //  return;
  //}

  if (r.angObj != -1) {
    // Verifica se está dentro da tolerancia
    if (abs(r.ang - r.angObj) < radians(tolAng)) r.setVel(0, 0);
    // Se não estiver, alinha
    else alinhaP(r, r.angObj);
    return;
  }
  if (r.obj == r.pos) return;
  // Vetor robo -> obj
  PVector robObj = new PVector();
  robObj = PVector.sub(r.obj, r.pos);
  float ang = atan2(robObj.y, robObj.x);
  float dAng = PVector.angleBetween(robObj, r.getDir());

  // Angulo do robo

  //println("CONTROLE: ang obj = " + degrees(ang));
  //println("CONTROLE: ang robo = " + degrees(r.ang));
  //println("CONTROLE: dAng = " + degrees(dAng));
  if (abs(dAng) < radians(r.tolAng)) {
    // Anda reto

    //println("CONTROLE: Robo " + r.index + " Anda reto");
    //r.velE = r.velEmin;
    //r.velD = r.velDmin;
    r.setVel(r.velMax, r.velMax);
  } else {
    // Alinha
    alinhaP(r, ang);
  }
}

// Alinha em velocidades constantes
void alinha(Robo r, float ang) {

  // Angulo do robo
  float angRobo = r.ang;

  if (ang - angRobo > 0 && ang - angRobo < PI) {
    //println("CONTROLE: Robo " + r.index + " Gira horário");
    gira(r, true);
  } else if (ang - angRobo > PI) {
    //println("CONTROLE: Robo " + r.index + " Gira anti horário");
    gira(r, false);
  } else if (angRobo - ang > 0 && angRobo - ang < PI) {
    //println("CONTROLE: Robo " + r.index + " Gira anti horário");
    gira(r, false);
  } else if (angRobo - ang > PI) {
    //println("CONTROLE: Robo " + r.index + " Gira horário");
    gira(r, true);
  }
}

//True é horario, e false é antihorário
void chutaGirando(Robo r) {

  r.setVel(50, -40);
  
}

// Alinha proporcional à distancia do angulo desejado
void alinhaP(Robo r, float ang) {
  // Constante de proporcionalidade
  // Angulo do robo
  float angRobo = r.ang;
  float dAng = ang - angRobo;

  while (dAng < -7*PI/10) dAng += 2*PI;
  while (dAng > 7*PI/10) dAng -= 2*PI;

  //println("dAng = " + degrees(dAng));

  float dVelE = abs(dAng)*10/(7*PI);
  dVelE = map(dVelE, 0, 1, 0, 63 - r.velEmin);

  float dVelD = abs(dAng)*10/(7*PI);
  dVelD = map(dVelD, 0, 1, 0, 63 - r.velDmin);

  //if (r.index == 0) println("dVelE = " + dVelE);

  if (sin(dAng) > 0) {
    //println("CONTROLE: Robo " + r.index + " Gira horário");
    //if (r.index == 0) {
    //  print("ANG ROBO: " + degrees(angRobo) + " angObj: " + degrees(ang) + " velEmin: " + r.velEmin + " dVel: " + r.kP*abs(dAng)*r.velEmin);
    //  println("CONTROLE: Robo " + r.index + " KP: " + r.kP + " dAng: " + degrees(dAng));
    //}

    r.setVel(r.velEmin+r.kP*dVelE, -r.velDmin-r.kP*dVelD);
    //r.setVel(r.kP*abs(dAng)*r.velEmin, r.kP*-abs(dAng)*r.velDmin);
  } else if (sin(dAng) < 0) {
    //println("CONTROLE: Robo " + r.index + " Gira anti horário");
    //println("CONTROLE: Robo " + r.index + " KP: " + r.kP + " dAng: " + dAng);
    r.setVel(-r.velEmin-r.kP*dVelE, r.velDmin+r.kP*dVelD);
    //r.setVel(r.kP*abs(dAng)*r.velEmin, r.kP*-abs(dAng)*r.velDmin);
  }
}

// Alinha e anda e alinha
void alinhaGoleiro(Robo r) {
  // Verifica se a bola está perto
  if (distSq(r.pos, bola) < 15*15) {
    gira(r, true);
    return;
  }

  if (r.angObj != -1) {
    // Verifica se está dentro da tolerancia
    if (abs(r.ang - r.angObj) < radians(tolAng)) r.setVel(0, 0);
    // Se não estiver, alinha
    else alinhaP(r, r.angObj);
    return;
  }
  // Vetor robo -> obj
  PVector robObj = new PVector();
  robObj = PVector.sub(r.obj, r.pos);
  float ang = atan2(robObj.y, robObj.x);
  float dAng = PVector.angleBetween(robObj, r.getDir());
  //if(dAng > PI) dAng = 2*PI - dAng;
  // Angulo do robo
  float angRobo = r.ang;
  //println("CONTROLE: ang obj = " + degrees(ang));
  //println("CONTROLE: ang robo = " + degrees(r.ang));
  //println("CONTROLE: dAng = " + degrees(dAng));

  if (dAng < radians(tolAng)) {
    // Anda reto
    //println("CONTROLE: Robo " + r.index + " Anda reto");
    r.setVel(r.velMax, r.velMax);
  } else {
    // Alinha
    alinhaP(r, ang);
  }
}

// Verifica se o robo já venceu a inércia
//boolean inercia(Robo r) {
//  println("CONTROLE: tempo = " + tempo + "  antes = " + antes);
//  if(tempo - antes < 200) {
//    println("CONTROLE: ajuste de inercia");
//    r.setVel(r.velMax, 0);
//    return true;
//  }
//  // Controle para nao vencer a inercia toda vez
//  // Só chama inercia() quando o comando anterior era de giro
//  andaReto = true;
//  antes = tempo;
//  r.velE = r.eAntiga;
//  r.velD = r.dAntiga;
//  return false;
//}

// Gira o robo r no proprio eixo na velocidade velGiro
// sentido true : gira horário
// sentido false : gira anti horário
void gira(Robo r, boolean sentido) {
  if (sentido) {
    r.setVel(r.velMax, -r.velMax);
  } else {
    r.setVel(-r.velMax, r.velMax);
  }
}

// Alinha andando
void alinhandando(Robo r) {
  // O desafio maior tem sido vencer a inercia das rodas (que não é a mesma para as duas)
  // A ideia é começar numa velocidade alta independente da direção do robo em relação ao objetivo

  // Velocidades atuais do robo
  float velE = r.velE;
  float velD = r.velD;

  // Velocidades mínima e máxima
  int velMin = 30;
  int velMax = 50;

  // Define o lado de menor angulo
  int giraHorario = 1;

  // Angulo do objetivo
  float angObj = atan2(r.obj.y, r.obj.x) - PI;
  float dAng = r.ang - angObj;

  //println("CONTROLE: Angulo robObj = " + degrees(angObj));
  //println("CONTROLE: Angulo robo = " + degrees(r.ang));
  //println("CONTROLE: dAng = " + degrees(dAng));

  /*// Verifica a inercia por distancia
   //if((velE == 0 && velD == 0) || (velE == 0 && velD == 0)) {
   if(abs(r.pos.x - r.posAnt.x) + abs(r.pos.y - r.posAnt.y) < 5) {
   // Vence a inercia
   println("CONTROLE: Vencendo a inércia");
   r.setVel(velMax, velMax);
   return;
   }
   */
  // Verifica a inercia por contagem de quadros
  //if(contagemAlinhandando < 50) {
  //  // Vence a inercia
  //  println("CONTROLE: Vencendo a inércia");
  //  r.setVel(0, velMax);
  //  contagemAlinhandando++;
  //  return;
  //}

  // Já estamos alinhando
  // PD
  float kp = 1, kd = 10;
  // Se ao inves de ler o dt entre dois frames, ele for constante, a variacao do ang pro angAnt é maior
  double dt = 50;
  if (tempo - antes < dt) {
    println("");
    println("");
    return;
  }
  antes = tempo;
  // A saída é a soma dos fatores P e D
  double p = kp * dAng;
  double d = kd * (dAng - r.dAngAnt) / dt;
  double out = p + d;

  println("CONTROLE: P = " + p + "  D = " + d);
  println("CONTROLE: out = " + out);

  if (dAng > PI || dAng < -PI) giraHorario = -1;
  else giraHorario = 1;
  velE -= out * giraHorario;
  velD += out * giraHorario;

  // Atribui as velocidades ao robo
  r.setVel(velE, velD);
  // Atualiza o erro antigo para o próximo frame
  r.dAngAnt = dAng;
}

// Método de controle baseado no Craig Reynolds
void arrive(Robo r) {
  // Vetor velocidade desejada
  PVector desVel = PVector.sub(r.pos, r.obj);
  // A velocidade é proporcional à distancia até o objetivo
  float distance = desVel.mag();
  if (distance < 100) {
    float m = map(distance, 0, 100, 0, r.velMax);
    desVel.setMag(m);
  } else desVel.setMag(r.velMax);

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

// Se a esquerda já foi configurada
boolean configEsq = false;

// Funcao que define alguns parametros do robo a partir de testes empiricos
void configRobo(Robo r) {
  // Descobre as velocidades minimas para cada roda
  // Configura o angulo antigo pela primeira vez
  if (r.angAnt == 0) r.angAnt = r.ang;
  // Acompanhamos a quanto tempo tá rolando a configuracao
  double agora = millis();
  if (agora - tempo > 2000) r.angAnt = r.ang;
  // Diferença entre o angulo atual e o inicial
  float dAng = abs(r.ang - r.angAnt);
  println("CONTROLE: angAnt = " + degrees(r.angAnt));
  println("CONTROLE: dAng = " + degrees(dAng));
  // Diferença mínima do angulo atual (em graus) para o inicial para configurar movimento
  int dAngMin = 5;
  // Taxa de incremento das velocidades por frame
  float taxaVel = 0.1;

  if (configEsq) {
    // Configura a direita depois
    if (dAng > radians(dAngMin)) {
      r.angAnt = r.ang;
      println("CONTROLE: Velocidades definidas para o Robo " + r.index);
      println("CONTROLE: vEsq = " + r.velE + "  vDir = " + r.velD);
      //configRobo = false;
    } else {
      // Incrementa velD
      if (r.velD <= 63) r.velD += taxaVel;
      println("CONTROLE: vDir = " + r.velD);
    }
  } else {
    // Configura a esquerda primeiro
    if (dAng > radians(dAngMin)) {
      r.angAnt = r.ang;
      configEsq = true;
      return;
    } else {
      // Incrementa velE
      if (r.velE <= 63) r.velE += taxaVel;
      println("CONTROLE: vEsq = " + r.velE);
    }
  }

  enviar();
}

// Controle pelo teclado do pc
void gameplay(Robo r) {
  if (!keyPressed) r.setVel(0, 0);
  //else if (key == CODED) {
  if (key == 'w') r.setVel(r.velEmin, r.velDmin);
  else if (key == 's') r.setVel(-r.velEmin, -r.velDmin);
  else if (key == 'a') gira(r, false);
  else if (key == 'D') gira(r, true);
  //}
}
