//
//  SumoDebuggerAppDelegate.h
//  SumoDebugger
//
//  Created by Tymon Tobolski on 10-01-16.
//  Copyright 2010 Politechnika Wrocławska. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SumoDebuggerAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;

@end
