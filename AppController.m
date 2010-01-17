//
//  AppController.m
//  SumoDebugger
//
//  Created by Tymon Tobolski on 10-01-16.
//  Copyright 2010 Politechnika Wrocławska. All rights reserved.
//

#import "AppController.h"
#import "AMSerialPortList.h"

#define DefaultPortPath @"DefaultPortPath"


@implementation AppController

- (void)awakeFromNib
{
	distanceSensors[0].label = dist0ValueLabel;
	distanceSensors[0].levelIndicator = dist0LevelIndicator;
	distanceSensors[1].label = dist1ValueLabel;
	distanceSensors[1].levelIndicator = dist1LevelIndicator;
	distanceSensors[2].label = dist2ValueLabel;
	distanceSensors[2].levelIndicator = dist2LevelIndicator;
	distanceSensors[3].label = dist3ValueLabel;
	distanceSensors[3].levelIndicator = dist3LevelIndicator;
	distanceSensors[4].label = dist4ValueLabel;
	distanceSensors[4].levelIndicator = dist4LevelIndicator;
	distanceSensors[5].label = dist5ValueLabel;
	distanceSensors[5].levelIndicator = dist5LevelIndicator;
	
	groundSensors[0].checkBox = ground0CheckBox;
	groundSensors[1].checkBox = ground1CheckBox;
	groundSensors[2].checkBox = ground2CheckBox;
	groundSensors[3].checkBox = ground3CheckBox;
	
	engines[0].slider = engine0Slider;
	engines[0].label = engine0ValueLabel;
	engines[1].slider = engine1Slider;
	engines[1].label = engine1ValueLabel;
	
	manualEngineMode = NO;
	
	preferences = [[NSUserDefaults standardUserDefaults] retain];	
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(didAddPorts:) 
												 name:AMSerialPortListDidAddPortsNotification 
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(didRemovePorts:)
												 name:AMSerialPortListDidRemovePortsNotification
											   object:nil];
	[AMSerialPortList sharedPortList];
	[self updatePortList];
	
	NSString *defaultPort = [preferences objectForKey:DefaultPortPath];
	if(defaultPort && ![defaultPort isEqualToString:@""])
	{
		[portListPopUpButton selectItemWithTitle:defaultPort];
		[self initPortFor:defaultPort];
	}
}

- (void)windowWillClose:(NSNotification *)notification 
{
	[self closePort];
	[NSApp terminate:self];
}

- (void) setPort:(AMSerialPort *)newPort
{
	id old = nil;
	if(newPort != port)
	{
		old = port;
		port = [newPort retain];
		[old release];
	}
}

- (AMSerialPort *)port 
{
	return port;
}

- (void) openPort
{
	[self initPortFor:[portListPopUpButton titleOfSelectedItem]];
	if([port isOpen]) return;
	
	if([port bsdPath] == nil){
		[self log:@"[ERROR] Empty bsdPath"];
		[port close];
		return;
	}
	
	[self log:@"[INFO] Attempting to open port"];
	
	if([port open])
	{
		[self log:[@"[INFO] Port opened for device " stringByAppendingString:[port bsdPath]]];
		[port readDataInBackground];
	}
	else 
	{
		[self log:[@"[ERROR] Couldn`t open port for devie " stringByAppendingString:[port bsdPath]]];
		[self setPort:nil];			
	}
	
}

- (void) closePort
{
	[port stopReadInBackground];
	[port clearError];
	[port close];
}


- (void) initPortFor:(NSString *)portPath
{
	if(![portPath isEqualToString:[port bsdPath]])
	{
		[port close];
		
		[self setPort:[[[AMSerialPort alloc] init:portPath 
										 withName:portPath 
											 type:(NSString*)CFSTR(kIOSerialBSDModemType)] autorelease]];
		[port setDelegate:self];
		[port setSpeed:B9600]; 
	}
}
	 
- (void) log:(NSString *) text
{
	[outputTextView insertText:[text stringByAppendingString:@"\n"]];
}

- (void) updatePortList
{
	[portListPopUpButton removeAllItems];
	NSEnumerator *enumerator = [AMSerialPortList portEnumerator];
	AMSerialPort *aPort;
	while(aPort = [enumerator nextObject])
	{
		[portListPopUpButton addItemWithTitle:[aPort bsdPath]];
	}
	[self log:@"[INFO] Port list updated"];
}

// port stuff

- (void)serialPortReadData:(NSDictionary *)dataDictionary
{
	NSLog(@"DUPA");
	AMSerialPort *sendPort = [dataDictionary objectForKey:@"serialPort"];
	NSData *data = [dataDictionary objectForKey:@"data"];
	if([data length] > 0)
	{
		NSString *text = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
		[self parseInput:text];
		[text release];
		
		[sendPort readDataInBackground];
	}
	else 
	{
		[self closePort];
		[self log:@"[INFO] Port closed"];
	}
}

- (void) parseInput:(NSString *)input
{
	// Input: G1:..:GN:D1:..:DN:M1:..:MN:OTHER\n
	[self log:[@"[INPUT] " stringByAppendingString:[input substringToIndex:[input length]-1]]];
	
	NSArray *chunks = [input componentsSeparatedByString: @":"];
	
	if([chunks count] < (GROUND_COUNT + DISTANCE_COUNT + ENGINE_COUNT + 1)) return;
	
	int value;
	
	// ground sensors
	for(int i=0 ; i<GROUND_COUNT; i++) {
		if ([[chunks objectAtIndex:i] intValue] == 1) [groundSensors[i].checkBox setState:NSOnState];
		else [groundSensors[i].checkBox setState:NSOffState];
	}
	
	// distance sensors
	for(int i=0; i<DISTANCE_COUNT; i++){
		value = [[chunks objectAtIndex:(i+GROUND_COUNT)] intValue];
		[distanceSensors[i].label setIntValue:value];
		[distanceSensors[i].levelIndicator setIntValue:(value*50/1023)];
	}
	
	// engines
	if(!manualEngineMode){
		for(int i=0; i<ENGINE_COUNT; i++){
			value = [[chunks objectAtIndex:(i+GROUND_COUNT+DISTANCE_COUNT)] intValue];
			[engines[i].label setIntValue:value];
			[engines[i].slider setIntValue:value];
		}
	}
	
	// other
	//chunks[i] 
}

- (void)didAddPorts:(NSNotification *)theNotification
{
	[self log:@"[INFO] New port found"];
	[self updatePortList];
	
	NSString *defaultPort = [preferences objectForKey:DefaultPortPath];
	if([[portListPopUpButton itemTitles] containsObject:defaultPort]){
		[self log:[@"[INFO] Selecting default port:" stringByAppendingString:defaultPort]];
		[portListPopUpButton selectItemWithTitle:defaultPort];
	}
}

- (void)didRemovePorts:(NSNotification *)theNotification
{
	[self log:@"[INFO] Port removed"];
	[self updatePortList];
}

// actions

- (IBAction) startStopReading:(id)sender
{
	if([[sender title] isEqualToString:@"Connect"])
	{
		[self openPort];
		[sender setTitle:@"Disconnect"];
	}
	else 
	{
		[self closePort];
		[sender setTitle:@"Connect"];
	}
}

- (IBAction) selectPort:(id)sender
{
	[preferences setObject:[sender titleOfSelectedItem] forKey:DefaultPortPath];
}

-(IBAction) selectEngineMode:(id)sender
{
	manualEngineMode = [[[sender selectedCell] title] isEqualToString:@"Manual"];
	for(int i=0; i<ENGINE_COUNT; i++) [engines[i].slider setEnabled:manualEngineMode];

}


@end
