//
//  AppDelegate.m
//  LightDeck
//
//  Created by Florian Maurer on 4/3/12.
//  Copyright (c) 2012 2215 22nd St. All rights reserved.
//

#import "AppDelegate.h"
#import "AppDelegate.h"
#import "MyHTTPConnection.h"
#import "DDLog.h"
#import "DDTTYLogger.h"

@interface AppDelegate()

- (void)startServer;

@end

// Log levels: off, error, warn, info, verbose
static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@implementation AppDelegate

//@synthesize serialSelectMenu;
//@synthesize textField;

- (id) init {
    if (self = [super init]) {
        [self startServer];
    }
    return self;
}



- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	
	//[sendButton setEnabled:NO];
	
    
}

# pragma mark HTTPServer

- (void)startServer {
    // Configure our logging framework.
	// To keep things simple and fast, we're just going to log to the Xcode console.
	[DDLog addLogger:[DDTTYLogger sharedInstance]];
	
	// Initalize our http server
	httpServer = [[HTTPServer alloc] init];
	
	// Tell the server to broadcast its presence via Bonjour.
	// This allows browsers such as Safari to automatically discover our service.
	[httpServer setType:@"_http._tcp."];
	
	// Normally there's no need to run our server on any specific port.
	// Technologies like Bonjour allow clients to dynamically discover the server's port at runtime.
	// However, for easy testing you may want force a certain port so you can just hit the refresh button.
    	[httpServer setPort:11111];
	
	// We're going to extend the base HTTPConnection class with our MyHTTPConnection class.
	// This allows us to do all kinds of customizations.
	[httpServer setConnectionClass:[MyHTTPConnection class]];
	
	// Serve files from our embedded Web folder
	NSString *webPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Web"];
	DDLogInfo(@"Setting document root: %@", webPath);
	
	[httpServer setDocumentRoot:webPath];
	
	
	NSError *error = nil;
	if(![httpServer start:&error])
	{
		DDLogError(@"Error starting HTTP Server: %@", error);
	}
    
}



@end
