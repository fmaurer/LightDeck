//
//  LightDeckController.h
//  ArduinoSerial
//
//  Created by Florian Maurer on 2/26/12.
//  Copyright (c) 2012 2215 22nd St. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMXChannels.h"
#import "AMSerialPort.h"

@interface LightDeckController : NSObject

@property (nonatomic, retain) NSMutableArray* activeChannels;
@property (nonatomic, retain) DMXChannels* dmxchannels;
@property (nonatomic, retain) AMSerialPort *port;
@property (nonatomic, retain) NSString* deviceName;

-(void) setLights:(NSDictionary*)parameters;
-(void) sendDMXSerialString;

// Serial Port Methods
- (AMSerialPort *)port;
- (void)setPort:(AMSerialPort *)newPort;
- (void)initPort;

- (void)selectedDevice: (NSString*)deviceName;


@end
