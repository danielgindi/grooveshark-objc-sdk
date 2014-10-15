//
//  GroovesharkErrorCode.h
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

#pragma once

typedef NS_ENUM(NSUInteger, GroovesharkErrorCode) {
    kGroovesharkErrorNone = 0,
    kGroovesharkErrorCouldNotParse = 1,
    kGroovesharkErrorInvalidMethod = 2,
    kGroovesharkErrorInvalidParameter = 3,
    kGroovesharkErrorMissingParameter = 4,
    kGroovesharkErrorSSLRequired = 5,
    kGroovesharkErrorInvalidFormat = 6,
    kGroovesharkErrorSignatureRequired = 7,
    kGroovesharkErrorSignatureInvalid = 8,
    kGroovesharkErrorNoAccessRights = 9,
    kGroovesharkErrorRateLimitExceeded = 11,
    kGroovesharkErrorNoSourceID = 12,
    kGroovesharkErrorUserRegisterFailed = 99,
    kGroovesharkErrorUserAuthRequired = 100,
    kGroovesharkErrorUserAuthFailed = 101,
    kGroovesharkErrorUserPremiumRequired = 102,
    kGroovesharkErrorUserMobileSubscriptionRequired = 103,
    kGroovesharkErrorUserMobileTrialExpired = 104,
    kGroovesharkErrorUserTrialExpired = 105,
    kGroovesharkErrorUserDoesntExist = 200,
    kGroovesharkErrorSongDoesntExist = 201,
    kGroovesharkErrorArtistDoesntExist = 202,
    kGroovesharkErrorAlbumDoesntExist = 203,
    kGroovesharkErrorPlaylistDoesntExist = 204,
    kGroovesharkErrorSessionRequired = 300,
    kGroovesharkErrorLocationLookupFailed = 700,
    kGroovesharkErrorLocationMalformedCountry = 701,
    kGroovesharkErrorPlaylistDuplicateName = 800,
};
