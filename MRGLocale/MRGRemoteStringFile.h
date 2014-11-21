//
//  MRGRemoteStringFile.h
//  MRGLocale
//
//  Created by Vincent Roy Chevalier on 2014-03-05.
//  Copyright (c) 2014 Mirego. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MRGRemoteStringResource.h"

@interface MRGRemoteStringFile : NSObject <NSCoding, MRGRemoteStringResource>

@property (nonatomic, readonly) NSURL *url;

- (id)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithLangIdentifier:(NSString *)languageIdentifier url:(NSURL *)url;

@end
