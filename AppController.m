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
	
	if([chunks count] < (GROUND_COUNT + DISTANCE_COUNT + MOTOR_COUNT + 1)) return;
	
	int value;
	
	// ground sensors
	//for(int i=0 ; i<GROUND_COUNT; i++) {
	//	value = [[chunks objectAtIndex:i] intValue];
	//}
	
	// distance sensors
	for(int i=0; i<DISTANCE_COUNT; i++){
		value = [[chunks objectAtIndex:(i+GROUND_COUNT)] intValue];
		[distanceSensors[i].label setIntValue:value];
		[distanceSensors[i].levelIndicator setIntValue:(value*50/1023)];
	}
	
	// motors
	//for(int i=0; i<MOTOR_COUNT; i++){
	//	value = [[chunks objectAtIndex:i] intValue];
	//}
	
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
	if([[sender title] isEqualToString:@"Start"])
	{
		[self openPort];
		[sender setTitle:@"Stop"];
	}
	else 
	{
		[self closePort];
		[sender setTitle:@"Start"];
	}
}

- (IBAction) selectPort:(id)sender
{
	[preferences setObject:[sender titleOfSelectedItem] forKey:DefaultPortPath];
}


@end
