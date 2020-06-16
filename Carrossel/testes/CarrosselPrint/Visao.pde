int getFrame() {    
  return ceil(mov.time() * 30) - 1;
}

int getLength() {
  return int(mov.duration() * mov.frameRate);
}

// Funcao que atribui coordenadas para os objetos
boolean track() {
  int[] corAchada = {0, 0, 0};
  int raioBusca = 15;
  
  // Verifica se há blobs salvos
  if(oldBlobs.size() > 0){
    for(Blob b : oldBlobs) {
      // Salva as coordenadas anteriores do blob
      int prevX = int(b.center().x);
      int prevY = int(b.center().y);
      // Limpa as coordenadas do blob
      b.reset();
      // Tenta buscar por perto
      int xi = prevX - raioBusca;
      if(xi < 0) xi = 0;
      int xf = prevX + raioBusca;
      if(xf > width) xf = width;
      int yi = prevY - raioBusca;
      if(yi < 0) yi = 0;
      int yf = prevY + raioBusca;
      if(yf > height) yf = height;
      if(search(xi, xf, yi, yf, b)) {
        corAchada[b.cor]++;
      }
      //else if(search(0, width, 0, height, b)) {
      //}
      else {
      println("VISÃO: O objeto não está no campo");
      }
    }
    
    // Verifica se todos os elemento foram encontrados
    boolean erro = false;
    for(int i = 0; i<quantCor.length; i++) {
      if(corAchada[i] != quantCor[i]) {
        print("VISÃO: Problema na cor ");
        println(i);
        searchNew(i);
        erro = true;
      }
    }
    if(!erro) {
      //println("VISÃO: Todos os blobs foram encontrados!");
      // Confere identidade aos objetos
      if(id()) return true;
    }
  }
  
  // Não há blobs salvos
  else{
    for(int index = 0; index < quantCor.length; index++) {
      print("VISÃO: Buscando novo blob na cor ");
      println(index);
      searchNew(index);
    }
  }
  return false;
}

float distSq(PVector v, PVector u) {
  float d = (u.x-v.x)*(u.x-v.x) + (u.y-v.y)*(u.y-v.y);
  return d;
}
float distSq(float x1, float y1, float x2, float y2) {
  float d = (x2-x1)*(x2-x1) + (y2-y1)*(y2-y1);
  return d;
}
float distSq(float x1, float y1, float z1, float x2, float y2, float z2) {
  float d = (x2-x1)*(x2-x1) + (y2-y1)*(y2-y1) +(z2-z1)*(z2-z1);
  return d;
}

// Retorna a distancia ao quadrado entre duas cores
float distColorSq(color c1, color c2) {
  
  float r1 = red(c1);
  float g1 = green(c1);
  float b1 = blue(c1);
  float r2 = red(c2);
  float g2 = green(c2);
  float b2 = blue(c2);

  // Using euclidean distance to compare colors
  return distSq(r1, g1, b1, r2, g2, b2);
}

// Checa se o blob está na área desejada
boolean search (int xi, int xf, int yi, int yf, Blob b) {
  // contagem de pixels por blob
  int count = 0;
  
  float threshold = 35;
  // Procura nas coordenadas dadas
  for (int x = xi; x < xf; x++ ) {
    for (int y = yi; y < yf; y++ ) {
      if(x >= 0 && x < mov.width && y >= 0 && y < mov.height) {
        int loc = x + y * mov.width;
        // What is current color
        color currentColor = mov.pixels[loc];

        // Compara as cores
        float dd = distColorSq(currentColor, cores[b.cor]);
         
        if (dd < threshold*threshold) {
          b.add(x, y);
          count++;
          // Debug
          //stroke(255);
          //strokeWeight(1);
          //point(x, y);
        }
      }
    }
  }
  
  // Projeta a area de busca
  //stroke(0);
  //rectMode(CORNERS);
  //rect(xi, yi, xf, yf);
    
  if(count > 10) {
    //println("VISÃO: O objeto estava próximo ao anterior");
    blobs.add(new Blob(b.clone()));
    return true;
  }
  else {
    println("VISÃO: Não encontramos o objeto nessa região");
    return false;
  }
}

// Acha novos blobs
void searchNew (int c) {
  
  float threshold = 30;
  // Procura por todo o campo
  for (int x = 0; x < width; x++ ) {
    for (int y = 0; y < height; y++ ) {
      if(x >= 0 && x < mov.width && y >= 0 && y < mov.height) {
        int loc = x + y * mov.width;
        // What is current color
        color currentColor = mov.pixels[loc];

        // Compara as cores
        float dd = distColorSq(currentColor, cores[c]);
        
        // DEBUG VERDE MALDITO
        //if(c == 2 && x < 320 && x > 300 && y < 320 && y > 300) print(dd + " ");
        
        if (dd < threshold*threshold) {
          
          // Verifica se algum elemento já foi encontrado
          if(blobs.size() > 0) {
            boolean found = false;
            for(Blob b : blobs) {
              if(b.isNear(x, y)) {
                b.add(x, y);
                found = true;
                break;
              }
            }
              if(!found) {
                println("VISÃO: Novo blob encontrado");
                Blob b = new Blob(x, y, c);
                blobs.add(b);
              }
          }
          // Este é o primeiro blob
          else {
            println("VISÃO: Novo blob encontrado");
            Blob b = new Blob(x, y, c);
            blobs.add(b);
          }
   
          // Debug
          //stroke(255);
          //strokeWeight(1);
          //point(x, y);
        }
      }
    }
  }
  //print("VISÃO: Quantidade de blobs: ");
  //println(blobs.size());
}

// Funcao que atribui identidade aos objetos
boolean id() {
  
  int raioBusca = 65;
  for(Blob b : blobs) {
    switch(b.cor) {
      // O id depende da cor do blob
      case 0:    // Laranja
        // O objeto só pode ser a bola
        b.id = 0;
      break;
      
      case 1:    // Vermelho
        // O objeto depende da quantidade de verdes ao redor
        int qVerde = 0;
        for(Blob v : blobs) {
          if(v.cor == 2 && distSq(b.center().x, b.center().y, v.center().x, v.center().y) < raioBusca*raioBusca) {
            qVerde++;
          }
        }
        if(qVerde > 0) b.id = qVerde;
        else b.id = 10;
        
        // Raio de busca por verdes
        //noFill();
        //stroke(255);
        //ellipse(b.center().x, b.center().y, raioBusca, raioBusca);
      break;
      
      case 2:    // Verde
        // O objeto depende da orientação do robo
        // Verifica qual robo
        for(Blob v : blobs) {
          // Distancia entre as tags vermelha e verde
          float distVV = dist(b.center().x, b.center().y, v.center().x, v.center().y);
          float ang, cx, cy;
          boolean achou = false, achou2 = false;
          
          if(v.cor == 1 && distVV < raioBusca) {
            switch(v.id) {
              case 1:     // Somente 1 verde
                b.id = 4;
              break;
              
              case 2:    // 2 verdes
                ang = atan2(- v.center().x + b.center().x, - v.center().y + b.center().y);
                //println("Ang = " + ang*180/PI);
                
                if(ang < 0) ang += PI;
                ang += PI/2;
                
                cx = v.center().x + distVV * cos(ang);
                cy = v.center().y + distVV * sin(ang);
                // Raio de busca por outra quina
                //noFill();
                //stroke(255);
                //ellipse(cx, cy, 15, 15);
                
                // Verifica se há outro verde onde deveria haver
                achou = false;
                for(Blob t : blobs) {
                  if(t.cor == 2 && distSq(t.center().x, t.center().y, cx, cy) < 15*15) {
                    b.id = 5;
                    achou = true;
                    //b.show(color(0,255,0));
                  }
                }
                if(!achou) {
                  b.id = 6;
                  //b.show(color(255,0,0));
                }
              break;
              
              case 3:    // 3 verdes
                ang = atan2(b.center().x - v.center().x, b.center().y - v.center().y);
                //println("Ang = " + ang*180/PI);
                if(ang > -PI/2 && ang < 0) ang -= PI/2;
                else ang += PI/2;
             
                cx = v.center().x + distVV * cos(ang);
                cy = v.center().y + distVV * sin(ang);
                
                // Raio de busca por outra quina
                //noFill();
                //stroke(255);
                //ellipse(cx, cy, 15, 15);
                
                // Verifica se há outro verde onde deveria haver
                for(Blob t : blobs) {
                  if(t.cor == 2 && distSq(t.center().x, t.center().y, cx, cy) < 15*15) {
                    // Verifica se há um terceiro verde
                    if(ang > -PI/2 && ang < 0) ang -= PI/2;
                    else ang += PI/2;
                    cx = v.center().x + distVV * cos(ang);
                    cy = v.center().y + distVV * sin(ang);
                    
                    // Raio de busca por outra quina
                    //noFill();
                    //stroke(255);
                    //ellipse(cx, cy, 15, 15);
                    
                    for(Blob u : blobs) {
                      if(u.cor == 2 && distSq(u.center().x, u.center().y, cx, cy) < 15*15) {
                        //println("id 9");
                        b.id = 9;
                        achou = true;
                      }
                      else {
                        //println("id 8");
                        b.id = 8;
                        achou2 = true;
                      }
                      if(achou) break;
                    }
                  }
                  else {
                    //println("id 7");
                    b.id = 7; 
                  }
                  if(achou || achou2) break;
                }
              break;
              
              default:
                b.id = -1;
              break;
            }
          }
        }
      default:
      break;
    }
  }
  //for(Blob b : blobs) {
  //  if(b.id >= 0) print(b.id + "  ");

  //}
  
  // Coloca em ordem crescente de id
  if(ordenar()) return true;
  return false;
}

boolean ordenar() {
  Blob newBlobs[] = new Blob[blobs.size()];
  for(int i = 0; i < newBlobs.length; i++) newBlobs[i] = new Blob();
  for(Blob b : blobs) newBlobs[b.id] = new Blob(b.clone());
  
  // Copia de volta
  blobs.clear();
  for(Blob b : newBlobs) blobs.add(new Blob(b.clone()));
  
  int[] array = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9};
  boolean correto = true;
  for(Blob b : blobs) {
    if (b.id != array[b.id]) {
      correto = false;
    }
    if (b.id == 0) rastro.add(new PVector(b.center().x, b.center().y));
  }
  if(correto) return true;
  return false;
}

// Retorna o vetor velocidade da bola, originado no centro dela
PVector velBola() {
  // Remove os rastros mais antigos
  while(rastro.size() > 15) rastro.remove(0);
  // Espera colher dados o suficiente
  if(rastro.size() < 14) return null;
  // Coordenadas
  PVector bolaAtual = new PVector(blobs.get(0).center().x, blobs.get(0).center().y);
  
  // Mostra o rastro na tela
  //for(int i = 0; i < rastro.size()-1; i++) ellipse(rastro.get(i).x, rastro.get(i).y, 15, 15);
  
  // Descobre o angulo e o modulo da bola
  float ang = 0;
  float modulo = 0;
  // Numero de frames entre duas bolas para calcular a velocidade
  int frames = 3;
  
  for(int i = 0; i < 9; i++) {
    // Começa pelo mais antigo
    PVector bolaAnt = new PVector(rastro.get(i).x, rastro.get(i).y);
    PVector bolaRec = new PVector(rastro.get(i+frames).x, rastro.get(i+frames).y);
    modulo += PVector.dist(bolaAnt, bolaRec);
    ang += atan2(bolaAtual.y - bolaAnt.y, bolaAtual.x - bolaAnt.x);
  }
  
  ang /= 9;
  modulo /= 9;
  
  PVector vel = new PVector();
  vel.x = modulo*cos(ang);
  vel.y = modulo*sin(ang);
  vel.mult(mov.frameRate / frames);
  arrow(bolaAtual.x, bolaAtual.y, PVector.add(bolaAtual, vel).x, PVector.add(bolaAtual, vel).y);

  return vel;
}

// Retorna true se a bola estiver se aproximando do ponto fornecido
boolean bolaIsAprox(PVector aqui) {
  PVector bolaAtual = new PVector(blobs.get(0).center().x, blobs.get(0).center().y);
  PVector velBola = velBola();
  // Se a distancia entre a bola futura e o ponto for maior que a distancia entre a bola atual e o ponto, a abola esta se afastando
  if(distSq(bolaAtual.x + velBola.x, bolaAtual.y + velBola.y, aqui.x, aqui.y) > distSq(bolaAtual.x, bolaAtual.y, aqui.x, aqui.y)) {
    //println("VISÃO: afastando");
    return false;
  }
  else {
    //println("VISÃO: aproximando");
    return true;
  }
}

// Funcao para desenhar uma seta
void arrow(float x1, float y1, float x2, float y2) {
  line(x1, y1, x2, y2);
  pushMatrix();
  translate(x2, y2);
  float a = atan2(x1-x2, y2-y1);
  rotate(a);
  line(0, 0, -10, -10);
  line(0, 0, 10, -10);
  popMatrix();
} 
