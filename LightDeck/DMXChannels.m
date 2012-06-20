//
//  DMXChannels.m
//  ArduinoSerial
//
//  Created by Florian Maurer on 2/10/12.
//  Copyright (c) 2012 2215 22nd St. All rights reserved.
//

#import "DMXChannels.h"
#import "DMXChannel.h"

@implementation DMXChannels

@synthesize channelValues;
@synthesize numberOf;

- (id) init {
    if ((self = [super init])) {
        
        self.channelValues = [NSMutableDictionary dictionary];
        numberOf = 0;
        
        // Path to the plist (in the application bundle)
        NSString *path = [[NSBundle mainBundle] pathForResource:
                          @"defaultDMXValues" ofType:@"plist"];
        // Build the array from the plist  
        NSMutableDictionary *defaultDmx = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
        // Create DMXChannel objects from plist entries and store them into channelValues  
        for (NSDictionary *tempChannel in [defaultDmx objectForKey:@"channels"]){
            DMXChannel* newChannel = [[[DMXChannel alloc] init] autorelease];
            newChannel.channel = [tempChannel objectForKey:@"channel"];
            newChannel.value = [tempChannel objectForKey:@"value"];
            newChannel.description = [tempChannel objectForKey:@"description"];

            [channelValues setObject:newChannel forKey:newChannel.channel];
            numberOf++;
             
            //NSLog(@"--%@", [tempChannel objectForKey:@"description"]);
        } 
        [defaultDmx release];
    }
    return self;
}
- (void) asdf {

}

- (void) setChannel:(NSNumber*)ch toValue:(NSNumber*)val {
    
    NSLog(@"setting ch: %@ to val: %@",ch, val);
    
    //todo: implement check to see if ch exists
    
    DMXChannel* tempChannel = [channelValues objectForKey:ch];
    NSNumber * cleanValue = [NSNumber numberWithInt:(int)roundf([val floatValue]*255)];
    
    if (cleanValue > [NSNumber numberWithInt:255] || cleanValue < [NSNumber numberWithInt:0]) {
        cleanValue = [NSNumber numberWithInt:255];
    }
    
    tempChannel.value = cleanValue;
}

- (NSMutableData *) generateSerialData {
        
    //Initialize empty char[] that will hold the serial message
    NSMutableData * serialBytes = [[NSMutableData alloc] init];
    
    //First character is the number of channels about to be sent
    u_char numChannels = (u_char)self.numberOf;
    [serialBytes appendBytes:&numChannels length:sizeof(numChannels)];
    
    for (int i=1;i<=self.numberOf;i++){
        //get i'th channel from dictionary of channelValues
        DMXChannel* tempChannel = [self.channelValues objectForKey:[NSNumber numberWithInt:i]];
        u_char channelValue = (u_char)[tempChannel.value intValue];
        [serialBytes appendBytes:&channelValue length:sizeof(channelValue)];
    }
    
    //framing bytes    
    const u_char framingbytes[4] = "\xde\xad\xbe\xef";

    [serialBytes appendData:[NSData dataWithBytes:framingbytes length:sizeof(framingbytes)]];
    
    return serialBytes;
    
}

@end
