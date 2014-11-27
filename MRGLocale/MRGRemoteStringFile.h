//
//  MRGRemoteStringFile.h
//  MRGLocale
//
//  Created by Vincent Roy Chevalier on 2014-03-05.
//  Copyright (c) 2014 Mirego. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MRGRemoteStringResource.h"

@interface MRGRemoteStringFile : NSObject <MRGRemoteStringResource>

@property (nonatomic, readonly) NSURL *url;

- (id)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithLanguageIdentifier:(NSString *)languageIdentifier url:(NSURL *)url;

@end
