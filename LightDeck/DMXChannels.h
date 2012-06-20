//
//  DMXChannels.h
//  ArduinoSerial
//
//  Created by Florian Maurer on 2/10/12.
//  Copyright (c) 2012 2215 22nd St. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DMXChannels : NSObject

- (void) asdf;

@property (retain, nonatomic) NSMutableDictionary* channelValues;
@property (nonatomic) int numberOf;

- (NSMutableData*) generateSerialData;

- (void) setChannel:(NSNumber*)ch toValue:(NSNumber*)val;
@end
