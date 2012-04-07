#include <iostream>
#include <math.h>
#include <unistd.h>
#include <CoreFoundation/CoreFoundation.h>

#include "oscpkt/oscpkt.hh"
#include "oscpkt/udp.hh"

using namespace oscpkt;

const short DEFAULT_PORT_NUM = 9109;

typedef struct { float x,y; } mtPoint;
typedef struct { mtPoint pos,vel; } mtReadout;

typedef struct {
	int frame;
	double timestamp;
	int identifier, state, foo3, foo4;
	mtReadout normalized;
	float size;
	int zero1;
	float angle, majorAxis, minorAxis; // ellipsoid
	mtReadout mm;
	int zero2[2];
	float unk2;
} Finger;

typedef void *MTDeviceRef;
typedef int (*MTContactCallbackFunction)(int,Finger*,int,double,int);

#ifdef __cplusplus
extern "C" {
#endif

MTDeviceRef MTDeviceCreateDefault();
void MTRegisterContactFrameCallback(MTDeviceRef, MTContactCallbackFunction);
void MTDeviceStart(MTDeviceRef, int); // thanks comex

#ifdef __cplusplus
}
#endif


UdpSocket sock;
PacketWriter pw;
int verbosity;

int callback(int device, Finger *data, int nFingers, double timestamp, int frame) {
	for (int i=0; i<nFingers; i++) {
		Finger *f = &data[i];
		
		
		Message msg("/finger");
		msg.pushInt32(f->identifier);
		msg.pushFloat(f->normalized.pos.x);
		msg.pushFloat(f->normalized.pos.y);

		if (verbosity > 1) {
			msg.pushFloat(f->normalized.vel.x);
			msg.pushFloat(f->normalized.vel.y);
			msg.pushFloat(f->angle * 90.0f / atan2(1, 0));
			msg.pushFloat(f->majorAxis);
			msg.pushFloat(f->minorAxis);
			msg.pushInt32(f->frame);
			msg.pushInt32(f->state);
			msg.pushFloat(f->size);
		}
		
		pw.init().addMessage(msg);
		sock.sendPacket(pw.packetData(), pw.packetSize());
		
		if (verbosity > 2) {
			printf("Frame %7d: Angle %6.2f, ellipse %6.3f x%6.3f; "
			   "position (%6.3f,%6.3f) vel (%6.3f,%6.3f) "
			   "ID %d, state %d [%d %d?] size %6.3f, %6.3f?\n",
			   f->frame,
			   f->angle * 90 / atan2(1,0),
			   f->majorAxis,
			   f->minorAxis,
			   f->normalized.pos.x,
			   f->normalized.pos.y,
			   f->normalized.vel.x,
			   f->normalized.vel.y,
			   f->identifier, f->state, f->foo3, f->foo4,
			   f->size, f->unk2);
		}
	}
	
	return 0;
}

int main(int argc, char** argv) {
	
	short portNum = DEFAULT_PORT_NUM;
	verbosity = 1;
	
	if (argc > 1) {
		for (int i = 1; i < argc;) {
			if (strcmp(argv[i], "-h") == 0) {
				std::cerr << "Usage: sendMultiTouches [-p PORTNUM] [-v VERBOSITY]\n" <<
				"PORTNUM is the port on which sendMultiTouches will send OSC packets.\n" <<
				"VERBOSITY is the level of verbosity;\n" <<
				"\t1: Only send finger id and position\n" <<
				"\t2: Send finger id, position, velocity, angle, axes, frame, state, and size\n" <<
				"\t3: Send the above, but also log everything to stdout\n" << std::endl;
				return 0;
			}
			else if (strcmp(argv[i], "-v") == 0) {
				if (i + 1 < argc) {
					verbosity = atoi(argv[i + 1]);
					i += 2;
				}
				else {
					std::cerr << "Error: must specify the verbosity after supplying the -v flag." << std::endl;
					return 1;
				}
			}
			else if (strcmp(argv[i], "-p") == 0) {
				if (i + 1 < argc) {
					portNum = atoi(argv[i + 1]);
					i += 2;
				}
				else {
					std::cout << "Error: specify the port number after supplying the -p flag." << std::endl;
					return 1;
				}
			}
		}
	}
	
	std::cout << "Sending messages on port " << portNum << ", verbosity level: " << verbosity << std::endl;
	
	sock.connectTo("localhost", portNum);
	if (!sock.isOk()) {
		std::cout << "Error opening port " << portNum << ": " << sock.errorMessage() << "\n";
		return 1;
	}
	
	pw.init();
	
	MTDeviceRef dev = MTDeviceCreateDefault();
	MTRegisterContactFrameCallback(dev, callback);
	MTDeviceStart(dev, 0);
	printf("Ctrl-C to abort\n");
	sleep(-1);
	return 0;
}

