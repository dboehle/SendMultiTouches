//
//  AppDelegate.m
//  SendMultiTouches
//
//  Created by Duncan Boehle on 4/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

#import "MultiTouchSender.h"

@implementation AppDelegate
@synthesize PortField = _PortField;
@synthesize AddressField = _AddressField;
@synthesize NumberFormatter = _NumberFormatter;

@synthesize window = _window;

MultiTouchSender* multiTouchSender;

- (void)dealloc
{
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    multiTouchSender = [MultiTouchSender new];
    [multiTouchSender setup:"localhost" :9109 :2];
    
    [_NumberFormatter setFormat:@"####"];
    
    NSView* topView = [_window contentView];
    CustomView* canvas = (CustomView*)[[topView subviews] objectAtIndex:0];
    
    [canvas giveFingerArray:[multiTouchSender getFingerArray]];
}

- (IBAction)Connect:(id)sender
{
    NSString* portString = [_PortField stringValue];
    int portNum = [portString intValue];
    
    NSString* addressString = [_AddressField stringValue];
    const char* addressCStr = [addressString UTF8String];
    
    [multiTouchSender configureConnection:addressCStr :portNum];
}
@end
