//
// Created by Jean-Francois Morin on 14-11-21.
// Copyright (c) 2014 Mirego. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MRGRemoteStringResource.h"


@interface MRGRemoteAccentString : NSObject <MRGRemoteStringResource>

@property (nonatomic, readonly) NSString *apiKey;

- (id)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithLanguageIdentifier:(NSString *)languageIdentifier apiKey:(NSString *)apiKey;


@end