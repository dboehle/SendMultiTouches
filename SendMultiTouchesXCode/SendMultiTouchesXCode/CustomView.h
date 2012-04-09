//
//  CustomView.h
//  SendMultiTouches
//
//  Created by Duncan Boehle on 4/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>
#import <Cocoa/Cocoa.h>

@interface CustomView : NSOpenGLView
{
    
}

- (void) drawRect: (NSRect) bounds;

- (void) giveFingerDict: (void*) dictPtr;

@end
