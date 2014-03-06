//
//  MRGDynamicLocalRef.m
//  MRGLocale
//
//  Created by Vincent Roy Chevalier on 2014-03-05.
//  Copyright (c) 2014 Mirego. All rights reserved.
//

#import "MRGDynamicLocaleRef.h"

@implementation MRGDynamicLocaleRef

- (instancetype)initWithLangIdentifier:(NSString *)langIdentifier url:(NSURL *)url
{
    self = [super init];
    if (self) {
        NSParameterAssert(langIdentifier);
        NSParameterAssert(url);
        
        _langIdentifier = langIdentifier;
        _url = url;
    }
    return self;
}

///////////////////////////////////////////////////////////////
#pragma mark NSCoding Protocol
///////////////////////////////////////////////////////////////

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_langIdentifier forKey:@"_langIdentifier"];
    [aCoder encodeObject:_url forKey:@"_url"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        _langIdentifier = [aDecoder decodeObjectForKey:@"_langIdentifier"];
        _url = [aDecoder decodeObjectForKey:@"_url"];
    }
    return self;
}

@end
