#import <Cocoa/Cocoa.h>
#import "HTTPConnection.h"

@class MyWebSocket;

@interface MyHTTPConnection : HTTPConnection
{
	MyWebSocket *ws;
}
@property (nonatomic, retain) NSDictionary * postDataDictionary;

@end