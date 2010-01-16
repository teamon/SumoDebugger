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
	[self updatePortList];	
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

- (void)didAddPorts:(NSNotification *)theNotification
{
	[self log:@"[INFO] New port found"];
	[self updatePortList];
}

- (void)didRemovePorts:(NSNotification *)theNotification
{
	[self log:@"[INFO] Port removed"];
	[self updatePortList];
}

@end
