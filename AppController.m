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
	groundSensors[0].displayCheckBox = ground0DisplayCheckBox;
	groundSensors[1].displayCheckBox = ground1DisplayCheckBox;
	groundSensors[2].displayCheckBox = ground2DisplayCheckBox;
	groundSensors[3].displayCheckBox = ground3DisplayCheckBox;
	
	groundSensors[0].activeCheckBox = ground0ActiveCheckBox;
	groundSensors[1].activeCheckBox = ground1ActiveCheckBox;
	groundSensors[2].activeCheckBox = ground2ActiveCheckBox;
	groundSensors[3].activeCheckBox = ground3ActiveCheckBox;
	
	for(int i=0 ; i<GROUND_COUNT; i++) {
		[groundSensors[i].activeCheckBox setAction:@selector(activateGroundSensor:)];
	}
	
	
	distanceSensors[0].label = dist0ValueLabel;
	distanceSensors[1].label = dist1ValueLabel;
	distanceSensors[2].label = dist2ValueLabel;
	distanceSensors[3].label = dist3ValueLabel;
	distanceSensors[4].label = dist4ValueLabel;
	distanceSensors[5].label = dist5ValueLabel;
	
	distanceSensors[0].levelIndicator = dist0LevelIndicator;
	distanceSensors[1].levelIndicator = dist1LevelIndicator;
	distanceSensors[2].levelIndicator = dist2LevelIndicator;
	distanceSensors[3].levelIndicator = dist3LevelIndicator;
	distanceSensors[4].levelIndicator = dist4LevelIndicator;
	distanceSensors[5].levelIndicator = dist5LevelIndicator;
	
	distanceSensors[0].activeCheckBox = dist0ActiveCheckBox;
	distanceSensors[1].activeCheckBox = dist1ActiveCheckBox;
	distanceSensors[2].activeCheckBox = dist2ActiveCheckBox;
	distanceSensors[3].activeCheckBox = dist3ActiveCheckBox;
	distanceSensors[4].activeCheckBox = dist4ActiveCheckBox;
	distanceSensors[5].activeCheckBox = dist5ActiveCheckBox;
	
	distanceSensors[0].historyView = dist0HistoryView;
	distanceSensors[1].historyView = dist1HistoryView;
	distanceSensors[2].historyView = dist2HistoryView;
	distanceSensors[3].historyView = dist3HistoryView;
	distanceSensors[4].historyView = dist4HistoryView;
	distanceSensors[5].historyView = dist5HistoryView;
	
	for(int i=0 ; i<DISTANCE_COUNT; i++) {
		[distanceSensors[i].activeCheckBox setAction:@selector(activateDistanceSensor:)];
	}
	
	engines[0].slider = engine0Slider;
	engines[1].slider = engine1Slider;
	
	engines[0].label = engine0ValueLabel;
	engines[1].label = engine1ValueLabel;
	
	[engines[0].slider setAction:@selector(setEnginePower:)];
	[engines[1].slider setAction:@selector(setEnginePower:)];
	
	engineMode = kNormal;
	
	// serial port
	
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
	if(defaultPort && ![defaultPort isEqualToString: @""])
	{
		[portListPopUpButton selectItemWithTitle: defaultPort];
		[self initPortFor: defaultPort];
	}
	
	// joystick
	
	joystick.list = [[DDHidJoystick allJoysticks] retain];
	[joystick.list makeObjectsPerformSelector: @selector(setDelegate:)
								   withObject: self];
	
	if([joystick.list count] > 0){
		joystick.current = [joystick.list objectAtIndex: 0];
		[joystick.current startListening];
		
		NSArray * buttons = [joystick.current buttonElements];
		for(DDHidElement *e in buttons){
			NSLog(@"%@", [e usage]);
		}
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
- (void) debuglog:(NSString *) text
{
	[debugTextView insertText:[text stringByAppendingString:@"\n"]];
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
	AMSerialPort *sendPort = [dataDictionary objectForKey:@"serialPort"];
	NSData *data = [dataDictionary objectForKey:@"data"];
	if([data length] > 0)
	{
		NSString *text = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
		
		for(NSString *c in [text componentsSeparatedByString:@"\n"]){
			[self parseInput:c];
		}		
		
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
	if([input isEqualToString:@""]) return;
	if([[input substringWithRange:NSMakeRange(0,1)] isEqualToString:@"^"]){ // debug /^../
		[self debuglog:input];
		return;
	}
	
	[self log:[@"[INPUT] " stringByAppendingString:input]];
	
	NSArray *chunks = [input componentsSeparatedByString: @":"];
	
	if([chunks count] < (GROUND_COUNT + DISTANCE_COUNT + ENGINE_COUNT + 1)) return;
	
	int value;
	
	// ground sensors
	for(int i=0 ; i<GROUND_COUNT; i++) {
		if ([[chunks objectAtIndex:i] intValue] == 1) [groundSensors[i].displayCheckBox setState:NSOnState];
		else [groundSensors[i].displayCheckBox setState:NSOffState];
	}
	
	// distance sensors
	DistanceHistoryView *view;
	for(int i=0; i<DISTANCE_COUNT; i++){
		value = [[chunks objectAtIndex:(i+GROUND_COUNT)] intValue];
		[distanceSensors[i].label setIntValue:value];
		[distanceSensors[i].levelIndicator setIntValue:(value*50/1023)];
		view = distanceSensors[i].historyView;
		[view addValue:value];
	}
	
	// engines
	if(engineMode == kNormal){
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

- (void) send:(NSString *)msg
{
	[self log:[@"[OUTPUT] " stringByAppendingString:msg]];
	NSError *error;
	
	if(port && [port isOpen]) [port writeString:msg usingEncoding:NSASCIIStringEncoding error:&error];
	else [self log:@"[ERROR] Port not opened"];
}

// actions

-(IBAction) startStopReading:(id)sender
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

-(IBAction) selectPort:(id)sender
{
	[preferences setObject:[sender titleOfSelectedItem] forKey:DefaultPortPath];
}

-(IBAction) setNormalEngineMode:(id)sender
{
	engineMode = kNormal;
	for(int i=0; i<ENGINE_COUNT; i++) [engines[i].slider setEnabled:NO];
	[self send:@"M0\n"];
}
-(IBAction) setGUIEngineMode:(id)sender
{
	engineMode = kGUI;
	for(int i=0; i<ENGINE_COUNT; i++) [engines[i].slider setEnabled:YES];
	[self send:@"M1\n"];
}
-(IBAction) setJoystickEngineMode:(id)sender
{
	engineMode = kJoystick;
	for(int i=0; i<ENGINE_COUNT; i++) [engines[i].slider setEnabled:NO];
	[self send:@"M1\n"];
}


-(IBAction) sendStart:(id)sender { [self send:@"!"]; }
-(IBAction) sendReset:(id)sender { [self send:@"*"]; }
-(IBAction) sendNewline:(id)sender { [self send:@"\n"]; }
-(IBAction) sendCustom:(id)sender { [self send:[customSendTextField stringValue]]; }

-(IBAction) clearLog:(id)sender {
	NSFont *font = [outputTextView font];
	
	[outputTextView setString:@""];
	[outputTextView setTextColor: [NSColor whiteColor]];
	[outputTextView setFont:font];
	
	[debugTextView setString:@""];
	[debugTextView setTextColor: [NSColor whiteColor]];
	[debugTextView setFont:font];
}

-(IBAction) activateGroundSensor:(id)sender
{
	for(int i=0 ; i<GROUND_COUNT; i++) {
		if([groundSensors[i].activeCheckBox isEqual:sender]){
			if([sender state] == NSOnState) [self send:[NSString stringWithFormat:@"G%d1\n", i]];
			else [self send:[NSString stringWithFormat:@"G%d0\n", i]];
			break;
		}
	}
}

-(IBAction) activateDistanceSensor:(id)sender
{
	for(int i=0 ; i<DISTANCE_COUNT; i++) {
		if([distanceSensors[i].activeCheckBox isEqual:sender]){
			if([sender state] == NSOnState) [self send:[NSString stringWithFormat:@"D%d1\n", i]];
			else [self send:[NSString stringWithFormat:@"D%d0\n", i]];
			break;
		}
	}
}

-(IBAction) setEnginePower:(id)sender
{
	if(engineMode == kNormal) return;
	
	for(int i=0 ; i<ENGINE_COUNT; i++) {
		if([engines[i].slider isEqual:sender]){
			[self send:[NSString stringWithFormat:@"E%d%04d\n", i, [sender intValue]]];
			[engines[i].label setIntValue:[sender intValue]];
			break;
		}
	}
}

-(void)setEnginePower:(int)engine_id withValue:(int)value
{
	if(engineMode == kNormal) return;
	
	[self send:[NSString stringWithFormat:@"E%d%04d\n", engine_id, value]];
	[engines[engine_id].label setIntValue:value];
	[engines[engine_id].slider setIntValue:value];
}

-(void) changeEnginePower:(int)engine_id withValue:(int)value
{
	if(engineMode == kNormal) return;
	
	value += [engines[engine_id].label intValue];
	if(value > 100) value = 100;
	else if(value < -100) value = -100;
	
	[self send:[NSString stringWithFormat:@"E%d%04d\n", engine_id, value]];
	[engines[engine_id].label setIntValue:value];
	[engines[engine_id].slider setIntValue:value];
	
} 



- (void) ddhidJoystick:(DDHidJoystick *)theJoystick stick:(unsigned)stick xChanged:(int)value;
{
	joystick.xValue = value * 100 / 65536;
	if(engineMode == kJoystick)	[self setEnginePower: 1 withValue: joystick.xValue];
}

- (void) ddhidJoystick:(DDHidJoystick *)theJoystick stick:(unsigned)stick yChanged:(int)value;
{
    joystick.yValue = -value * 100 / 65536;
	if(engineMode == kJoystick)	[self setEnginePower: 0 withValue: joystick.yValue];
}

- (void) ddhidJoystick:(DDHidJoystick *)theJoystick stick:(unsigned)stick otherAxis:(unsigned)otherAxis valueChanged:(int)value;
{
    joystick.zValue = value * 100 / 65536;
}

- (void) ddhidJoystick:(DDHidJoystick *)theJoystick buttonDown:(unsigned)buttonNumber;
{
    NSLog(@"Button %d down", buttonNumber);
}

- (void) ddhidJoystick:(DDHidJoystick *)theJoystick buttonUp:(unsigned)buttonNumber;
{
    NSLog(@"Button %d up", buttonNumber);
}


@end
