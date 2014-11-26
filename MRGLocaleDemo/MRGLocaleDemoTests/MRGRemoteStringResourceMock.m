//
// Created by Jean-Francois Morin on 14-11-24.
// Copyright (c) 2014 Mirego. All rights reserved.
//

#import "MRGRemoteStringResourceMock.h"
#import "MRGLocale.h"


@implementation MRGRemoteStringResourceMock

//------------------------------------------------------------------------------
#pragma mark Public
//------------------------------------------------------------------------------
- (NSData *)fetchRemoteResource:(NSError **)error
{
    NSData* data = [@"\"message\" = \"It's working\";" dataUsingEncoding:NSUTF8StringEncoding];
    return data;
}

- (NSString *)languageIdentifier
{
    return [MRGLocale systemLangIdentifier];
}

@end