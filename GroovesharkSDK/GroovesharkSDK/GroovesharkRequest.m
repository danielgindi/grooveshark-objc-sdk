//
//  GroovesharkRequest.m
//  GroovesharkSDK
//
//  Created by Daniel Cohen Gindi on 10/14/14.
//  Copyright (c) 2012 danielgindi@gmail.com. All rights reserved.
//
//  https://github.com/danielgindi/grooveshark-objc-sdk
//
//  The MIT License (MIT)
//
//  Copyright (c) 2014 Daniel Cohen Gindi (danielgindi@gmail.com)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import "GroovesharkRequest.h"

@interface GroovesharkRequest () <NSURLConnectionDelegate, NSURLConnectionDataDelegate>
{
    NSURLConnection *_connection;
    NSMutableData *_data;
    NSURLResponse *_response;
}
@end

@implementation GroovesharkRequest

- (id)initWithUrlRequest:(NSURLRequest *)urlRequest
              completion:(GroovesharkRequestResponseBlock)completionBlock
                   fail:(GroovesharkRequestFailBlock)failBlock
{
    self = [super init];
    if (self)
    {
        _urlRequest = urlRequest;
        _completionBlock = [completionBlock copy];
        _failBlock = [failBlock copy];
    }
    return self;
}

- (GroovesharkRequest *)start
{
    if (_connection) return self;
    _connection = [[NSURLConnection alloc] initWithRequest:self.urlRequest delegate:self];
    _data = [[NSMutableData alloc] init];
    [_connection start];
    return self;
}

- (GroovesharkRequest *)cancel
{
    [_connection cancel];
    _connection = nil;
    _data = nil;
    return self;
}

+ (GroovesharkRequest *)requestWithUrlRequest:(NSURLRequest *)urlRequest
                                   completion:(GroovesharkRequestResponseBlock)completionBlock
                                        fail:(GroovesharkRequestFailBlock)failBlock
                                        start:(BOOL)start
{
    GroovesharkRequest *req = [[GroovesharkRequest alloc] initWithUrlRequest:urlRequest completion:completionBlock fail:failBlock];
    if (start)
    {
        [req start];
    }
    return req;
}

#pragma mark - NSURLConnectionDelegate, NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (connection == _connection)
    {
        if (_failBlock)
        {
            _failBlock(error);
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (connection == _connection)
    {
        [_data appendData:data];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if (connection == _connection)
    {
        _response = response;
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (connection == _connection)
    {
        if (_completionBlock)
        {
            _completionBlock(connection.originalRequest, connection.currentRequest, _response, _data);
        }
    }
}

@end
