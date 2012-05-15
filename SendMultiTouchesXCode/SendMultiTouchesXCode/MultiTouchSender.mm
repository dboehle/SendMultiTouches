//
//  MultiTouchSender.m
//  SendMultiTouchesXCode
//
//  Created by Duncan Boehle on 4/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#include <math.h>
#include <unistd.h>
#include <iostream>
#include <map>
#include <CoreFoundation/CoreFoundation.h>

#include "oscpkt/oscpkt.hh"
#include "oscpkt/udp.hh"

#import "MultiTouchSender.h"

@implementation MultiTouchSender

using namespace oscpkt;

const short DEFAULT_PORT_NUM = 9109;
const char* DEFAULT_ADDRESS = "localhost";

Finger fingerList[MAX_FINGERS];

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
	
    NSTimeInterval curTime = [NSDate timeIntervalSinceReferenceDate];
    
    for (int i=0; i<nFingers; i++) {
        
		Finger* f = &data[i];
        f->timestamp = curTime;
        
        int sequenceId = -1;
        
        // first try to find a finger with the same ID that has been touched recently
        for (int i = 0; i < MAX_FINGERS; i++)
        {
            Finger finger = fingerList[i];
            double timeSinceTouched = curTime - finger.timestamp;
            if (timeSinceTouched < RELEASE_TIME && finger.identifier == f->identifier)
            {
                sequenceId = i;
                break;
            }
        }
        // then, try to replace an old finger that has already been lifted
        // try to replace with the closest finger
        if (sequenceId == -1)
        {
            float closestFingerDistSq = FLT_MAX;
            
            for (int i = 0; i < MAX_FINGERS; i++)
            {
                Finger finger = fingerList[i];
                double timeSinceTouched = curTime - finger.timestamp;
                float xDiff = finger.normalized.pos.x - f->normalized.pos.x;
                float yDiff = finger.normalized.pos.y - f->normalized.pos.y;
                float fingerDistSq = (xDiff * xDiff) + (yDiff * yDiff);
                
                if (timeSinceTouched > FIND_TIME && sequenceId == -1)
                {
                    sequenceId = i;
                    break;
                }
                else if (timeSinceTouched >= RELEASE_TIME && fingerDistSq < closestFingerDistSq &&
                    timeSinceTouched < FIND_TIME)
                {
                    closestFingerDistSq = fingerDistSq;
                    sequenceId = i;
                }
            }
        }
        
        if (sequenceId != -1)
        {
            float oldAngle = fingerList[sequenceId].angle;
            float newAngle = f->angle;
            
            fingerList[sequenceId] = *f;
            fingerList[sequenceId].angle = (ANGLE_DAMPING * oldAngle) + ((1.0f - ANGLE_DAMPING) * newAngle);
            f = &(fingerList[sequenceId]);
            
            Message msg("/finger");
            msg.pushInt32(sequenceId);
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
	}
	
	return 0;
}

- (void)setup: (const char*) targetAddr : (short) targetPort : (int) verboseLevel
{
    for (int i = 0; i < MAX_FINGERS; i++)
    {
        fingerList[i].timestamp = 0.0;
    }
    
    verbosity = verboseLevel;
    
    [self configureConnection:targetAddr :targetPort];
	
	pw.init();
	
	MTDeviceRef dev = MTDeviceCreateDefault();
	MTRegisterContactFrameCallback(dev, callback);
	MTDeviceStart(dev, 0);
}

- (void) configureConnection: (const char*) targetAddr : (short) targetPort
{
    if (sock.isOk() && sock.isBound())
    {
        sock.close();
    }
    
    if (strcmp(targetAddr, "") == 0)
    {
        targetAddr = DEFAULT_ADDRESS;
    }
    if (targetPort == 0)
    {
        targetPort = DEFAULT_PORT_NUM;
    }
    
    std::cout << "Connecting to " << targetAddr << ":" << targetPort << "..." << std::endl;
    
    sock.connectTo(targetAddr, targetPort);
	if (!sock.isOk()) {
		std::cout << "Error opening port " << targetPort << ": " << sock.errorMessage() << std::endl;
		return;
	}
}

- (void*)getFingerArray
{
    return fingerList;
}


@end
