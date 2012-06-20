#import "MyWebSocket.h"
#import "HTTPLogging.h"

// Log levels: off, error, warn, info, verbose
// Other flags : trace
static const int httpLogLevel = HTTP_LOG_LEVEL_WARN | HTTP_LOG_FLAG_TRACE;

@interface MyWebSocket()
    - (NSDictionary*)queryDictionary:(NSString *)paramString usingEncoding:(NSStringEncoding)encoding;
@end

@implementation MyWebSocket

- (void)didOpen
{
	HTTPLogTrace();
	
	[super didOpen];
	
	[self sendMessage:@"Connection established"];
}

- (void)didReceiveMessage:(NSString *)msg
{
	HTTPLogTrace2(@"%@[%p]: didReceiveMessage: %@", THIS_FILE, self, msg);
	
    NSDictionary* postDataDictionary = [self queryDictionary:msg usingEncoding:NSUTF8StringEncoding];
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"PostReceived"
     object:self
     userInfo:postDataDictionary];
    
	[self sendMessage:[NSString stringWithFormat:@"post received at %@", [NSDate date]]];
}

- (void)didClose
{
	HTTPLogTrace();
	
	[super didClose];
}

- (NSDictionary*)queryDictionary:(NSString *)paramString usingEncoding:(NSStringEncoding)encoding {
    
    NSCharacterSet* delimiterSet = [NSCharacterSet
                                    characterSetWithCharactersInString:@"&;"] ;
    NSMutableDictionary* pairs = [NSMutableDictionary dictionary] ;
    NSMutableArray *lights = [NSMutableArray new];
    [pairs setObject:lights forKey: @"lights"];
    
    NSScanner* scanner = [[[NSScanner alloc] initWithString:paramString] autorelease] ;
    
    while (![scanner isAtEnd]) {
        NSString* pairString ;
        [scanner scanUpToCharactersFromSet:delimiterSet
                                intoString:&pairString] ;
        [scanner scanCharactersFromSet:delimiterSet intoString:NULL] ;
        NSArray* kvPair = [pairString componentsSeparatedByString:@"="] ;
        if ([kvPair count] == 2) {
            NSString* key = [[kvPair objectAtIndex:0]
                             stringByReplacingPercentEscapesUsingEncoding:encoding] ;
            NSString* value = [[kvPair objectAtIndex:1]
                               stringByReplacingPercentEscapesUsingEncoding:encoding] ;
            
            if ([key isEqualToString:@"light"] ){
                [[pairs objectForKey:@"lights"] addObject:value];
            } else {
                [pairs setObject:value forKey:key] ;
            }
        }
    }
    
    return [NSDictionary dictionaryWithDictionary:pairs] ;
    
}


@end
