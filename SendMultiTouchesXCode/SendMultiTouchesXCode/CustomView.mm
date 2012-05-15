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
#import <iostream>

#import "MultiTouchSender.h"

#import <CoreGraphics/CoreGraphics.h>

@implementation CustomView

const int CIRCLE_LENGTH = 32;
const float SCALE_FACTOR = 0.007;
NSTimer* renderTimer;
Finger* fingerListPtr;
float viewWidth;
float viewHeight;
float aspect;

void drawFinger(Finger finger, int sequenceId);
void drawNumber(int num, float x, float y, float scale, float r, float g, float b);
void drawDigit(int num, float x, float y, float scale, float r, float g, float b);

// Synchronize buffer swaps with vertical refresh rate
- (void)prepareOpenGL
{
    GLint swapInt = 1;
    
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

void drawFinger(Finger finger, int sequenceId)
{
    glPushMatrix();

    glScalef(2.0f, 2.0f, 0.0f);
    glTranslatef(finger.normalized.pos.x - 0.5f, finger.normalized.pos.y - 0.5f, 0.0f);

    glPushMatrix();

    glRotatef(180.0f * finger.angle / M_PI, 0.0f, 0.0f, 1.0f);
    glScalef(SCALE_FACTOR * finger.majorAxis, SCALE_FACTOR * finger.minorAxis, 1.0f);
    
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
    
    drawNumber(sequenceId, 0.0f, 0.0f, 0.02f, 1.0f, 1.0f, 1.0f);
    
    glPopMatrix();
}

-(void) giveFingerArray: (void*)arrayPtr
{
    fingerListPtr = (Finger*)arrayPtr;
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
    
    if (fingerListPtr != NULL)
    {
        for (int i = 0; i < MAX_FINGERS; i++)
        {
            Finger finger = fingerListPtr[i];
            double timeSinceTouched = curTime - finger.timestamp;
            if (timeSinceTouched < RELEASE_TIME)
            {
                drawFinger(finger, i);
            }
        }
    }
    
    /*if (fingerIdDictPtr != NULL)
    {
        std::map<int, MultiTouchFinger*>::iterator it = fingerIdDictPtr->begin();
        while (it != fingerIdDictPtr->end())
        {
            MultiTouchFinger* multiTouchFingerPtr = (*it).second;
            Finger* fingerPtr = multiTouchFingerPtr->finger;
            double timeSinceTouched = curTime - fingerPtr->timestamp;
            if (timeSinceTouched > RELEASE_TIME)
            {
                std::cout << "Finger with id " << fingerPtr->identifier << ", sequence " <<
                    multiTouchFingerPtr->sequenceId << " was lifted." << std::endl;
                fingerIdDictPtr->erase(it++);
                //fingerListPtr[multiTouchFingerPtr->sequenceId] = NULL;
                std::cout << "Touching with " << fingerIdDictPtr->size() << " fingers." << std::endl;
            }
            else
            {
                drawFinger(multiTouchFingerPtr);
                it++;
            }
        }
    }*/
    
    glFlush();
}

void drawNumber(int num, float x, float y, float scale, float r, float g, float b)
{
    if (num > 9)
    {
        int ones = num % 10;
        int tens = (num - ones) / 10;
        drawDigit(ones, x + 1.0f, y, scale, r, g, b);
        drawDigit(tens, x - 1.0f, y, scale, r, g, b);
    }
    else
    {
        drawDigit(num, x, y, scale, r, g, b);
    }
}

void drawDigit(int num, float x, float y, float scale, float r, float g, float b)
{
    glPushMatrix();
    
    glColor3f(r, g, b);
    glScalef(0.5f * scale, scale, scale);
    glTranslatef(x, y, 0.0f);
    
    switch (num) {
        case 0:
            glBegin(GL_LINE_LOOP);
            glVertex2f(-1.0f, 1.0f);
            glVertex2f(1.0f, 1.0f);
            glVertex2f(1.0f, -1.0f);
            glVertex2f(-1.0f, -1.0f);
            glEnd();
            break;
        case 1:
            glBegin(GL_LINES);
            glVertex2f(0.0f, 1.0f);
            glVertex2f(0.0f, -1.0f);
            glEnd();
            break;
        case 2:
            glBegin(GL_LINE_STRIP);
            glVertex2f(-1.0f, 1.0f);
            glVertex2f(1.0f, 1.0f);
            glVertex2f(1.0f, 0.0f);
            glVertex2f(-1.0f, 0.0f);
            glVertex2f(-1.0f, -1.0f);
            glVertex2f(1.0f, -1.0f);
            glEnd();
            break;
        case 3:
            glBegin(GL_LINES);
            glVertex2f(1.0f, 1.0f);
            glVertex2f(1.0f, -1.0f);
            glVertex2f(-1.0f, 1.0f);
            glVertex2f(1.0f, 1.0f);
            glVertex2f(-1.0f, 0.0f);
            glVertex2f(1.0f, 0.0f);
            glVertex2f(-1.0f, -1.0f);
            glVertex2f(1.0f, -1.0f);
            glEnd();
            break;
        case 4:
            glBegin(GL_LINES);
            glVertex2f(-1.0f, 1.0f);
            glVertex2f(-1.0f, 0.0f);
            glVertex2f(-1.0f, 0.0f);
            glVertex2f(1.0f, 0.0f);
            glVertex2f(1.0f, 1.0f);
            glVertex2f(1.0f, -1.0f);
            glEnd();
            break;
        case 5:
            glBegin(GL_LINE_STRIP);
            glVertex2f(1.0f, 1.0f);
            glVertex2f(-1.0f, 1.0f);
            glVertex2f(-1.0f, 0.0f);
            glVertex2f(1.0f, 0.0f);
            glVertex2f(1.0f, -1.0f);
            glVertex2f(-1.0f, -1.0f);
            glEnd();
            break;
        case 6:
            glBegin(GL_LINE_STRIP);
            glVertex2f(1.0f, 1.0f);
            glVertex2f(-1.0f, 1.0f);
            glVertex2f(-1.0f, -1.0f);
            glVertex2f(1.0f, -1.0f);
            glVertex2f(1.0f, 0.0f);
            glVertex2f(-1.0f, 0.0f);
            glEnd();
            break;
        case 7:
            glBegin(GL_LINE_STRIP);
            glVertex2f(-1.0f, 1.0f);
            glVertex2f(1.0f, 1.0f);
            glVertex2f(1.0f, -1.0f);
            glEnd();
            break;
        case 8:
            glBegin(GL_LINE_LOOP);
            glVertex2f(-1.0f, 1.0f);
            glVertex2f(1.0f, 1.0f);
            glVertex2f(1.0f, -1.0f);
            glVertex2f(-1.0f, -1.0f);
            glEnd();
            glBegin(GL_LINES);
            glVertex2f(-1.0f, 0.0f);
            glVertex2f(1.0f, 0.0f);
            glEnd();
            break;
        case 9:
            glBegin(GL_LINE_STRIP);
            glVertex2f(1.0f, -1.0f);
            glVertex2f(1.0f, 1.0f);
            glVertex2f(-1.0f, 1.0f);
            glVertex2f(-1.0f, 0.0f);
            glVertex2f(1.0f, 0.0f);
            glEnd();
            break;
            
        default:
            break;
    }
    
    glPopMatrix();
}

@end
