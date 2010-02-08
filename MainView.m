//
//  MainView.m
//  SumoDebugger
//
//  Created by Tymon Tobolski on 10-02-03.
//  Copyright 2010 Politechnika Wrocławska. All rights reserved.
//

#import "MainView.h"


@implementation MainView

- (void)keyDown:(NSEvent *)event
{
	char c = [[event characters] characterAtIndex:0];
	
	switch(c){
		case 'q':
			[[self delegate] changeEnginePower:0 withValue:5];
			break;
		case 'a':
			[[self delegate] changeEnginePower:0 withValue:-5];
			break;
		case 'w':
			[[self delegate] changeEnginePower:1 withValue:5];
			break;
		case 's':
			[[self delegate] changeEnginePower:1 withValue:-5];
			break;
	}
}

@end
