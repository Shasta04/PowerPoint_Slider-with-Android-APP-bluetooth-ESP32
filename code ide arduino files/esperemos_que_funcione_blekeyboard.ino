#include <BluetoothSerial.h>

BluetoothSerial SerialBT;

void setup() {
  Serial.begin(115200);
  SerialBT.begin("ControlPPT");  // Nombre Bluetooth
  
  pinMode(2, OUTPUT);  // LED interno (opcional)
  Serial.println("ESP32 Listo - Control PPT");
}

void loop() {
  // Recibir de App Inventor
  if (SerialBT.available()) {
    char cmd = SerialBT.read();
    Serial.write(cmd);  // Enviar a PC por USB
    digitalWrite(2, HIGH);  // LED on
    delay(100);
    digitalWrite(2, LOW);   // LED off
  }
  delay(10);
}
