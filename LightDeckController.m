//
//  LightDeckController.m
//  ArduinoSerial
//
//  Created by Florian Maurer on 2/26/12.
//  Copyright (c) 2012 2215 22nd St. All rights reserved.
//

#import "LightDeckController.h"
#import "DMXChannel.h"
#import "AMSerialPortList.h"
#import "AMSerialPortAdditions.h"

@interface LightDeckController()
//- (void)initPort;
@end

@implementation LightDeckController

@synthesize activeChannels;
@synthesize dmxchannels = _dmxchannels;
@synthesize port = _port;
@synthesize deviceName;

- (id) init {
    
    self.deviceName = @"";
    
    if (self = [super init]) {
        // Initialize dmx channel values
        self.dmxchannels = [[[DMXChannels alloc] init] autorelease];
        
        //listen for change to lights from httpServer  
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(lightsChanged:) name:@"PostReceived" object:nil];
        
        //listen for change to different device selection
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(selectedDevice:) name:@"DeviceSelected" object:nil];
        
        //[self startServer];

        /// set up notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAddPorts:) name:AMSerialPortListDidAddPortsNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRemovePorts:) name:AMSerialPortListDidRemovePortsNotification object:nil];
        
        /// initialize port list to arm notifications
        [AMSerialPortList sharedPortList];
        
        if(self.port) {
            [self initPort];
        }
        
        if([self.port isOpen]) {
            //[port writeString:[self.dmxchannels generateSerialString] usingEncoding:NSASCIIStringEncoding error:NULL];
            //NSLog(@"%@", [self.dmxchannels generateSerialString]);
            
            //NSMutableData *serialData = [self.dmxchannels generateSerialData];
            
            //[port writeData:[NSMutableData dataWithBytes:& serialData length:sizeof(serialData)] error:NULL]; 
            //u_char test[] = {0x07, 0xff, 0xff, 0xff, 0x00, 0x00, 0x00, 0xff, 0xde, 0xad, 0xbe, 0xef};
            
            NSError *writeError;
            //[port writeData:[NSMutableData dataWithBytes:test length:12] error:&writeError]; 
            //[port writeData:[NSMutableData dataWithData:serialData] error:&writeError];
            /*if (writeError) {
             NSLog(@"Write error: %@",writeError);
             }*/
            //NSLog(@"%@", [[NSString alloc] initWithBytes:&serialData length:sizeof(serialData) encoding:NSASCIIStringEncoding]);
        }
        
        return self;
        
    }
    
    return self;
}

- (void)awakeFromNib {
}

//event handler when event occurs
-(void)lightsChanged: (NSNotification *) notification
{
    [self setLights:notification.userInfo];
}

- (void)selectedDevice: (NSNotification *) notification{
    self.deviceName = [notification.userInfo objectForKey:@"dev"];
    NSLog(@"%@",self.deviceName);
}

-(void) setLights:(NSDictionary*)parameters {
    
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle]; 
        
    for (NSNumber *lightNumber in [parameters objectForKey:@"lights"]) {
        for( NSString *aKey in parameters )
        {
            if ([aKey isEqualToString:@"brightness"]){
                NSNumber *tempBrightness = [f numberFromString:[parameters objectForKey:aKey]];
                /* The following line is a hack to make it work: it assumes all the lights have identical channels to multiply by 7
                
                    The correct solution would be another function setValueOf:dmxChannel forLight:identifier which uses the below method
                 
                 (lightNum -1 ) * 7 + channel
                 
                */
                [self.dmxchannels asdf];
                [self.dmxchannels setChannel:[NSNumber numberWithInt:[lightNumber intValue]*7] toValue:tempBrightness];
                //NSLog(@"%@",tempBrightness);
            }
            if ([aKey isEqualToString:@"color"]){
                NSString *tempColor = [parameters objectForKey:aKey];
            
                if ([tempColor isEqualToString:@"red"]) {
                    [self.dmxchannels setChannel:[NSNumber numberWithInt:([lightNumber intValue]-1)*7+1] toValue:[NSNumber numberWithInt:1]];
                    [self.dmxchannels setChannel:[NSNumber numberWithInt:([lightNumber intValue]-1)*7+2] toValue:[NSNumber numberWithInt:0]];
                    [self.dmxchannels setChannel:[NSNumber numberWithInt:([lightNumber intValue]-1)*7+3] toValue:[NSNumber numberWithInt:0]];
                }
                
                if ([tempColor isEqualToString:@"purple"]) {
                    [self.dmxchannels setChannel:[NSNumber numberWithInt:([lightNumber intValue]-1)*7+1] toValue:[NSNumber numberWithInt:1]];
                    [self.dmxchannels setChannel:[NSNumber numberWithInt:([lightNumber intValue]-1)*7+2] toValue:[NSNumber numberWithInt:0]];
                    [self.dmxchannels setChannel:[NSNumber numberWithInt:([lightNumber intValue]-1)*7+3] toValue:[NSNumber numberWithInt:1]];
                }
                
                if ([tempColor isEqualToString:@"blue"]) {
                    [self.dmxchannels setChannel:[NSNumber numberWithInt:([lightNumber intValue]-1)*7+1] toValue:[NSNumber numberWithInt:0]];
                    [self.dmxchannels setChannel:[NSNumber numberWithInt:([lightNumber intValue]-1)*7+2] toValue:[NSNumber numberWithInt:0]];
                    [self.dmxchannels setChannel:[NSNumber numberWithInt:([lightNumber intValue]-1)*7+3] toValue:[NSNumber numberWithInt:1]];
                }
                
                if ([tempColor isEqualToString:@"teal"]) {
                    [self.dmxchannels setChannel:[NSNumber numberWithInt:([lightNumber intValue]-1)*7+1] toValue:[NSNumber numberWithInt:0]];
                    [self.dmxchannels setChannel:[NSNumber numberWithInt:([lightNumber intValue]-1)*7+2] toValue:[NSNumber numberWithInt:1]];
                    [self.dmxchannels setChannel:[NSNumber numberWithInt:([lightNumber intValue]-1)*7+3] toValue:[NSNumber numberWithInt:1]];
                }
                
                if ([tempColor isEqualToString:@"green"]) {
                    [self.dmxchannels setChannel:[NSNumber numberWithInt:([lightNumber intValue]-1)*7+1] toValue:[NSNumber numberWithInt:0]];
                    [self.dmxchannels setChannel:[NSNumber numberWithInt:([lightNumber intValue]-1)*7+2] toValue:[NSNumber numberWithInt:1]];
                    [self.dmxchannels setChannel:[NSNumber numberWithInt:([lightNumber intValue]-1)*7+3] toValue:[NSNumber numberWithInt:0]];
                }
                
                if ([tempColor isEqualToString:@"white"]) {
                    [self.dmxchannels setChannel:[NSNumber numberWithInt:([lightNumber intValue]-1)*7+1] toValue:[NSNumber numberWithInt:1]];
                    [self.dmxchannels setChannel:[NSNumber numberWithInt:([lightNumber intValue]-1)*7+2] toValue:[NSNumber numberWithInt:1]];
                    [self.dmxchannels setChannel:[NSNumber numberWithInt:([lightNumber intValue]-1)*7+3] toValue:[NSNumber numberWithInt:1]];
                }
                
                
                //NSLog(@"%@",tempBrightness);
            }
        }
    }
    
    [self sendDMXSerialString];
    /*if (writeError) {
        NSLog(@"Write error: %@",writeError);
    }
    NSLog(@"%@", [[NSString alloc] initWithBytes:&serialData length:sizeof(serialData) encoding:NSASCIIStringEncoding]);
    */
    [f release];
}

-(void) sendDMXSerialString {
    NSMutableData *serialData = [self.dmxchannels generateSerialData];
    NSError *writeError;
    [self.port writeData:[NSMutableData dataWithData:serialData] error:&writeError];
}

# pragma mark Serial Port Stuff

- (void)initPort
{
    NSString *currentDevName = self.deviceName;
    if (![currentDevName isEqualToString:[self.port bsdPath]]) {
        [self.port close];
        
        [self setPort:[[[AMSerialPort alloc] init:currentDevName withName:currentDevName type:(NSString*)CFSTR(kIOSerialBSDModemType)] autorelease]];
        [self.port setDelegate:self];
        
        if ([self.port open]) {
            
            //Then I suppose we connected!
            NSLog(@"successfully connected");
            
            //[connectButton setEnabled:NO];
            //[sendButton setEnabled:YES];
            //[serialScreenMessage setStringValue:@"Connection Successful!"];
            
            //TODO: Set appropriate baud rate here. 
            
            //The standard speeds defined in termios.h are listed near
            //the top of AMSerialPort.h. Those can be preceeded with a 'B' as below. However, I've had success
            //with non standard rates (such as the one for the MIDI protocol). Just omit the 'B' for those.
			
            [self.port setSpeed:B115200]; 
            
            
            // listen for data in a separate thread
            [self.port readDataInBackground];
            
            
        } else { // an error occured while creating port
            
            NSLog(@"error connecting");
            //[serialScreenMessage setStringValue:@"Error Trying to Connect..."];
            [self setPort:nil];
            
        }
    }
}

@end
