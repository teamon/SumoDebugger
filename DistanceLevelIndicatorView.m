//
//  DistanceLevelIndicatorView.m
//  SumoDebugger
//
//  Created by Tymon Tobolski on 10-01-25.
//  Copyright 2010 Politechnika Wrocławska. All rights reserved.
//

#import "DistanceLevelIndicatorView.h"


@implementation DistanceLevelIndicatorView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)mouseDown:(NSEvent *)event
{
	if([event clickCount] == 2){
		[historyPanel makeKeyAndOrderFront:self];
	}
}
@end
