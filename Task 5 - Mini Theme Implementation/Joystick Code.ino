#include <SPI.h>
#include <RF24.h>

RF24 radio(10, 9); // CE, CSN pins
const byte address = 5;

const int joyXPin = A1; // Analog pin for X-axis of joystick
const int joyYPin = A2; // Analog pin for Y-axis of joystick
const int swPin = 7 ;    // Digital pin for the switch



void setup() {
  Serial.begin(9600);
  radio.begin();
  radio.openWritingPipe(address);
  radio.setDataRate(RF24_2MBPS);
  radio.setPALevel(RF24_PA_MIN);
  pinMode(swPin, INPUT_PULLUP);
}

void loop() {
  char command =  getCommand();
  Serial.println("Controller Command: " + String(command));
  radio.write(&command, sizeof(command));
  delay(60); // Adjust as needed
}

char getCommand() {
  int joyX = analogRead(joyXPin);
  int joyY = analogRead(joyYPin);
  int swState = digitalRead(swPin);

  // Add dead zone to joystick values to prevent small variations
  if (abs(joyX - 512) < 20){
    joyX = 512;
  }

  if (abs(joyY - 512) < 20){
    joyY = 512;
  }

  // Map joystick values to commands
  if (joyX < 400){
    return 'F'; // Left
  } else if (joyX > 600){
    return 'B'; // Right
  } else if (joyY < 400) {
    return 'R'; // Backward
  } else if (joyY > 600) {
    return 'L'; // Forward
  } else if (swState == LOW){
    delay(120);
    return 'X'; 
  } else {
    return 'S'; // Stop
  }
}
