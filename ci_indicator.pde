/**
 * For now, really simple interface. Send a byte over usb to indicate the state.
 * (PASSING, FAILING, RUNNING)
 *
 **/
 
const int GREEN = 9;
const int YELLOW = 10;
const int RED = 11;

const int PASSING = 0x01;
const int FAILING = 0x02;
const int RUNNING = 0x03;

void setup() {
  Serial.begin(9600);
  Serial.println("Hello World");
}

float angle = 0.0;
float angleIncr = PI / 60.0;


void loop() {
  while(true) {
    // read from usb to see what to do
    // determine which led to pulse
    pulse(getColor());
    delay(15);
  }
}

void pulse(int pin) {
  int ledVal = round( (255*cos(angle)+255)/2.0 );
  analogWrite(pin, ledVal);
  angle = angle + angleIncr;
}

// in case we don't have any input, use the last known one
int lastColor = GREEN;

int getColor() {
  int state = getState();
 
  if (state == PASSING)
    lastColor = GREEN;
  else if (state == FAILING)
    lastColor = RED;
  else if (state == RUNNING)
    lastColor = YELLOW;

  return lastColor;
}

int lastState = PASSING;

int getState() {
  if (Serial.available()) {
    lastState = Serial.read();
  }
  
  return lastState;
}
