//
//  DMXChannel.h
//  ArduinoSerial
//
//  Created by Florian Maurer on 2/12/12.
//  Copyright (c) 2012 2215 22nd St. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DMXChannel : NSObject{    
    NSNumber* channel;
    NSNumber* value;
    NSString* description;
}

@property (retain, nonatomic) NSNumber* channel;
@property (retain, nonatomic) NSNumber* value;
@property (retain, nonatomic) NSString* description;

@end
