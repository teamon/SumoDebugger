//
//  AppController.h
//  SumoDebugger
//
//  Created by Tymon Tobolski on 10-01-16.
//  Copyright 2010 Politechnika Wrocławska. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AmSerialPort.h"


@interface AppController : NSObject {
	IBOutlet NSPopUpButton *portListPopUpButton;
	IBOutlet NSTextView *outputTextView;
	AMSerialPort *port;
}

-(void) updatePortList;

@end
