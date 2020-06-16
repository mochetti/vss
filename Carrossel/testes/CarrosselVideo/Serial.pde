void enviar() {
  byte[] txBuffer = {};
  txBuffer = new byte[7];
  txBuffer[0] = 127;
  for(Robo r : robos) {
    txBuffer[r.index+1] = r.velE;
    txBuffer[r.index+2] = r.velD;
  }
  for(byte data : txBuffer) myPort.write(data);
}
