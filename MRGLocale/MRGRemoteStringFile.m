//
//  MRGRemoteStringFile.m
//  MRGLocale
//
//  Created by Vincent Roy Chevalier on 2014-03-05.
//  Copyright (c) 2014 Mirego. All rights reserved.
//

#import "MRGRemoteStringFile.h"

@implementation MRGRemoteStringFile

@synthesize languageIdentifier = _languageIdentifier;

- (instancetype)initWithLangIdentifier:(NSString *)languageIdentifier url:(NSURL *)url
{
    self = [super init];
    if (self) {
        NSParameterAssert(languageIdentifier);
        NSParameterAssert(url);

        _languageIdentifier = languageIdentifier;
        _url = url;
    }
    return self;
}

///////////////////////////////////////////////////////////////
#pragma mark NSCoding Protocol
///////////////////////////////////////////////////////////////

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_languageIdentifier forKey:@"languageIdentifier"];
    [aCoder encodeObject:_url forKey:@"url"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        _languageIdentifier = [aDecoder decodeObjectForKey:@"languageIdentifier"];
        _url = [aDecoder decodeObjectForKey:@"url"];
    }
    return self;
}

@end
