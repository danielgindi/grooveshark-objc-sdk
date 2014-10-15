//
//  GroovesharkSession.m
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

#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>

#import "GroovesharkSession.h"
#import "GroovesharkRequest.h"

#import <ifaddrs.h>
#import <arpa/inet.h>

#define API_HOST @"api.grooveshark.com"
#define API_ENDPOINT @"/ws3.php"

@implementation GroovesharkSession

#pragma mark - Shared

static NSString *s_synchronizer = @"GroovesharkSession:Synchronizer";
static GroovesharkSession *s_session = nil;

+ (GroovesharkSession *)sharedSession
{
    GroovesharkSession *session = s_session;
    if (!session)
    {
        @synchronized(s_synchronizer)
        {
            if (!s_session)
            {
                s_session = [[GroovesharkSession alloc] init];
            }
            session = s_session;
        }
    }
    return session;
}

+ (void)setSharedSession:(GroovesharkSession *)sharedSession
{
    @synchronized(s_synchronizer)
    {
        s_session = sharedSession;
    }
}

#pragma mark - Constructors

- (id)init
{
    self = [super init];
    if (self)
    {
        _requestTimeout = 15.0;
    }
    return self;
}

- (id)initWithKey:(NSString *)key secret:(NSString *)secret
{
    self = [self init];
    if (self)
    {
        self.key = key;
        self.secret = secret;
    }
    return self;
}

- (id)initWithKey:(NSString *)key secret:(NSString *)secret sessionID:(NSString *)sessionID
{
    self = [self init];
    if (self)
    {
        self.key = key;
        self.secret = secret;
        self.sessionID = sessionID;
    }
    return self;
}

+ (instancetype)sessionWithKey:(NSString *)key secret:(NSString *)secret
{
    return [[self alloc] initWithKey:key secret:secret];
}

+ (instancetype)sessionWithKey:(NSString *)key secret:(NSString *)secret sessionID:(NSString *)sessionID
{
    return [[self alloc] initWithKey:key secret:secret sessionID:sessionID];
}

#pragma mark - Session

- (void)pingServiceWithCompletion:(void(^)(BOOL success))completion
{
    [self callApiFunction:@"pingService" withParameters:nil https:NO completion:^(id result, NSError *error) {
        
        if (completion)
        {
            completion([result isKindOfClass:NSString.class]);
        }
        
    }];
}

- (void)startSessionWithCompletion:(void(^)(BOOL success, NSError *error))completion
{
    [self callApiFunction:@"startSession" withParameters:nil https:YES completion:^(id result, NSError *error) {
        
        if (completion)
        {
            BOOL success = NO;
            
            if (!error && result && result[@"sessionID"])
            {
                self.sessionID = result[@"sessionID"];
                success = YES;
            }
            
            completion(success, error);
        }
        
    }];
}

- (void)logoutWithCompletion:(void(^)(BOOL success, NSError *error))completion
{
    [self callApiFunction:@"logout" withParameters:nil https:NO completion:^(id result, NSError *error) {
        
        if (completion)
        {
            BOOL success = !error && result && [result[@"success"] boolValue];
            
            if (success)
            {
                self.loggedUserEmail = nil;
                self.loggedUserInfo = nil;
            }
            
            completion(success, error);
        }
        
    }];
}

- (void)authenticateWithUsername:(NSString *)username password:(NSString *)password completion:(void(^)(BOOL success, NSString *email, GroovesharkUserInfo *userInfo, NSError *error))completion
{
    NSDictionary *parameters = @{@"login": username, @"password": [GroovesharkSession md5OfString:password]};
    [self callApiFunction:@"authenticate" withParameters:parameters https:YES completion:^(id result, NSError *error) {
        
        if (completion)
        {
            BOOL success = result && [result[@"success"] boolValue];
            
            NSString *userEmail = result[@"Email"];
            GroovesharkUserInfo *userInfo = nil;
            
            if (success)
            {
                userInfo = [GroovesharkUserInfo userInfoWithValuesInDictionary:result];
                self.loggedUserEmail = userEmail;
                self.loggedUserInfo = userInfo;
            }
            
            completion(success, userEmail, userInfo, error);
        }
        
    }];
}

- (void)authenticateWithToken:(NSString *)token completion:(void (^)(BOOL success, NSString *email, GroovesharkUserInfo *userInfo, NSError *error))completion
{
    NSDictionary *parameters = @{@"token": token};
    [self callApiFunction:@"authenticateToken" withParameters:parameters https:YES completion:^(id result, NSError *error) {
        
        if (completion)
        {
            BOOL success = result && [result[@"success"] boolValue];
            
            NSString *userEmail = result[@"Email"];
            GroovesharkUserInfo *userInfo = nil;
            
            if (success)
            {
                userInfo = [GroovesharkUserInfo userInfoWithValuesInDictionary:result];
                self.loggedUserEmail = userEmail;
                self.loggedUserInfo = userInfo;
            }
            
            completion(success, userEmail, userInfo,  error);
        }
        
    }];
}

#pragma mark - Country

- (void)getCountryForIP:(NSString *)ip completion:(void (^)(NSDictionary *country, NSError *error))completion
{
    NSDictionary *parameters = @{@"ip": ip};
    [self callApiFunction:@"getCountry" withParameters:parameters https:NO completion:^(id result, NSError *error) {
        
        if (!error && result && !self.defaultCountry)
        {
            self.defaultCountry = result;
        }
        
        if (completion)
        {
            completion(result, error);
        }
        
    }];
}

- (void)getCountryForCurrentIPWithCompletion:(void (^)(NSDictionary *country, NSError *error))completion
{
    static NSString *s_cachedIPAddress = nil;
    NSString *ipAddress = s_cachedIPAddress;
    if (!ipAddress)
    {
        s_cachedIPAddress = ipAddress = [GroovesharkSession currentIPAddress];
    }
    
    if (!ipAddress)
    {
        ipAddress = @"8.8.8.8";
    }
    
    [self getCountryForIP:ipAddress completion:completion];
}

#pragma mark - User

- (void)getUserInfoWithCompletion:(void (^)(GroovesharkUserInfo *userInfo, NSError *error))completion
{
    [self callApiFunction:@"getUserInfo" withParameters:nil https:NO completion:^(id result, NSError *error) {
        
        if (completion)
        {
            completion(error ? nil : [GroovesharkUserInfo userInfoWithValuesInDictionary:result], error);
        }
        
    }];
}

- (void)getUserInfoForUser:(int64_t)userID completion:(void (^)(GroovesharkUserInfo *userInfo, NSError *error))completion
{
    NSDictionary *parameters = @{@"userID": @(userID)};
    [self callApiFunction:@"getUserInfoFromUserID" withParameters:parameters https:NO completion:^(id result, NSError *error) {
        
        if (completion)
        {
            completion(error ? nil : [GroovesharkUserInfo userInfoWithValuesInDictionary:result], error);
        }
        
    }];
}

#pragma mark - Songs

- (void)getUserLibrarySongsWithLimit:(NSInteger)limit
                                page:(NSInteger)page
                          completion:(void (^)(NSArray *songs, BOOL hasMore, NSInteger maxSongs, NSDate *libraryModified, NSError *error))completion
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    if (limit)
    {
        parameters[@"limit"] = @(limit);
    }
    if (page)
    {
        parameters[@"page"] = @(page);
    }
    
    [self callApiFunction:@"getUserLibrarySongs" withParameters:parameters https:NO completion:^(id result, NSError *error) {
        
        if (completion)
        {
            NSMutableArray *songs = nil;
            if (!error && result && result[@"songs"])
            {
                songs = [[NSMutableArray alloc] init];
                for (NSDictionary *info in result[@"songs"])
                {
                    [songs addObject:[GroovesharkLibrarySongInfo songInfoWithValuesInDictionary:info]];
                }
            }
            
            completion(songs, [result[@"hasMore"] boolValue], [result[@"maxSongs"] integerValue], [NSDate dateWithTimeIntervalSince1970:[result[@"libraryTSModified"] doubleValue]], error);
        }
        
    }];
}

- (void)getSongURLFromSongID:(int64_t)songID completion:(void(^)(NSString *url, NSError *error))completion
{
    NSDictionary *parameters = @{@"songID": @(songID)};
    [self callApiFunction:@"getSongURLFromSongID" withParameters:parameters https:NO completion:^(id result, NSError *error) {
        
        if (completion)
        {
            completion((result && result[@"url"]) ? result[@"url"] : nil, error);
        }
        
    }];
}

- (void)getSongsInfoForSongIDs:(NSArray *)songIDs completion:(void(^)(NSDictionary *songs, NSError *error))completion
{
    if (songIDs.count == 0)
    {
        completion([[NSDictionary alloc] init], nil);
    }
    else
    {
        NSDictionary *parameters = @{@"songIDs": songIDs};
        [self callApiFunction:@"getSongsInfo" withParameters:parameters https:NO completion:^(id result, NSError *error) {
            
            if (completion)
            {
                NSMutableDictionary *songs = nil;
                if (!error && result && result[@"songs"])
                {
                    songs = [[NSMutableDictionary alloc] init];
                    for (NSDictionary *info in result[@"songs"])
                    {
                        GroovesharkSongInfo *songInfo = [GroovesharkSongInfo songInfoWithValuesInDictionary:info];
                        songs[@(songInfo.songID)] = songInfo;
                    }
                }
                
                completion(songs, error);
            }
            
        }];
    }
}

- (void)getSongInfoForSongID:(int64_t)songID completion:(void(^)(GroovesharkSongInfo *songInfo, NSError *error))completion
{
    [self getSongsInfoForSongIDs:@[@(songID)] completion:^(NSDictionary *songs, NSError *error) {
        
        NSNumber *key = @(songID);
        
        if (songs[key])
        {
            completion(songs[key], nil);
        }
        else
        {
            completion(nil, error);
        }
        
    }];
}

- (void)getDoesSongExist:(int64_t)songID completion:(void(^)(BOOL exists, NSError *error))completion
{
    NSDictionary *parameters = @{@"songID": @(songID)};
    [self callApiFunction:@"getDoesSongExist" withParameters:parameters https:NO completion:^(id result, NSError *error) {
        
        if (completion)
        {
            completion([result boolValue], error);
        }
        
    }];
}

- (void)getSongSearchResultsByQuery:(NSString *)query
                            country:(NSDictionary *)country
                              limit:(NSInteger)limit
                             offset:(NSInteger)offset
                         completion:(void (^)(NSArray *songs, NSError *error))completion
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    parameters[@"query"] = query;
    parameters[@"country"] = country ? country : self.defaultCountry;
    if (limit)
    {
        parameters[@"limit"] = @(limit);
    }
    if (offset)
    {
        parameters[@"offset"] = @(offset);
    }
    
    [self callApiFunction:@"getSongSearchResults" withParameters:parameters https:NO completion:^(id result, NSError *error) {
        
        if (completion)
        {
            NSMutableArray *songs = nil;
            if (!error && result && result[@"songs"])
            {
                songs = [[NSMutableArray alloc] init];
                for (NSDictionary *info in result[@"songs"])
                {
                    [songs addObject:[GroovesharkSongInfo songInfoWithValuesInDictionary:info]];
                }
            }
            
            completion(songs, error);
        }
        
    }];
}

#pragma mark - Artists

- (void)getArtistsInfoForArtistIDs:(NSArray *)artistIDs completion:(void(^)(NSDictionary *artists, NSError *error))completion
{
    if (artistIDs.count == 0)
    {
        completion([[NSDictionary alloc] init], nil);
    }
    else
    {
        NSDictionary *parameters = @{@"artistIDs": artistIDs};
        [self callApiFunction:@"getArtistsInfo" withParameters:parameters https:NO completion:^(id result, NSError *error) {
            
            if (completion)
            {
                NSMutableDictionary *artists = nil;
                if (!error && result && result[@"artists"])
                {
                    artists = [[NSMutableDictionary alloc] init];
                    for (NSDictionary *info in result[@"artists"])
                    {
                        GroovesharkArtistInfo *artistInfo = [GroovesharkArtistInfo artistInfoWithValuesInDictionary:info];
                        artists[@(artistInfo.artistID)] = artistInfo;
                    }
                }
                
                completion(artists, error);
            }
            
        }];
    }
}

- (void)getArtistInfoForArtistID:(int64_t)artistID completion:(void(^)(GroovesharkArtistInfo *artistInfo, NSError *error))completion
{
    [self getArtistsInfoForArtistIDs:@[@(artistID)] completion:^(NSDictionary *artists, NSError *error) {
        
        NSNumber *key = @(artistID);
        
        if (artists[key])
        {
            completion(artists[key], nil);
        }
        else
        {
            completion(nil, error);
        }
        
    }];
}

- (void)getDoesArtistExist:(int64_t)artistID completion:(void(^)(BOOL exists, NSError *error))completion
{
    NSDictionary *parameters = @{@"artistID": @(artistID)};
    [self callApiFunction:@"getDoesArtistExist" withParameters:parameters https:NO completion:^(id result, NSError *error) {
        
        if (completion)
        {
            completion([result boolValue], error);
        }
        
    }];
}

- (void)getArtistSearchResultsByQuery:(NSString *)query
                                limit:(NSInteger)limit
                           completion:(void (^)(NSArray *artists, BOOL hasPrevPage, BOOL hasNextPage, NSInteger pageCount, NSError *error))completion
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    parameters[@"query"] = query;
    if (limit)
    {
        parameters[@"limit"] = @(limit);
    }
    
    [self callApiFunction:@"getArtistSearchResults" withParameters:parameters https:NO completion:^(id result, NSError *error) {
        
        if (completion)
        {
            NSDictionary *pager = result[@"pager"];
            
            NSMutableArray *artists = nil;
            if (!error && result && result[@"artists"])
            {
                artists = [[NSMutableArray alloc] init];
                for (NSDictionary *info in result[@"artists"])
                {
                    [artists addObject:[GroovesharkArtistInfo artistInfoWithValuesInDictionary:info]];
                }
            }
            
            completion(artists, [pager[@"hasPrevPage"] boolValue], [pager[@"hasNextPage"] boolValue], [pager[@"numPages"] integerValue], error);
        }
        
    }];
}

#pragma mark - Albums

- (void)getAlbumsInfoForAlbumIDs:(NSArray *)albumIDs completion:(void(^)(NSDictionary *albums, NSError *error))completion
{
    if (albumIDs.count == 0)
    {
        completion([[NSDictionary alloc] init], nil);
    }
    else
    {
        NSDictionary *parameters = @{@"albumIDs": albumIDs};
        [self callApiFunction:@"getAlbumsInfo" withParameters:parameters https:NO completion:^(id result, NSError *error) {
            
            if (completion)
            {
                NSMutableDictionary *albums = nil;
                if (!error && result && result[@"albums"])
                {
                    albums = [[NSMutableDictionary alloc] init];
                    for (NSDictionary *info in result[@"albums"])
                    {
                        GroovesharkAlbumInfo *albumInfo = [GroovesharkAlbumInfo albumInfoWithValuesInDictionary:info];
                        albums[@(albumInfo.albumID)] = albumInfo;
                    }
                }
                
                completion(albums, error);
            }
            
        }];
    }
}

- (void)getAlbumInfoForAlbumID:(int64_t)albumID completion:(void(^)(GroovesharkAlbumInfo *albumInfo, NSError *error))completion
{
    [self getAlbumsInfoForAlbumIDs:@[@(albumID)] completion:^(NSDictionary *albums, NSError *error) {
        
        NSNumber *key = @(albumID);
        
        if (albums[key])
        {
            completion(albums[key], nil);
        }
        else
        {
            completion(nil, error);
        }
        
    }];
}

- (void)getDoesAlbumExist:(int64_t)albumID completion:(void(^)(BOOL exists, NSError *error))completion
{
    NSDictionary *parameters = @{@"albumID": @(albumID)};
    [self callApiFunction:@"getDoesAlbumExist" withParameters:parameters https:NO completion:^(id result, NSError *error) {
        
        if (completion)
        {
            completion([result boolValue], error);
        }
        
    }];
}

- (void)getAlbumSearchResultsByQuery:(NSString *)query
                               limit:(NSInteger)limit
                          completion:(void (^)(NSArray *albums, BOOL hasPrevPage, BOOL hasNextPage, NSInteger pageCount, NSError *error))completion
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    parameters[@"query"] = query;
    if (limit)
    {
        parameters[@"limit"] = @(limit);
    }
    
    [self callApiFunction:@"getAlbumSearchResults" withParameters:parameters https:NO completion:^(id result, NSError *error) {
        
        if (completion)
        {
            NSDictionary *pager = result[@"pager"];
            
            NSMutableArray *albums = nil;
            if (!error && result && result[@"albums"])
            {
                albums = [[NSMutableArray alloc] init];
                for (NSDictionary *info in result[@"albums"])
                {
                    [albums addObject:[GroovesharkAlbumInfo albumInfoWithValuesInDictionary:info]];
                }
            }
            
            completion(albums, [pager[@"hasPrevPage"] boolValue], [pager[@"hasNextPage"] boolValue], [pager[@"numPages"] integerValue], error);
        }
        
    }];
}

#pragma mark - Favorites

- (void)getUserFavoriteSongsWithLimit:(NSInteger)limit completion:(void (^)(NSArray *songs, NSError *error))completion
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    if (limit)
    {
        parameters[@"limit"] = @(limit);
    }
    
    [self callApiFunction:@"getUserFavoriteSongs" withParameters:parameters https:NO completion:^(id result, NSError *error) {
        
        if (completion)
        {
            NSMutableArray *songs = nil;
            if (!error && result && result[@"songs"])
            {
                songs = [[NSMutableArray alloc] init];
                for (NSDictionary *info in result[@"songs"])
                {
                    [songs addObject:[GroovesharkFavoriteSongInfo songInfoWithValuesInDictionary:info]];
                }
            }
        
            completion(songs, error);
        }
        
    }];
}

- (void)addUserFavoriteSong:(int64_t)songID completion:(void(^)(BOOL success, NSError *error))completion
{
    NSDictionary *parameters = @{@"songID": @(songID)};
    [self callApiFunction:@"addUserFavoriteSong" withParameters:parameters https:NO completion:^(id result, NSError *error) {
        
        BOOL success = result && [result[@"success"] boolValue];
        
        if (completion)
        {
            completion(success, error);
        }
        
    }];
}

- (void)removeUserFavoriteSong:(int64_t)songID completion:(void(^)(BOOL success, NSError *error))completion
{
    [self removeUserFavoriteSongIDs:@[@(songID)] completion:completion];
}

- (void)removeUserFavoriteSongIDs:(NSArray *)songIDs completion:(void(^)(BOOL success, NSError *error))completion
{
    if (songIDs.count == 0)
    {
        completion(YES, nil);
    }
    else
    {
        NSDictionary *parameters = @{@"songIDs": songIDs};
        [self callApiFunction:@"removeUserFavoriteSongs" withParameters:parameters https:NO completion:^(id result, NSError *error) {
            
            BOOL success = result && [result[@"success"] boolValue];
            
            if (completion)
            {
                completion(success, error);
            }
            
        }];
    }
}

#pragma mark - Playlists

- (void)getPlaylistSearchResultsByQuery:(NSString *)query
                                  limit:(NSInteger)limit
                             completion:(void (^)(NSArray *playlists, BOOL hasPrevPage, BOOL hasNextPage, NSInteger pageCount, NSError *error))completion;
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    parameters[@"query"] = query;
    if (limit)
    {
        parameters[@"limit"] = @(limit);
    }
    
    [self callApiFunction:@"getPlaylistSearchResults" withParameters:parameters https:NO completion:^(id result, NSError *error) {
        
        if (completion)
        {
            NSDictionary *pager = result[@"pager"];
            
            NSMutableArray *playlists = nil;
            if (!error && result && result[@"playlists"])
            {
                playlists = [[NSMutableArray alloc] init];
                for (NSDictionary *info in result[@"playlists"])
                {
                    [playlists addObject:[GroovesharkUserPlaylistInfo playlistInfoWithValuesInDictionary:info]];
                }
            }
            
            completion(playlists, [pager[@"hasPrevPage"] boolValue], [pager[@"hasNextPage"] boolValue], [pager[@"numPages"] integerValue], error);
        }
        
    }];
}

- (void)getUserPlaylistsWithLimit:(NSInteger)limit completion:(void (^)(NSArray *playlists, NSError *error))completion
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    if (limit)
    {
        parameters[@"limit"] = @(limit);
    }
    
    [self callApiFunction:@"getUserPlaylists" withParameters:parameters https:NO completion:^(id result, NSError *error) {
        
        if (completion)
        {
            NSMutableArray *playlists = nil;
            if (!error && result && result[@"playlists"])
            {
                playlists = [[NSMutableArray alloc] init];
                for (NSDictionary *info in result[@"playlists"])
                {
                    [playlists addObject:[GroovesharkPlaylistInfo playlistInfoWithValuesInDictionary:info]];
                }
            }
        
            completion(playlists, error);
        }
        
    }];
}

- (void)getUserPlaylistsForUser:(int64_t)userID
                          limit:(NSInteger)limit
                     completion:(void (^)(NSArray *playlists, NSError *error))completion
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    if (limit)
    {
        parameters[@"limit"] = @(limit);
    }
    parameters[@"userID"] = @(userID);
    
    [self callApiFunction:@"getUserPlaylistsByUserID" withParameters:parameters https:NO completion:^(id result, NSError *error) {
        
        if (completion)
        {
            NSMutableArray *playlists = nil;
            if (!error && result && result[@"playlists"])
            {
                playlists = [[NSMutableArray alloc] init];
                for (NSDictionary *info in result[@"playlists"])
                {
                    [playlists addObject:[GroovesharkPlaylistInfo playlistInfoWithValuesInDictionary:info]];
                }
            }
            
            completion(playlists, error);
        }
        
    }];
}

#pragma mark - Streaming

- (void)getStreamURLForSongID:(int64_t)songID
                   lowBitrate:(BOOL)lowBitrate
                      country:(NSDictionary *)country
                   completion:(void (^)(NSString *url, NSString *streamKey, int64_t streamServerId, NSTimeInterval duration, NSError *error))completion
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    if (lowBitrate)
    {
        parameters[@"lowBitrate"] = @(YES);
    }
    parameters[@"songID"] = @(songID);
    parameters[@"country"] = country ? country : self.defaultCountry;
    
    [self callApiFunction:@"getStreamKeyStreamServer" withParameters:parameters https:NO completion:^(id result, NSError *error) {
        
        if (completion)
        {
            if (!error && result[@"StreamKey"])
            {
                completion(result[@"url"], result[@"StreamKey"], [result[@"StreamServerID"] longLongValue], [result[@"uSecs"] longLongValue] / 1000000.0, error);
            }
            else
            {
                completion(nil, nil, 0L, 0.0, error);
            }
        }
        
    }];
}

- (void)getSubscriberStreamURLForSongID:(int64_t)songID
                      subscriberTrialID:(NSNumber *)uniqueTrialID
                             lowBitrate:(BOOL)lowBitrate
                                country:(NSDictionary *)country
                             completion:(void (^)(NSString *url, NSString *streamKey, int64_t streamServerId, NSTimeInterval duration, NSError *error))completion
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    if (lowBitrate)
    {
        parameters[@"lowBitrate"] = @(YES);
    }
    if (uniqueTrialID)
    {
        parameters[@"uniqueID"] = uniqueTrialID;
    }
    parameters[@"songID"] = @(songID);
    parameters[@"country"] = country ? country : self.defaultCountry;
    
    [self callApiFunction:@"getSubscriberStreamKey" withParameters:parameters https:NO completion:^(id result, NSError *error) {
        
        if (completion)
        {
            if (!error && result[@"StreamKey"])
            {
                completion(result[@"url"], result[@"StreamKey"], [result[@"StreamServerID"] longLongValue], [result[@"uSecs"] longLongValue] / 1000000.0, error);
            }
            else
            {
                completion(nil, nil, 0L, 0.0, error);
            }
        }
        
    }];
}

- (void)getSubscriberStreamURLForSongID:(int64_t)songID
                             lowBitrate:(BOOL)lowBitrate
                                country:(NSDictionary *)country
                             completion:(void (^)(NSString *url, NSString *streamKey, int64_t streamServerId, NSTimeInterval duration, NSError *error))completion
{
    return [self getSubscriberStreamURLForSongID:songID subscriberTrialID:nil lowBitrate:lowBitrate country:country completion:completion];
}

- (void)markStreamKeyOver30Seconds:(NSString *)streamKey
                  onStreamServerID:(int64_t)streamServerID
                        completion:(void (^)(BOOL, NSError *))completion
{
    if (!streamKey.length)
    {
        if (completion)
        {
            completion(NO, [NSError errorWithDomain:API_HOST code:kGroovesharkErrorMissingParameter userInfo:@{@"code": @(kGroovesharkErrorMissingParameter), @"parameter": @"streamKey"}]);
        }
    }
    else
    {
        NSDictionary *parameters = @{@"streamKey": streamKey, @"streamServerID": @(streamServerID)};
        [self callApiFunction:@"markStreamKeyOver30Secs" withParameters:parameters https:NO completion:^(id result, NSError *error) {
            
            BOOL success = result && [result[@"success"] boolValue];
            
            if (completion)
            {
                completion(success, error);
            }
            
        }];
    }
}

- (void)markStreamKey:(NSString *)streamKey
donePlayingWithSongID:(int64_t)songID
     onStreamServerID:(int64_t)streamServerID
           completion:(void (^)(BOOL success, NSError *error))completion
{
    if (!streamKey.length)
    {
        if (completion)
        {
            completion(NO, [NSError errorWithDomain:API_HOST code:kGroovesharkErrorMissingParameter userInfo:@{@"code": @(kGroovesharkErrorMissingParameter), @"parameter": @"streamKey"}]);
        }
    }
    else
    {
        NSDictionary *parameters = @{@"streamKey": streamKey, @"songID": @(songID), @"streamServerID": @(streamServerID)};
        [self callApiFunction:@"markSongComplete" withParameters:parameters https:NO completion:^(id result, NSError *error) {
            
            BOOL success = result && [result[@"success"] boolValue];
            
            if (completion)
            {
                completion(success, error);
            }
            
        }];
    }
}

#pragma mark - Generic

- (NSString *)signatureForRequestData:(NSData *)requestData
{
    return [GroovesharkSession hmacMd5ForData:requestData withSecret:self.secret];
}

- (void)callApiFunction:(NSString *)functionName
         withParameters:(NSDictionary *)parameters
                  https:(BOOL)https
             completion:(void(^)(id result, NSError *error))completion
{
    NSMutableDictionary *payload = [[NSMutableDictionary alloc] init];
    
    payload[@"method"] = functionName;
    payload[@"parameters"] = parameters == nil ? [[NSDictionary alloc] init] : parameters;
    
    NSMutableDictionary *header = [[NSMutableDictionary alloc] init];
    header[@"wsKey"] = self.key == nil ? @"" : self.key;
    if (self.sessionID)
    {
        header[@"sessionID"] = self.sessionID;
    }
    payload[@"header"] = header;
    
    NSData *postBody = [NSJSONSerialization dataWithJSONObject:payload options:0 error:nil];
    
    NSMutableString *urlString = [[NSMutableString alloc] init];
    [urlString appendString:(https ? @"https://" : @"http://")];
    [urlString appendString:API_HOST API_ENDPOINT];
    [urlString appendString:@"?sig="];
    [urlString appendString:[[self signatureForRequestData:postBody] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:self.requestTimeout];
    urlRequest.HTTPMethod = @"POST";
    urlRequest.HTTPBody = postBody;
    [urlRequest setValue:@"Content-Type" forHTTPHeaderField:@"application/json"];
    
    [GroovesharkRequest requestWithUrlRequest:urlRequest completion:^(NSURLRequest *originalRequest, NSURLRequest *currentRequest, NSURLResponse *response, NSData *responseBody) {
        
        NSError *error = nil;
        
        NSDictionary *jsonResponse = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:responseBody options:NSJSONReadingAllowFragments error:&error];
        
        if (jsonResponse && jsonResponse[@"errors"])
        {
            NSArray *errors = jsonResponse[@"errors"];
            if (errors && errors.count)
            {
                error = [NSError errorWithDomain:API_HOST code:[errors[0][@"code"] intValue] userInfo:
                        @{
                          @"code": errors[0][@"code"],
                          @"message": errors[0][@"message"],
                          @"errors": errors
                          }];
            }
        }
        
        if (completion)
        {
            completion(jsonResponse[@"result"], error);
        }
        
    } fail:^(NSError *error) {
        
        if (completion)
        {
            completion(nil, error);
        }
        
    } start:YES];
}

+ (NSDateFormatter *)dateFormatterForGroovesharkTimestamp;
{
    static NSTimeZone *s_timeZone = nil;
    static NSDateFormatter *s_dateFormatter = nil;
    if (!s_timeZone)
    {
        s_timeZone = [NSTimeZone timeZoneForSecondsFromGMT:-14400];
    }
    if (!s_dateFormatter)
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.timeZone = s_timeZone;
        dateFormatter.dateStyle = NSDateFormatterNoStyle;
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        s_dateFormatter = dateFormatter;
    }
    return s_dateFormatter;
}

+ (NSDate *)dateFromGroovesharkTimestamp:(NSString *)timestamp
{
    return timestamp.length ? [self.dateFormatterForGroovesharkTimestamp dateFromString:timestamp] : nil;
}

#pragma mark - Utilities

+ (NSString *)currentIPAddress
{
    NSString *address = nil;
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *pInterface = NULL;
    
    int success = getifaddrs(&interfaces);
    if (success == 0)
    {
        pInterface = interfaces;
        while (pInterface != NULL)
        {
            if (pInterface->ifa_addr->sa_family == AF_INET)
            {
                if ([[NSString stringWithUTF8String:pInterface->ifa_name] isEqualToString:@"en0"])
                {
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)pInterface->ifa_addr)->sin_addr)];
                }
            }
            
            pInterface = pInterface->ifa_next;
        }
    }
    
    if (interfaces)
    {
        freeifaddrs(interfaces);
    }
    
    return address;
}

+ (NSString *)md5OfString:(NSString *)string
{
    static unsigned char s_hexCharMap[] = "0123456789abcdef";
    
    const char *utf8String = string.UTF8String;
    unsigned char md5[CC_MD5_DIGEST_LENGTH];
    CC_MD5(utf8String, (unsigned int)strlen(utf8String), md5);
    char md5string[2 * CC_MD5_DIGEST_LENGTH + 1];
    
    char *p = md5string;
    unsigned char c;
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
    {
        c = md5[i];
        *(p++) = s_hexCharMap[c >> 4];
        *(p++) = s_hexCharMap[c & 0x0F];
    }
    *p = 0;
    
    return [NSString stringWithUTF8String:md5string];
}

+ (NSString *)hmacMd5ForData:(NSData *)data withSecret:(NSString *)secret
{
    static unsigned char s_hexCharMap[] = "0123456789abcdef";
    
    CCHmacContext ctx;
    const char *key = secret.UTF8String;
    unsigned char md5[CC_MD5_DIGEST_LENGTH];
    char md5string[2 * CC_MD5_DIGEST_LENGTH + 1];
    
    CCHmacInit(&ctx, kCCHmacAlgMD5, key, strlen(key));
    CCHmacUpdate(&ctx, data.bytes, (size_t)data.length);
    CCHmacFinal(&ctx, md5);
    
    char *p = md5string;
    unsigned char c;
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
    {
        c = md5[i];
        *(p++) = s_hexCharMap[c >> 4];
        *(p++) = s_hexCharMap[c & 0x0F];
    }
    *p = 0;
    
    return [NSString stringWithUTF8String:md5string];
}

#pragma mark - Images

+ (int)imageSizeForMinimumSize:(int)size
{
    if (size <= 30)
    {
        size = 30;
    }
    else if (size <= 40)
    {
        size = 40;
    }
    else if (size <= 50)
    {
        size = 50;
    }
    else if (size <= 70)
    {
        size = 70;
    }
    else if (size <= 80)
    {
        size = 80;
    }
    else if (size <= 90)
    {
        size = 90;
    }
    else if (size <= 120)
    {
        size = 120;
    }
    else if (size <= 200)
    {
        size = 200;
    }
    else if (size <= 500)
    {
        size = 500;
    }
    else
    {
        size = 0;
    }
    
    return size;
}

+ (NSString *)urlForArtistImageNamed:(NSString *)imageName minWidth:(int)minWidth maxWidth:(int)maxWidth
{
    NSMutableString *url = [@"http://images.grooveshark.com/static/artist/" mutableCopy];
    
    int size = (minWidth <= 0 || maxWidth <= 0) ? 0 : MAX(minWidth, maxWidth);
    size = [self imageSizeForMinimumSize:size];
    if (size > 0)
    {
        [url appendFormat:@"%i_", size];
    }
    [url appendString:imageName];
    
    return url;
}

+ (NSString *)urlForAlbumImageNamed:(NSString *)imageName minWidth:(int)minWidth maxWidth:(int)maxWidth
{
    NSMutableString *url = [@"http://images.grooveshark.com/static/albums/" mutableCopy];
    
    int size = (minWidth <= 0 || maxWidth <= 0) ? 0 : MAX(minWidth, maxWidth);
    size = [self imageSizeForMinimumSize:size];
    if (size > 0)
    {
        [url appendFormat:@"%i_", size];
    }
    [url appendString:imageName];
    
    return url;
}

+ (NSString *)urlForPlaylistImageNamed:(NSString *)imageName minWidth:(int)minWidth maxWidth:(int)maxWidth
{
    NSMutableString *url = [@"http://images.grooveshark.com/static/playlists/" mutableCopy];
    
    int size = (minWidth <= 0 || maxWidth <= 0) ? 0 : MAX(minWidth, maxWidth);
    size = [self imageSizeForMinimumSize:size];
    if (size > 0)
    {
        [url appendFormat:@"%i_", size];
    }
    [url appendString:imageName];
    
    return url;
}

@end
