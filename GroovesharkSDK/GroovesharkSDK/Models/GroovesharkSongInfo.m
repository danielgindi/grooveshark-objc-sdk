//
//  GroovesharkSongInfo.m
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

#import "GroovesharkSongInfo.h"

@implementation GroovesharkSongInfo

- (id)initWithValuesInDictionary:(NSDictionary *)values
{
    self = [super init];
    if (self)
    {
        if (values[@"SongID"])
        {
            self.songID = [values[@"SongID"] longLongValue];
        }
        
        self.songName = values[@"SongName"];
        
        if (values[@"ArtistID"])
        {
            self.artistID = [values[@"ArtistID"] longLongValue];
        }
        
        self.artistName = values[@"ArtistName"];
        
        self.coverArtFilename = values[@"CoverArtFilename"];
        
        if (values[@"Popularity"])
        {
            self.popularity = [values[@"Popularity"] longLongValue];
        }
        
        if (values[@"IsLowBitrateAvailable"])
        {
            self.isLowBitrateAvailable = [values[@"IsLowBitrateAvailable"] boolValue];
        }
        
        if (values[@"IsVerified"])
        {
            self.isVerified = [values[@"IsVerified"] boolValue];
        }
        
        if (values[@"Flags"])
        {
            self.flags = [values[@"Flags"] intValue];
        }
    }
    return self;
}

+ (instancetype)songInfoWithValuesInDictionary:(NSDictionary *)values
{
    return [[self alloc] initWithValuesInDictionary:values];
}

@end
