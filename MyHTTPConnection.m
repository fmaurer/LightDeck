#import "MyHTTPConnection.h"
#import "HTTPMessage.h"
#import "HTTPDataResponse.h"
#import "DDNumber.h"
#import "HTTPLogging.h"
#import "MyWebSocket.h"

@interface MyHTTPConnection()

- (NSDictionary*)queryDictionary:(NSString *)paramString usingEncoding:(NSStringEncoding)encoding;

@end

// Log levels : off, error, warn, info, verbose
// Other flags: trace
static const int httpLogLevel = HTTP_LOG_LEVEL_WARN; // | HTTP_LOG_FLAG_TRACE;


/**
 * All we have to do is override appropriate methods in HTTPConnection.
**/

@implementation MyHTTPConnection

@synthesize postDataDictionary;

- (BOOL)supportsMethod:(NSString *)method atPath:(NSString *)path
{
	HTTPLogTrace();
	
	// Add support for POST
	
	if ([method isEqualToString:@"POST"])
	{
		if ([path isEqualToString:@"/post.html"])
		{
			// Let's be extra cautious, and grab the first 5000 characters (this was increased from 50 chars because it was truncating my form POST)
			
			return requestContentLength < 5000;
		}
	}
	
	return [super supportsMethod:method atPath:path];
}

- (BOOL)expectsRequestBodyFromMethod:(NSString *)method atPath:(NSString *)path
{
	HTTPLogTrace();
	
	// Inform HTTP server that we expect a body to accompany a POST request
	
	if([method isEqualToString:@"POST"])
		return YES;
	
	return [super expectsRequestBodyFromMethod:method atPath:path];
}

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path
{
	HTTPLogTrace();
	
	if ([method isEqualToString:@"POST"] && [path isEqualToString:@"/post.html"])
	{
		HTTPLogVerbose(@"%@[%p]: postContentLength: %qu", THIS_FILE, self, requestContentLength);
		
		NSString *postStr = nil;
		
		NSData *postData = [request body];
		if (postData)
		{
			postStr = [[[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding] autorelease];
		}
		
		HTTPLogVerbose(@"%@[%p]: postStr: %@", THIS_FILE, self, postStr);
		
		// Result will be of the form "answer=..."
		
		/*int answer = [[postStr substringFromIndex:7] intValue];
		
		NSData *response = nil;
		if(answer == 10)
		{
			response = [@"<html><body>Correct<body></html>" dataUsingEncoding:NSUTF8StringEncoding];
		}
		else
		{
			response = [@"<html><body>Sorry - Try Again<body></html>" dataUsingEncoding:NSUTF8StringEncoding];
		}
		*/
        
    self.postDataDictionary = [self queryDictionary:postStr usingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"%@", self.postDataDictionary);
     
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"PostReceived"
     object:self
     userInfo:self.postDataDictionary];
        
    //[[[HTTPResponseTest alloc] initWithConnection:self] autorelease];
        
    return [[[HTTPDataResponse alloc] initWithData:postData] autorelease];
	}
	
	return [super httpResponseForMethod:method URI:path];
}

- (void)prepareForBodyWithSize:(UInt64)contentLength
{
	HTTPLogTrace();
	
	// If we supported large uploads,
	// we might use this method to create/open files, allocate memory, etc.
}

- (void)processBodyData:(NSData *)postDataChunk
{
	HTTPLogTrace();
	
	// Remember: In order to support LARGE POST uploads, the data is read in chunks.
	// This prevents a 50 MB upload from being stored in RAM.
	// The size of the chunks are limited by the POST_CHUNKSIZE definition.
	// Therefore, this method may be called multiple times for the same POST request.
	
	BOOL result = [request appendData:postDataChunk];
	if (!result)
	{
		HTTPLogError(@"%@[%p]: %@ - Couldn't append bytes!", THIS_FILE, self, THIS_METHOD);
	}
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

- (WebSocket *)webSocketForURI:(NSString *)path
{
	HTTPLogTrace2(@"%@[%p]: webSocketForURI: %@", THIS_FILE, self, path);
	
	if([path isEqualToString:@"/service"])
	{
		HTTPLogInfo(@"MyHTTPConnection: Creating MyWebSocket...");
		
		return [[[MyWebSocket alloc] initWithRequest:request socket:asyncSocket] autorelease];		
	}
	
	return [super webSocketForURI:path];
}


@end
