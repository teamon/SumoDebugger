//
//  AppController.m
//  SumoDebugger
//
//  Created by Tymon Tobolski on 10-01-16.
//  Copyright 2010 Politechnika Wrocławska. All rights reserved.
//

#import "AppController.h"
#import "AMSerialPortList.h"


@implementation AppController

- (void)awakeFromNib
{
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(didAddPorts:) 
												 name:AMSerialPortListDidAddPortsNotification 
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(didRemovePorts:)
												 name:AMSerialPortListDidRemovePortsNotification
											   object:nil];
	[AMSerialPortList sharedPortList];
	[self updateDeviceList];	
}

- (void)windowWillClose:(NSNotification *)notification 
{
	[port clearError];
	[port close];
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

- (void) initPortFor:(NSString *)deviceName
{
	if(![deviceName isEqualToString:[port bsdPath]])
	{
		[port close];
		
		[self setPort:[[[AMSerialPort alloc] init:deviceName 
										 withName:deviceName 
											 type:(NSString*)CFSTR(kIOSerialBSDModemType)] autorelease]];
		[port setDelegate:self];
		[self log:@"[INFO] Attempting to open port"];
		
		if([port open])
		{
			[self log:@"[INFO] Port opened"];
			[port setSpeed:B9600]; 
			[port readDataInBackground];
		}
		else 
		{
			[self log:[[NSString stringWithString:@"[ERROR] Couldn`t open port for devie "] stringByAppendingString:deviceName]];
			[self setPort:nil];			
		}
		
	}
}
	 
- (void) log:(NSString *) text
{
	[outputTextView insertText:[text stringByAppendingString:@"\n"]];
}

- (void) updateDeviceList
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
		[self log:[@"[INPUT] " stringByAppendingString:text]];
		[text release];
		
		[sendPort readDataInBackground];
	}
	else 
	{
		[self log:@"[INFO] Port closed"];
	}

}

- (void)didAddPorts:(NSNotification *)theNotification
{
	[self log:@"[INFO] New port found"];
	[self updateDeviceList];
}

- (void)didRemovePorts:(NSNotification *)theNotification
{
	[self log:@"[INFO] Port removed"];
	[self updateDeviceList];
}

// actions

- (IBAction) chooseDevice:(id)sender
{
	[self initPortFor:[sender titleOfSelectedItem]];
}

- (IBAction) closePort:(id)sender
{
	[port stopReadInBackground];
	[port close];
}


@end
