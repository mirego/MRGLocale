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

- (instancetype)initWithLanguageIdentifier:(NSString *)languageIdentifier url:(NSURL *)url
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

//------------------------------------------------------------------------------
#pragma mark Public
//------------------------------------------------------------------------------
- (NSData *)fetchRemoteResource:(NSError **)error
{
    NSData *localeData = [NSData dataWithContentsOfURL:self.url options:NSDataReadingUncached error:error];

    return localeData;
}

@end
