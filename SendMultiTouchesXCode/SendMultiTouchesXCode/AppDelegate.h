//
//  AppDelegate.h
//  SendMultiTouches
//
//  Created by Duncan Boehle on 4/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CustomView.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
- (IBAction)Connect:(id)sender;
@property (assign) IBOutlet NSTextField *PortField;
@property (assign) IBOutlet NSTextField *AddressField;
@property (assign) IBOutlet NSNumberFormatter *NumberFormatter;

@end
