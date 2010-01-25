//
//  DistanceHistoryView.m
//  SumoDebugger
//
//  Created by Tymon Tobolski on 10-01-25.
//  Copyright 2010 Politechnika Wrocławska. All rights reserved.
//

#import "DistanceHistoryView.h"


@implementation DistanceHistoryView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _data = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSMutableArray *)data
{
	return _data;
}

- (void)drawRect:(NSRect)dirtyRect
{
	NSLog(@"drawing rect");
	float width = dirtyRect.size.width;
	float height = dirtyRect.size.height;
	float w = width / 400;
		
	[[NSColor colorWithCalibratedRed:0.0 green:0.0 blue:1.0 alpha:0.95] set];
	
	NSRect rect;
	int c = [_data count];
	for(int i=0; i<c; i++){
		rect = NSMakeRect((i-c)*w + width, 0, w, height*[[_data objectAtIndex:i] floatValue] / 1023);
		NSRectFill(rect);
	}
}

@end
