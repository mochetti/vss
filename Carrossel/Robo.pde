// Classe que gerencia os robos

class Robo {

  //Variaveis de controle de estado para cada estratégia:
  int estagio = 0;  //Variável que para cada estratégia vai ditar o que no estágio atual deveria acontecer
  //Estratégia 0:
  /*
    estagio:
   -0 vai até o y da bola (limitando limites superior e inferior)
   -1 se a bola estiver próxima, gira até a bola distanciar
   */
  //Estratégia 1: com seus estados iniciais já setados
  /*
   estagio:
   -0: vai até a sombra da bola
   -1 vai até a posição projetada da sombra
   -2´ir até a sombra da bola, tendo passado pelo estágio 1
   -3: Vai até a bola
   Aqui percebemos que existem 2 caminhos lógicos que o robô poderá seguir:
   0 -> 3; OU  Nesta o robô chega direto na sombra da bola e vai direto até ela
   0 -> 1 -> 2 -> 3;  Enquanto nesta o robô vai até a sombra original, encontra a bola no caminho e passa a percorrer atrás da sombra projetada. Chega na projetada e vai até
   a original. Chega na original e vai até a bola.
   */

  PVector pos = new PVector(), posAnt, vel, obj, objAnt;
  float ang = 0, angAnt = 0, angObj = -1;
  // Armazena o erro no valor do angulo do frame anterior
  // É propriedade da classe robo para evitar multiplas variaveis globais
  float dAngAnt = 0;
  float velD, velE, dAntiga, eAntiga;
  // Velocidades limite do robo (0 - 64)
  int velMax = 20;
  int velMin = -10;
  float velEmin = 2.5;
  float velDmin = 2.5;
  // coeficiente proporcional para o controle
  float kP;
  int v = 0;
  int index;
  PShape corpo;
  float tolAng;
  // 0 = verde -> vermelho
  // 1 = verde <- vermelho
  boolean frente = false;
  boolean girando = false;

  Robo(int n) {
    index = n;
    if (n >= 0) {
      ang = getAng();
      pos = getPos();
      atualiza();
    }
    vel = new PVector();
    obj = new PVector();  //
  }

  Robo(int n, int b) {
    index = n;
    if (n >= 0) {
      ang = getAng();
      pos = getPos();
      vel = new PVector();
      obj = new PVector();
      atualiza();
      estagio = b;
    }
  }

  Robo(Robo r) {
    pos = r.pos;
    vel = r.vel;
    ang = r.ang;
    frente = r.frente;
    index = r.index;
    estagio = r.estagio;
    angAnt = r.angAnt;
    girando = r.girando;
    obj = r.obj;
    objAnt = r.objAnt;
    atualiza();
  }

  // construtor usado pelo simulador
  Robo(float x, float y, int n) {
    pos.x = x;
    pos.y = y;
    index = n;
    vel = new PVector();
  }

  Robo clone() {
    Robo r = new Robo(this);
    return r;
  }

  // define o angulo do robo
  // criado para a simulacao - cuidado ao usar
  void setAng(float income) {
    ang = income;
  }

  // define como vetor velocidade
  void setVel(PVector income) {
    vel = income;
  }
  // define a velocidade das rodas
  void setVel(float vE, float vD) {
    // Verifica se as velocidades estão dentro dos limites estabelecidos
    // O ajuste para velocidade negativa é feito direto na serial
    if (vE > velMax && !girando) vE = velMax;
    else if (vE < -velMax && !girando) vE = -velMax;
    if (vD > velMax && !girando) vD = velMax;
    else if (vD < -velMax && !girando) vD = -velMax;
    velE = vE;
    velD = vD;
    

    if (frente) {
      float aux = velE;
      velE = -velD;
      velD = -aux;
    }
  }

  // Calcula o centro real do robo
  PVector getPos() {
    PVector centro = new PVector();
    PVector posVerde = new PVector(blobs.get(index+1).center().x, blobs.get(index+1).center().y);
    PVector posVermelho = new PVector(blobs.get(index+4).center().x, blobs.get(index+4).center().y);
    switch(index) {
      //Tamanhos iguais
    case 0:  // o centro é a media aritmética dos centros dos blobs
      centro.x = (posVerde.x + posVermelho.x) / 2;
      centro.y = (posVerde.y + posVermelho.y) / 2;
      break;
      //Vermelho Maior
    case 1: 
      float angulo1 = ang;
      if (frente) angulo1 -= PI;
      //println("ROBO: angulo = " + degrees(angulo));
      float distCentros1 = dist(posVerde.x, posVerde.y, posVermelho.x, posVermelho.y);
      distCentros1 /= 2;
      centro.x = (posVermelho.x + cos(angulo1)*distCentros1);
      centro.y = (posVermelho.y + sin(angulo1)*distCentros1);
      break;
      //Verde Maior
    case 2:  // o centro é deslocado (esse cálculo é aproximado mas muito bom)
      float angulo2 = ang;
      if (frente) angulo2 -= PI;
      //println("ROBO: angulo = " + degrees(angulo));
      float distCentros2 = dist(posVerde.x, posVerde.y, posVermelho.x, posVermelho.y);
      distCentros2 /= 2;
      centro.x = (posVerde.x + cos(angulo2)*distCentros2);
      centro.y = (posVerde.y + sin(angulo2)*distCentros2);
      break;
    }

    posAnt = new PVector(pos.x, pos.y);
    pos = new PVector(centro.x, centro.y);
    pushMatrix();
    translate(pos.x, pos.y);
    fill(255);
    text(index, 15, 15);
    popMatrix();
    return centro;
  }

  // Define posicao do objetivo como vetor
  void setObj(PVector income) {
    if (income.x > shapeCampo.getVertex(1).x) income.x = shapeCampo.getVertex(1).x;
    if (income.x < shapeCampo.getVertex(0).x) income.x = shapeCampo.getVertex(0).x;
    if (income.y > shapeCampo.getVertex(2).y) income.y = shapeCampo.getVertex(2).y;
    if (income.y < shapeCampo.getVertex(0).y) income.y = shapeCampo.getVertex(0).y;
    obj = income;
  }

  // Define posicao do objetivo como coordenadas
  void setObj(float x, float y) {
    if (x > shapeCampo.getVertex(1).x) x = shapeCampo.getVertex(1).x;
    if (x < shapeCampo.getVertex(0).x) x = shapeCampo.getVertex(0).x;
    if (y > shapeCampo.getVertex(2).y) y = shapeCampo.getVertex(2).y;
    if (y < shapeCampo.getVertex(0).y) y = shapeCampo.getVertex(0).y;
    obj.x = x;
    obj.y = y;
  }

  void setEstrategia(int n) {

    //println("Robô: " + index);
    estrategia(this, n);
  }

  // Retorna um vetor correspondente à direçao do robo
  PVector getDir() {
    PVector dir = new PVector();
    dir.x = cos(ang);
    dir.y = sin(ang);
    return dir;
  }

  // Retorna o angulo do robo
  float getAng() {

    switch(index) {
    case 0:    // Cores iguais
      ang = atan2(- blobs.get(1).center().y + blobs.get(4).center().y, - blobs.get(1).center().x + blobs.get(4).center().x);
      //line(blobs.get(1).center().x, blobs.get(1).center().y, blobs.get(4).center().x, blobs.get(4).center().y);
      break;

      //Angulo do robô 1 é PI defasado
    case 1:    // Vermelho maior
      ang = atan2(- blobs.get(5).center().y + blobs.get(2).center().y, - blobs.get(5).center().x + blobs.get(2).center().x);
      ang -= atan(0.5);
      //line(blobs.get(2).center().x, blobs.get(2).center().y, blobs.get(5).center().x, blobs.get(5).center().y);
      break;

    case 2:    // Verde maior
      ang = atan2(- blobs.get(3).center().y + blobs.get(6).center().y, - blobs.get(3).center().x + blobs.get(6).center().x);
      ang -= atan(0.5);
      //line(blobs.get(3).center().x, blobs.get(3).center().y, blobs.get(6).center().x, blobs.get(6).center().y);
      break;
    }
    if (frente) ang += PI;

    while (ang > 2*PI) ang -= 2*PI;
    while (ang < 0) ang += 2*PI;

    //println("ROBO: " + index + " ang = " + degrees(ang));

    return ang;
  }

  // Verifica se é necessário mudar a frente do robo (só tem efeito se chamado depois de definir os objetivos de cada robo)
  void frente() {
    if (obj.mag() != 0) {
      PVector robObj = new PVector();
      robObj = PVector.sub(obj, pos);
      float dAng = PVector.angleBetween(robObj, getDir());
      if (dAng > 7*PI/10) {
        frente = !frente;
        //println("ROBO: dAng do robo " + index + " = " + degrees(dAng));
      }
      if (inputVideo == 2) robosSimulados.get(index).frente = frente;

      getAng();
      debugAng();

      //println("ROBO: robo " + index + " esta com a frente trocada");
    }
  }

  // atualiza alguns parametros do robo
  void atualiza() {

    getPos();
    getAng();

    objAnt = obj;

    switch(index) {
    case 0:
      velEmin = 3;
      velDmin = 3;
      kP = 0.1;
      tolAng = 18;
      break;
    case 1:
      velEmin = 3;
      velDmin = 3;
      kP = 0.1;     
      tolAng = 10;
      break;
    case 2:
      velEmin = 3;
      velDmin = 3;
      kP = 0.1;  
      tolAng = 10;
      break;
    default:
      velEmin = 2.5;
      velDmin = 2.5;
      kP = 0.3;
      break;
    }
  }

  // Funcoes de debug
  void debugAng() {
    //println("ROBO: " + index + "  ang = " + degrees(ang));
    arrow(pos.x, pos.y, pos.x + 50*cos(ang), pos.y + 50*sin(ang));
  }

  void debugObj() {
    //println(obj);
    arrow(pos.x, pos.y, obj.x, obj.y);
    fill(255, 0, 0);
    ellipse(obj.x, obj.y, 5, 5);
  }

  // desenha o robo no simulador
  void simula() {
    // lado do robo em pixels
    int lado = 35;
    rectMode(CORNER);
    // PShape
    corpo = createShape(GROUP);
    PShape vermelho = createShape();
    PShape azul = createShape();
    PShape fundo = createShape();
    fundo.beginShape();
    fundo.vertex(-lado/2, -lado/2);
    fundo.vertex(lado/2, -lado/2);
    fundo.vertex(lado/2, lado/2);
    fundo.vertex(-lado/2, lado/2);
    fundo.endShape(CLOSE);


    switch(index) {
      // goleiro
    case 0:
      vermelho = createShape(RECT, -lado/2, -lado/2, lado, lado/2);
      azul = createShape(RECT, -lado/2, 0, lado, lado/2);
      break;

      // zagueiro (metade vermelho 1/4 verde)
    case 1:
      vermelho = createShape(RECT, -lado/2, 0, lado, lado/2);
      azul = createShape(RECT, 0, -lado/2, lado/2, lado/2);
      break;

      // atacante (metade verde 1/4 vermelho)
    case 2:
      vermelho = createShape(RECT, 0, -lado/2, lado/2, lado/2);
      azul = createShape(RECT, -lado/2, 0, lado, lado/2);
      break;
    }

    vermelho.setFill(color(238, 96, 119));
    azul.setFill(color(16, 148, 238));
    fundo.setFill(color(0));
    corpo.addChild(fundo);
    corpo.addChild(azul);
    corpo.addChild(vermelho);
  }

  void display() {
    pushMatrix();
    corpo.translate(pos.x, pos.y);
    corpo.rotate(ang + PI/2);
    shape(corpo);
    popMatrix();
  }

  boolean isBolaEntre(PVector objetivo) {  

    float distRoboObj = distSq(pos, objetivo);
    float distRoboBola = distSq(pos, bola);
    //println(distRoboObj);
    //println(distRoboBola);

    if (isNear(bola, 80) && distRoboObj > distRoboBola) {


      return true;
    } 
    return false;
  }

  boolean isNear(PVector alvo, int tolerancia) {
    int raio = tolerancia;
    noFill();
    ellipse(pos.x, pos.y, raio, raio);

    if (distSq(pos, alvo) < tolerancia*tolerancia) {
      //println("ROBO: Robo " + index + " isNear = true");
      return true;
    }
    //println("ROBO: Robo " + index + " isNear = false");
    return false;
  }
}
