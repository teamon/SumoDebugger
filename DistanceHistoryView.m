//
//  DistanceHistoryView.m
//  SumoDebugger
//
//  Created by Tymon Tobolski on 10-01-25.
//  Copyright 2010 Politechnika Wrocławska. All rights reserved.
//

#import "DistanceHistoryView.h"

#define KR 0.05
#define KQ 0.0003
#define HISTORY_SIZE 100


@implementation DistanceHistoryView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _data = [[NSMutableArray alloc] init];
		_kalmanData = [[NSMutableArray alloc] init];
		[_data addObject:[NSNumber numberWithInt:0]];
		[_kalmanData addObject:[NSNumber numberWithInt:0]];
		P = 1;
    }
    return self;
}

- (NSMutableArray *)data
{
	return _data;
}

-(void)addValue:(int)value
{	
	[_data addObject:[NSNumber numberWithInt:value]];
	
	double P_ = P + KQ;
	double K = P_/(P_ + KR);
	double last = [[_kalmanData lastObject] doubleValue];
	P = (1-K)*P_;
	
	[_kalmanData addObject:[NSNumber numberWithDouble:(last + K*(value - last))]];
	[self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect
{
	float width = dirtyRect.size.width;
	float height = dirtyRect.size.height;
	float w = width / HISTORY_SIZE;
		
	
	// lines
	[[NSColor grayColor] set];
	NSBezierPath* aPath = [NSBezierPath bezierPath];
	[aPath setLineWidth:1.0];
	
	float h;
	for(int i=1; i<4; i++){
		h = i*height / 4;
		[aPath moveToPoint:NSMakePoint(0, h)];
		[aPath lineToPoint:NSMakePoint(width, h)];
		[aPath stroke];
	}
	
	int c = [_data count];
	for(int i=0; i<c; i++){
		// normal data
		if(i%2==0)[[NSColor colorWithCalibratedRed:0.0 green:0.0 blue:1.0 alpha:0.95] set];
		else [[NSColor colorWithCalibratedRed:0.2 green:0.2 blue:1.0 alpha:0.95] set];
		NSRectFill(NSMakeRect((i-c)*w + width, 0, w, height*[[_data objectAtIndex:i] floatValue] / 1023));
				
		// kalman data
		if(i > 0){
			[[NSColor whiteColor] set];
			NSBezierPath* aPath = [NSBezierPath bezierPath];
			[aPath setLineWidth:2.0];
			[aPath moveToPoint:NSMakePoint((i-1-c)*w + width, height*[[_kalmanData objectAtIndex:(i-1)] floatValue] / 1023)];
			[aPath lineToPoint:NSMakePoint((i-c)*w + width, height*[[_kalmanData objectAtIndex:i] floatValue] / 1023)];
			[aPath stroke];
		}

		//[[NSColor whiteColor] set];
		//NSRectFill(NSMakeRect((i-c)*w + width, height*[[_kalmanData objectAtIndex:i] floatValue] / 1023, w, w));
	}
	
	if(c > HISTORY_SIZE + 1){
		[_data removeObjectAtIndex:0];
		[_data removeObjectAtIndex:0];
		[_kalmanData removeObjectAtIndex:0];
		[_kalmanData removeObjectAtIndex:0];
	}
}

@end
