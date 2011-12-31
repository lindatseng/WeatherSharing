//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "UrlFetcher.h"

@implementation UrlFetcher
@synthesize delegate;
@synthesize responseData;
@synthesize userData;
@synthesize connection;

-(UrlFetcher *) initWithDelegate:(id<UrlFetcherDelegate>)del {
	self = [super init];
	if (self) {
		self.delegate = del;
	}
	return self;
}

-(void) getUrl:(NSString *)url {
#ifdef DEBUG
    NSLog(@"Url: %@", url);
#endif
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];     
	[request setHTTPMethod:@"GET"];
	
	NSURLConnection *tmpConnection =[[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
	if(!tmpConnection) {
		NSLog(@"SpeedyApi - UrlFetcher: Connection failed on %@", url);
	}
	[self.connection cancel];
	self.connection = tmpConnection;
	[tmpConnection release];
	[request release];
	
}

-(void) getDataUrl:(NSString *)url {
	resultIsData = YES;
	[self getUrl:url];
}

-(void) getUrl:(NSString *)url withPostData:(NSData *)postData {
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];     
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:postData];
	
	NSURLConnection *tmpConnection =[[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
	if(!tmpConnection)  {
		NSLog(@"SpeedyApi - UrlFetcher: Connection failed on %@", url);
	}
	self.connection = tmpConnection;
	[tmpConnection release];
	[request release];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSLog(@"SpeedyApi - UrlFetcher %@: Connection Failed %@ %d", self, [error domain], [error code]);
	[delegate urlGotError:self withError:error];
	[self clean];
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	if(responseData == nil) {
		responseData = [[NSMutableData alloc] initWithData:data];
	} else {
		[responseData appendData:data];
	}
	
}

- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response {
    NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *) response;
    assert( [httpResponse isKindOfClass:[NSHTTPURLResponse class]] );
    
    if (httpResponse.statusCode != 200) {
		NSLog(@"SpeedyApi - UrlFetcher %@: http rc was %d. Cancelling the connection", self, httpResponse.statusCode);
		[theConnection cancel];
		[delegate urlGotError:self withError:[NSError errorWithDomain:@"UrlFetcher wrong responseCode" code:httpResponse.statusCode userInfo:nil]];
    }    
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    }
    
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (resultIsData) {
		[delegate urlDidFinish:self withData:responseData];
		[self clean];
	} else {
		NSString *responseFromServer = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
#ifdef DEBUG
        NSLog(@"response: %@", responseFromServer);
#endif
		[delegate urlDidFinish:self withString:responseFromServer];
		[responseFromServer release];
		[self clean];
	}
}	

-(void)clean {
	[responseData release];
	responseData = nil;
	[connection release];
	connection = nil;
}

-(void) cancel {
	if (connection != nil) {
		[connection cancel];
	}
}

- (void)dealloc {
	[connection release];
	[userData release];
	[super dealloc];
}

@end
