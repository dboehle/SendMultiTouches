//
//  CustomView.m
//  SendMultiTouches
//
//  Created by Duncan Boehle on 4/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CustomView.h"
#import <OpenGL/gl.h>
#import <math.h>
#import <map>
#import <vector>

#import "MultiTouchSender.h"

@implementation CustomView

const int CIRCLE_LENGTH = 32;
const float SCALE_FACTOR = 0.007;
NSTimer* renderTimer;
std::map<int, Finger>* fingerIdDictPtr;
float viewWidth;
float viewHeight;
float aspect;

void drawFinger(Finger* finger);

// Synchronize buffer swaps with vertical refresh rate
- (void)prepareOpenGL
{
    GLint swapInt = 1;
    GLint aaSamples = 4;
    
    [[self openGLContext] setValues:&swapInt forParameter:NSOpenGLCPSwapInterval];
    
    glLineWidth(2.0f);
}

// Put our timer in -awakeFromNib, so it can start up right from the beginning
- (void)awakeFromNib
{
    renderTimer = [NSTimer timerWithTimeInterval:0.030
                                           target:self
                                         selector:@selector(timerFired:)
                                         userInfo:nil
                                          repeats:YES];
   
   [[NSRunLoop currentRunLoop] addTimer:renderTimer 
                                forMode:NSDefaultRunLoopMode];
   [[NSRunLoop currentRunLoop] addTimer:renderTimer 
                                forMode:NSEventTrackingRunLoopMode]; //Ensure timer fires during resize
}
                   
// Timer callback method
- (void)timerFired:(id)sender
{
    // It is good practice in a Cocoa application to allow the system to send the -drawRect:
    // message when it needs to draw, and not to invoke it directly from the timer. 
    // All we do here is tell the display it needs a refresh
    [self setNeedsDisplay:YES];
}

void drawFinger(Finger* finger)
{
    glPushMatrix();

    glScalef(2.0f, 2.0f, 0.0f);
    glTranslatef(finger->normalized.pos.x - 0.5f, finger->normalized.pos.y - 0.5f, 0.0f);


    glRotatef(180.0f * finger->angle / M_PI, 0.0f, 0.0f, 1.0f);
    glScalef(SCALE_FACTOR * finger->majorAxis, SCALE_FACTOR * finger->minorAxis, 1.0f);

    
    
    glColor3f(0.72f, 0.125f, 0.14f);
    glBegin(GL_TRIANGLE_FAN);
    {
        for (int i = 0; i < CIRCLE_LENGTH; i++)
        {
            float angleRad = 2.0f * M_PI * ((float)(i) / (float)(CIRCLE_LENGTH));
            glVertex2f(cosf(angleRad), sinf(angleRad));
        }
    }
    glEnd();
    
    glColor3f(0.0f, 0.0f, 0.0f);
    glBegin(GL_LINES);
    glVertex2f(0.0f, 0.0f);
    glVertex2f(0.75f, 0.0f);
    glVertex2f(0.75f, 0.0f);
    glVertex2f(0.5f, 0.25f);
    glVertex2f(0.75f, 0.0f);
    glVertex2f(0.5f, -0.25f);
    glEnd();
    
    glPopMatrix();
}

-(void) giveFingerDict: (void*)dictPtr
{
    fingerIdDictPtr = (std::map<int, Finger>*)dictPtr;
}

-(void) drawRect: (NSRect) bounds
{
    glClearColor(0.7f, 0.7f, 0.7f, 0.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    NSTimeInterval curTime = [NSDate timeIntervalSinceReferenceDate];
    NSRect frameRect = [self frame];
    viewWidth = frameRect.size.width;
    viewHeight = frameRect.size.height;
    aspect = (viewWidth / viewHeight);
    
    if (fingerIdDictPtr != NULL)
    {
        std::map<int, Finger>::iterator it = fingerIdDictPtr->begin();
        while (it != fingerIdDictPtr->end())
        {
            Finger* fingerPtr = &((*it).second);
            double timeSinceTouched = curTime - fingerPtr->timestamp;
            if (timeSinceTouched > RELEASE_TIME)
            {
                fingerIdDictPtr->erase(it++);
            }
            else
            {
                drawFinger(&(*it).second);
                it++;
            }
        }
    }
    
    glFlush();
}

@end
