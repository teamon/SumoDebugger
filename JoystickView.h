//
//  JoystickView.h
//  SumoDebugger
//
//  Created by Tymon Tobolski on 10-02-19.
//  Copyright 2010 Politechnika Wrocławska. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface JoystickView : NSView {
	int xValue;
	int yValue;
}

-(void)setX:(int)x;
-(void)setY:(int)x;
@end
