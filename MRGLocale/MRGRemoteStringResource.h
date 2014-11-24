//
// Created by Jean-Francois Morin on 14-11-21.
// Copyright (c) 2014 Mirego. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MRGRemoteStringResource <NSObject, NSCoding>

@property (nonatomic, readonly) NSString *languageIdentifier;

@end