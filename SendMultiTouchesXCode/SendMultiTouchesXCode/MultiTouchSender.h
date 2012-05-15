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

typedef struct {
    Finger* finger;
    int sequenceId;
} MultiTouchFinger;

static const double RELEASE_TIME = 0.05;
static const float ANGLE_DAMPING = 0.9f;
static const double FIND_TIME = 0.8f;

static const int MAX_FINGERS = 10;

@interface MultiTouchSender : NSObject

typedef void *MTDeviceRef;
typedef int (*MTContactCallbackFunction)(int,Finger*,int,double,int);

int callback(int device, Finger *data, int nFingers, double timestamp, int frame);
- (void) setup: (const char*) targetAddr : (short) targetPort : (int) verboseLevel;
- (void) configureConnection: (const char*) targetAddr : (short) targetPort;
- (void*) getFingerArray;

@end
