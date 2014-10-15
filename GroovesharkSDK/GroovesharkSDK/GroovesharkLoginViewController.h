//
//  GroovesharkLoginViewController.h
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GroovesharkSession.h"
#import "GroovesharkErrorCode.h"

@protocol GroovesharkLoginViewControllerDelegate;

@interface GroovesharkLoginViewController : UIViewController

@property (nonatomic, strong) GroovesharkSession *session;
@property (nonatomic, strong) NSURL *callbackUrl;
@property (nonatomic, weak) id<GroovesharkLoginViewControllerDelegate> delegate;

- (id)init;
- (id)initWithSession:(GroovesharkSession *)session callbackUrl:(NSURL *)callbackUrl;
- (id)initWithSession:(GroovesharkSession *)session callbackUrl:(NSURL *)callbackUrl delegate:(id<GroovesharkLoginViewControllerDelegate>)delegate;

@end

@protocol GroovesharkLoginViewControllerDelegate <NSObject>;

@optional

/**
 * Sent after the login view controller's webview started loading new page.
 * @param loginViewController The login view controller */
- (void)groovesharkLoginViewControllerDidStartLoading:(GroovesharkLoginViewController *)loginViewController;

/**
 * Sent after the login view controller's webview finished loading new page.
 * @param loginViewController The login view controller */
- (void)groovesharkLoginViewControllerDidFinishLoading:(GroovesharkLoginViewController *)loginViewController;

/**
 * Sent after the login view controller's webview has failed loading new page.
 * @param loginViewController The login view controller
 * @param error The error supplied by the webview */
- (void)groovesharkLoginViewController:(GroovesharkLoginViewController *)loginViewController didFailLoadingWithError:(NSError *)error;

/**
 * Sent after the user has chosen to cancel the login (with the Cancel button supplied by the login page)
 * You should dismiss the login view controller here.
 * @param loginViewController The login view controller  */
- (void)groovesharkLoginViewControllerDidCancel:(GroovesharkLoginViewController *)loginViewController;

/**
 * Sent after the user had a successful login.
 * The token is automatically saved in the attached session.
 * @param loginViewController The login view controller */
- (void)groovesharkLoginViewControllerDidLogin:(GroovesharkLoginViewController *)loginViewController;

/**
 * Sent after the user had an error while logging in. Most likely a token was received but authenticating with it returned an error.
 * @param loginViewController The login view controller
 * @param error The error returned */
- (void)groovesharkLoginViewController:(GroovesharkLoginViewController *)loginViewController didFailLoginWithError:(NSError *)error;

@end