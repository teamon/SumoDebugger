//
//  JoystickView.m
//  SumoDebugger
//
//  Created by Tymon Tobolski on 10-02-19.
//  Copyright 2010 Politechnika Wrocławska. All rights reserved.
//

#import "JoystickView.h"


@implementation JoystickView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
	float width = dirtyRect.size.width;
	float height = dirtyRect.size.height;
	
	int a = (xValue + 100) * width / 200;
	int b = (yValue + 100) * height / 200;
	
	
	[[NSColor blueColor] set];
	
	
	NSBezierPath* thePath = [NSBezierPath bezierPath];
	
    [thePath appendBezierPathWithOvalInRect:NSMakeRect(a-5, b-5, 10, 10)];
    [thePath stroke];
	[thePath fill];
}

- (void)setX:(int)x
{
	xValue = x;
	[self setNeedsDisplay:YES];
}
		
- (void)setY:(int)y
{
	yValue = y;
	[self setNeedsDisplay:YES];
}

@end
