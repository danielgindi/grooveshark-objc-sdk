//
//  GroovesharkLoginViewController.m
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

#import "GroovesharkLoginViewController.h"

@interface GroovesharkLoginViewController () <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webView;

@end

@implementation GroovesharkLoginViewController

- (id)init
{
    return [super init];
}

- (id)initWithSession:(GroovesharkSession *)session callbackUrl:(NSURL *)callbackUrl
{
    self = [self init];
    if (self)
    {
        self.session = session;
        self.callbackUrl = callbackUrl;
    }
    return self;
}

- (id)initWithSession:(GroovesharkSession *)session callbackUrl:(NSURL *)callbackUrl delegate:(id<GroovesharkLoginViewControllerDelegate>)delegate
{
    self = [self init];
    if (self)
    {
        self.session = session;
        self.callbackUrl = callbackUrl;
        self.delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.webView = [[UIWebView alloc] init];
    _webView.delegate = self;
    _webView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_webView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[webView]-0-|" options:0 metrics:nil views:@{@"webView": _webView}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[webView]-0-|" options:0 metrics:nil views:@{@"webView": _webView}]];
    
    NSMutableString *urlString = [@"https://auth.grooveshark.com/?app=" mutableCopy];
    [urlString appendString:[self.session.key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [urlString appendString:@"&callback="];
    [urlString appendString:[self.callbackUrl.absoluteString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *url = request.URL;
    if ([url.absoluteString hasPrefix:self.callbackUrl.absoluteString])
    {
        NSMutableDictionary *queryParams = [[NSMutableDictionary alloc] init];
        for (NSString *pair in [url.query componentsSeparatedByString:@"&"])
        {
            NSArray *elements = [pair componentsSeparatedByString:@"="];
            if(elements.count < 2) continue;
            
            [queryParams setObject:[[elements objectAtIndex:1] stringByRemovingPercentEncoding] forKey:[[elements objectAtIndex:0] stringByRemovingPercentEncoding]];
        }
        
        if (queryParams[@"token"])
        {
            [self.session authenticateWithToken:queryParams[@"token"] completion:^(BOOL success, NSString *email, GroovesharkUserInfo *userInfo, NSError *error) {
                
                if (success)
                {
                    if ([_delegate respondsToSelector:@selector(groovesharkLoginViewControllerDidLogin:)])
                    {
                        [_delegate groovesharkLoginViewControllerDidLogin:self];
                    }
                }
                else
                {
                    if ([_delegate respondsToSelector:@selector(groovesharkLoginViewController:didFailLoginWithError:)])
                    {
                        [_delegate groovesharkLoginViewController:self didFailLoginWithError:error];
                    }
                }
                
            }];
        }
        else if (queryParams[@"cancel"])
        {
            if ([_delegate respondsToSelector:@selector(groovesharkLoginViewControllerDidCancel:)])
            {
                [_delegate groovesharkLoginViewControllerDidCancel:self];
            }
        }
        
        return NO;
    }
    
    return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if ([_delegate respondsToSelector:@selector(groovesharkLoginViewController:didFailLoadingWithError:)])
    {
        [_delegate groovesharkLoginViewController:self didFailLoadingWithError:error];
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if ([_delegate respondsToSelector:@selector(groovesharkLoginViewControllerDidStartLoading:)])
    {
        [_delegate groovesharkLoginViewControllerDidStartLoading:self];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if ([_delegate respondsToSelector:@selector(groovesharkLoginViewControllerDidFinishLoading:)])
    {
        [_delegate groovesharkLoginViewControllerDidFinishLoading:self];
    }
}

@end
