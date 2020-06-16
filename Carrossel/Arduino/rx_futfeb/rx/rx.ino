/* CÓDIGO ARDUINO DOS ROBÔS QUE RECEBEM AS INFORMAÇÕES DO RÁDIO. */
#include "config.h"

/* ------------ Declarações Relacionadas ao Robo que terá este código gravodo ----------- */
/* Define qual robo é esse (valores possíveis: 0, 1 ou 2) */
const byte NUM_ROBO = 1;

/* Somamos 1 no inicio pois o primeiro elemento do buffer é fixo, nomalmente 0x80. */
const int INDEX_RODA_ESQ = 1 + 2 * NUM_ROBO; /* index da roda esquerda no array rxBuffer. */
const int INDEX_RODA_DIR = 2 + 2 * NUM_ROBO; /* index da roda direita no array rxBuffer. */

// Controle do tempo
unsigned long tempo = 0;

/* ------------ Declarações Relacionadas aos motores ----------- */
// 5 9 10 7 8 6
#define PWM_MOTOR_ESQ 5
#define DIRECAO_PWM_MOTOR_ESQ_A 9
#define DIRECAO_PWM_MOTOR_ESQ_B 10
#define DIRECAO_PWM_MOTOR_DIR_A 7
#define DIRECAO_PWM_MOTOR_DIR_B 8
#define PWM_MOTOR_DIR 6
int velPWMEsq, velPWMDir;

/* ------------ Declarações Relacionadas aos Pinos do Rádio ----------- */
#define RADIO_ENABLE 14 /* O pino ligado ao Chip Enable no módulo do rádio // 14 caso seja FUTFEB */  
#define RADIO_SELECT 15 /* O pino ligado ao Chip Select no módulo do rádio // 15 caso seja FUTFEB*/  

RF24 radio(RADIO_ENABLE, RADIO_SELECT);
byte rxBuffer[Config::BUFFER_SIZE]; /* Buffer usado para armazenar os bytes recebidos através do rádio. */

void setup() {
  // pino 4 por conta do enable da ponte
  pinMode(4, OUTPUT);
  digitalWrite(4, HIGH);
  pinMode(PWM_MOTOR_ESQ, OUTPUT);
  pinMode(DIRECAO_PWM_MOTOR_ESQ_A, OUTPUT);
  pinMode(DIRECAO_PWM_MOTOR_ESQ_B, OUTPUT);
  pinMode(DIRECAO_PWM_MOTOR_DIR_A, OUTPUT);
  pinMode(DIRECAO_PWM_MOTOR_DIR_B, OUTPUT);
  pinMode(PWM_MOTOR_DIR, OUTPUT);

  Serial.begin(Config::SERIAL_BIT_RATE);
  radio.begin();
  radio.setChannel(Config::CANAL);             //canal deve ser o mesmo de transmissão
  radio.setPALevel(RF24_PA_LOW);      //potência do módulo em baixa, para maiores distâncias aumentar a potência
  radio.openReadingPipe(Config::IND_PIPE_LEITURA, Config::PIPE_CHAVE); //abertura do tubo de leitura
  radio.startListening();         //garantir que o rádio é o receptor

}

void loop() {
  // Rotina do receptor
  if (radio.available()) {
    Serial.println("Recebemos algo");
    /* lendo o buffer do rádio */
    radio.read(&rxBuffer, sizeof(rxBuffer));
    
    ///* BEGIN DEBUG
    for (int i = 0; i < Config::BUFFER_SIZE; i++){
      Serial.print(rxBuffer[i]);
    }
    Serial.println("");
    //END DEBUG */
    if(rxBuffer[0] == Config::CARACTERE_INICIAL) {
      Serial.println("Chave correta");
      tempo = millis();
      andar(rxBuffer[INDEX_RODA_ESQ], rxBuffer[INDEX_RODA_DIR]);
    }
    else {
      // Só considera desconectado se ficar 1s sem receber dados
      if(millis() - tempo < 1000) return;
      tempo = millis();
      Serial.println("Rádio Indisponível");
      andar(0, 0);
    }
  }
  else {
    // Só considera desconectado se ficar 1s sem receber dados
    if(millis() - tempo < 1000) return;
    tempo = millis();
    Serial.println("Rádio Indisponível");
    andar(0, 0);
  }
}

//rotina para atuação dos motores e movimentação do robo.
void andar(byte velEsq, byte velDir) {
  bool dirD, dirE;
  
  // verifica roda esquerda
  /* (expression) ? (true-value) : (false-value). Logo, se velEsq < 64 então dirE é LOW, do contrário (velEsq >= 64), dirE é HIGH */
  dirE = velEsq <= 64 ? LOW : HIGH;
  // verifica roda direita
  dirD = velDir <= 64 ? LOW : HIGH;

  //Mapeamento do PWM na estrutura veloDirecao
  if(dirE) velEsq = velEsq - 64;
  if(dirD) velDir = velDir - 64;
  velPWMEsq = velEsq * 4;
  velPWMDir = velDir * 4;
  // ------- Debug Serial -----------
  
  Serial.print("vel Dir: " );
  Serial.println(velPWMDir);
  Serial.print("vel Esq: ");
  Serial.println(velPWMEsq);  
  
  // Define a velocidade de cada roda
  if (velEsq!= 128){ // MOTOR ESQUERDO
      analogWrite(PWM_MOTOR_ESQ,velPWMEsq);
      if(dirE){// andando para trás
        digitalWrite(DIRECAO_PWM_MOTOR_ESQ_A, LOW);
        digitalWrite(DIRECAO_PWM_MOTOR_ESQ_B, HIGH);
      }else{ // andando para frente
        digitalWrite(DIRECAO_PWM_MOTOR_ESQ_A, HIGH);
        digitalWrite(DIRECAO_PWM_MOTOR_ESQ_B, LOW);
      }
  }else{ // PARA TUDO
    analogWrite(PWM_MOTOR_ESQ, 0);
        digitalWrite(DIRECAO_PWM_MOTOR_ESQ_A, LOW);
        digitalWrite(DIRECAO_PWM_MOTOR_ESQ_B, LOW);
  }
  
   if (velDir!= 128){ // MOTOR DIREITO
      analogWrite(PWM_MOTOR_DIR,velPWMDir);
      if(dirD){// andando para trás
        digitalWrite(DIRECAO_PWM_MOTOR_DIR_A, LOW);
        digitalWrite(DIRECAO_PWM_MOTOR_DIR_B, HIGH);
      }else{ // andando para frente
        digitalWrite(DIRECAO_PWM_MOTOR_DIR_A, HIGH);
        digitalWrite(DIRECAO_PWM_MOTOR_DIR_B, LOW);
      }
  }else{ // PARA TUDO
    analogWrite(PWM_MOTOR_DIR, 0);
        digitalWrite(DIRECAO_PWM_MOTOR_DIR_A, LOW);
        digitalWrite(DIRECAO_PWM_MOTOR_DIR_B, LOW);
  }
}
