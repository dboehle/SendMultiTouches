//
//  MultiTouchSender.h
//  SendMultiTouchesXCode
//
//  Created by Duncan Boehle on 4/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

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

static const double RELEASE_TIME = 0.05;

@interface MultiTouchSender : NSObject

typedef void *MTDeviceRef;
typedef int (*MTContactCallbackFunction)(int,Finger*,int,double,int);

int callback(int device, Finger *data, int nFingers, double timestamp, int frame);
- (void) setup: (const char*) targetAddr : (short) targetPort : (int) verboseLevel;
- (void) configureConnection: (const char*) targetAddr : (short) targetPort;
- (void*) getDictPtr;

@end
