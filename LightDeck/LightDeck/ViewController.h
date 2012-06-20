//
//  ViewController.h
//  LightDeck
//
//  Created by Florian Maurer on 4/27/12.
//  Copyright (c) 2012 2215 22nd St. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LightDeckController.h"

@interface ViewController : NSObject {

    NSTableView* DMXTableView;

    IBOutlet NSPopUpButton	*serialSelectMenu;
    IBOutlet NSTextField	*textField;
    IBOutlet NSButton		*connectButton, *sendButton;
    IBOutlet NSTextField	*serialScreenMessage;
    IBOutlet NSWindow       *mainWindow;
}

@property (nonatomic, retain) LightDeckController *lightDeckController;
@property (nonatomic, retain) IBOutlet NSTableView *DMXTableView;
@property (nonatomic, retain) NSButton *connectButton, *sendButton;
@property (nonatomic, retain) NSWindow *mainWindow;

// Interface Methods
- (IBAction)attemptConnect:(id)sender;
- (IBAction)send:(id)sender;

-(void)didChangeDMX;

@end
