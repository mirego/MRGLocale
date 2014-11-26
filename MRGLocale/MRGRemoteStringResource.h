//
// Created by Jean-Francois Morin on 14-11-21.
// Copyright (c) 2014 Mirego. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MRGRemoteStringResource <NSObject>

@property (nonatomic, readonly) NSString *languageIdentifier;

- (NSData *)fetchRemoteResource:(NSError **)error;

@end