//
//  AppController.h
//  SumoDebugger
//
//  Created by Tymon Tobolski on 10-01-16.
//  Copyright 2010 Politechnika Wrocławska. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AmSerialPort.h"

#define GROUND_COUNT 4
#define DISTANCE_COUNT 6
#define ENGINE_COUNT 2

struct DistanceSensor {
	NSTextField *label;
	NSLevelIndicator *levelIndicator;
};

struct GroundSensor {
	NSButton *checkBox;
};

struct Engine {
	NSSlider *slider;
	NSTextField *label;
};


@interface AppController : NSObject {
	NSUserDefaults *preferences;
	AMSerialPort *port;
	Boolean manualEngineMode;
	
	
	IBOutlet NSPopUpButton *portListPopUpButton;
	IBOutlet NSTextView *outputTextView;
	IBOutlet NSMatrix *selectEngineModeMatrix;
	
	// distance sensors	
	IBOutlet NSTextField *dist0ValueLabel;
	IBOutlet NSTextField *dist1ValueLabel;
	IBOutlet NSTextField *dist2ValueLabel;
	IBOutlet NSTextField *dist3ValueLabel;
	IBOutlet NSTextField *dist4ValueLabel;
	IBOutlet NSTextField *dist5ValueLabel;
	IBOutlet NSLevelIndicator *dist0LevelIndicator;
	IBOutlet NSLevelIndicator *dist1LevelIndicator;
	IBOutlet NSLevelIndicator *dist2LevelIndicator;
	IBOutlet NSLevelIndicator *dist3LevelIndicator;
	IBOutlet NSLevelIndicator *dist4LevelIndicator;
	IBOutlet NSLevelIndicator *dist5LevelIndicator;
	struct DistanceSensor distanceSensors[DISTANCE_COUNT];
	
	// ground sensors
	IBOutlet NSButton *ground0CheckBox;
	IBOutlet NSButton *ground1CheckBox;
	IBOutlet NSButton *ground2CheckBox;
	IBOutlet NSButton *ground3CheckBox;
	struct GroundSensor groundSensors[GROUND_COUNT];
	
	// engines
	IBOutlet NSSlider *engine0Slider;
	IBOutlet NSSlider *engine1Slider;
	IBOutlet NSTextField *engine0ValueLabel;
	IBOutlet NSTextField *engine1ValueLabel;
	struct Engine engines[ENGINE_COUNT];
}

-(IBAction) startStopReading:(id)sender;
-(IBAction) selectPort:(id)sender;
-(IBAction) selectEngineMode:(id)sender;

					   
-(void) updatePortList;
-(void) closePort;
-(void) parseInput:(NSString *)text;

-(void)log:(NSString *)text;

@end
