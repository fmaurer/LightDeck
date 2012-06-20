//
//  AppDelegate.h
//  LightDeck
//
//  Created by Florian Maurer on 4/3/12.
//  Copyright (c) 2012 2215 22nd St. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HTTPServer.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>
{    
    //LightDeckController* lightDeckController;
    HTTPServer *httpServer;
	
}

//@property (nonatomic, retain) IBOutlet NSPopUpButton *serialSelectMenu;
//@property (nonatomic, retain) IBOutlet NSTextField	 *textField;

@end
