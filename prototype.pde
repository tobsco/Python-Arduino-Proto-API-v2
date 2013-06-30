
#ifndef SERIAL_RATE
#define SERIAL_RATE         115200
#endif

#ifndef SERIAL_TIMEOUT
#define SERIAL_TIMEOUT      5
#endif

#define SELPIN 10 //Selection Pin 
#define DATAOUT 11//MOSI 
#define DATAIN  12//MISO 
#define SPICLOCK  13//Clock 
int readvalue; 

void setup() {
	Serial.begin(SERIAL_RATE);
	Serial.setTimeout(SERIAL_TIMEOUT);

	int cmd = readData();
	for (int i = 0; i < cmd; i++) {
		pinMode(readData(), OUTPUT);
	}
	//set pin modes 
	pinMode(SELPIN, OUTPUT); 
	pinMode(DATAOUT, OUTPUT); 
	pinMode(DATAIN, INPUT); 
	pinMode(SPICLOCK, OUTPUT); 
	//disable device to start with 
	digitalWrite(SELPIN,HIGH); 
	digitalWrite(DATAOUT,LOW); 
	digitalWrite(SPICLOCK,LOW); 

	Serial.begin(9600); 
}

void loop() {
	switch (readData()) {
		case 0 :
			//set digital low
			digitalWrite(readData(), LOW); break;
		case 1 :
			//set digital high
			digitalWrite(readData(), HIGH); break;
		case 2 :
			//get digital value
			Serial.println(digitalRead(readData())); break;
		case 3 :
			// set analog value
			analogWrite(readData(), readData()); break;
		case 4 :
			//read analog value
			Serial.println(analogRead(readData())); break;
		case 5 :
			//read MCP3208 value
			Serial.println(readADC(readData())); break;



		case 99:
			//just dummy to cancel the current read, needed to prevent lock 
			//when the PC side dropped the "w" that we sent
			break;
	}
}

char readData() {
	Serial.println("w");
	while(1) {
		if(Serial.available() > 0) {
			return Serial.parseInt();
		}
	}
}

int readADC(int channel) {
	int adcvalue = 0;
	byte commandbits = B11000000; //command bits - start, mode, chn (3), dont care (3)

	//allow channel selection
	commandbits|=((channel-1)<<3);

	digitalWrite(SELPIN,LOW); //Select adc
	// setup bits to be written
	for (int i=7; i>=3; i--){
		digitalWrite(DATAOUT,commandbits&1<<i);
		//cycle clock
		digitalWrite(SPICLOCK,HIGH);
		digitalWrite(SPICLOCK,LOW);    
	}

	digitalWrite(SPICLOCK,HIGH);    //ignores 2 null bits
	digitalWrite(SPICLOCK,LOW);
	digitalWrite(SPICLOCK,HIGH);  
	digitalWrite(SPICLOCK,LOW);

	//read bits from adc
	for (int i=11; i>=0; i--){
		adcvalue+=digitalRead(DATAIN)<<i;
		//cycle clock
		digitalWrite(SPICLOCK,HIGH);
		digitalWrite(SPICLOCK,LOW);
	}
	digitalWrite(SELPIN, HIGH); //turn off device
	return adcvalue;

}
