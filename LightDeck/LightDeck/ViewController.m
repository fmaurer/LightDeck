//
//  ViewController.m
//  LightDeck
//
//  Created by Florian Maurer on 4/27/12.
//  Copyright (c) 2012 2215 22nd St. All rights reserved.
//

#import "ViewController.h"
#import "DMXChannel.h"
#import "AMSerialPortList.h"
#import "AMSerialPortAdditions.h"


@implementation ViewController

@synthesize DMXTableView;
@synthesize lightDeckController;
@synthesize connectButton, sendButton;
@synthesize mainWindow;

- (id) init {
    if ((self = [super init])) {
        self.lightDeckController = [[LightDeckController alloc] init];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(lightsChanged:) name:@"LightsChanged" object:nil];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didChangeDMX:) name:@"ReloadDMXView" object:nil];
        
    }
    
    return self;
}

- (void)listDevices
{
    // get an port enumerator
    NSEnumerator *enumerator = [AMSerialPortList portEnumerator];
    AMSerialPort *aPort;
    [serialSelectMenu removeAllItems];
    
    while (aPort = [enumerator nextObject]) {
        [serialSelectMenu addItemWithTitle:[aPort bsdPath]];
    }
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"DeviceSelected"
     object:nil
     userInfo:[NSDictionary dictionaryWithObject:[serialSelectMenu titleOfSelectedItem] forKey:@"dev"]];
}

- (NSString *)displayName {
    return [NSString stringWithFormat:@"LightDeck - %@:11111", [[[NSHost currentHost] addresses] objectAtIndex:1]];
}

- (void)awakeFromNib {
    
    [self listDevices];
    
    [self didChangeDMX];
    
    [self.mainWindow setTitle:[self displayName]];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    // This is a defensive move
    // There are cases where the nib containing the NSTableView can be loaded before the data is populated
    // by ensuring the count value is 0 and checking to see if the namesArray is not nil, the application
    // is protecting itself agains that situation
    
    
     NSInteger count=0;
     if (self.lightDeckController.dmxchannels)
     count=self.lightDeckController.dmxchannels.numberOf;
     return count;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    // the return value is typed as (id) because it will return a string in all cases with the exception of the
    id returnValue=nil;
    
    // The column identifier string is the easiest way to identify a table column. Much easier
     // than keeping a reference to the table column object.
     NSString *columnIdentifer = [aTableColumn identifier];
     
     // Get the name at the specified row in the namesArray
     DMXChannel *tempChannel = [self.lightDeckController.dmxchannels.channelValues objectForKey:[NSNumber numberWithInteger:rowIndex+1]];
     //NSLog([NSString stringWithFormat:@"%d", rowIndex+1]);
     
     
     // Compare each column identifier and set the return value to
     // the Person field value appropriate for the column.
     if ([columnIdentifer isEqualToString:@"channel_number"]) {
     returnValue = tempChannel.channel;
     }
     
     if ([columnIdentifer isEqualToString:@"channel_value"]) {
     returnValue = tempChannel.value;
     }
     
     if ([columnIdentifer isEqualToString:@"channel_description"]) {
     returnValue = tempChannel.description;
     }
     
    return returnValue;
}

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    
    
     NSDictionary *oldChannel = [self.lightDeckController.dmxchannels.channelValues objectForKey:[NSNumber numberWithInteger:rowIndex+1]];
     
     if ([aTableColumn.identifier isEqualToString:@"channel_value"]) {
     [oldChannel setValue:[NSNumber numberWithInt:[anObject intValue]] forKey:@"value"];
     
    [self.lightDeckController sendDMXSerialString];
     
     if ([aTableColumn.identifier isEqualToString:@"channel_description"]) {
     [oldChannel setValue:anObject forKey: @"description"];
     }
          
     //NSLog(@"%@",[self.dmxchannels.channelValues objectForKey:[NSNumber numberWithInteger:rowIndex+1]]);
      //NSLog(@"%@",aTableColumn);
     }
}

- (IBAction)send:(id)sender
{
    NSString *sendString = [[textField stringValue] stringByAppendingString:@"\r"];
    
    if(!self.lightDeckController.port) {
        [self.lightDeckController initPort];
    }
    
    if([self.lightDeckController.port isOpen]) {
        [self.lightDeckController.port writeString:sendString usingEncoding:NSUTF8StringEncoding error:NULL];
    }
}

- (IBAction)attemptConnect:(id)sender {
	
	[serialScreenMessage setStringValue:@"Attempting to Connect..."];
	[self.lightDeckController initPort];
	
}

- (AMSerialPort *)port
{
    return self.lightDeckController.port;
}

- (void)setPort:(AMSerialPort *)newPort
{
    id old = nil;
    
    if (newPort != self.lightDeckController.port) {
        old = self.lightDeckController.port;
        self.lightDeckController.port = [newPort retain];
        [old release];
    }
}


# pragma mark Notifications

- (void)didAddPorts:(NSNotification *)theNotification
{
    NSLog(@"A port was added");
    [self listDevices];
}

- (void)didRemovePorts:(NSNotification *)theNotification
{
    NSLog(@"A port was removed");
    [self listDevices];
}

- (void) didChangeDMX{
    [DMXTableView reloadData];
}

@end
