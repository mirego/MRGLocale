//
//  MRGDynamicLocalRef.h
//  MRGLocale
//
//  Created by Vincent Roy Chevalier on 2014-03-05.
//  Copyright (c) 2014 Mirego. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MRGDynamicLocaleRef : NSObject <NSCoding>

@property (nonatomic, readonly) NSString *langIdentifier;
@property (nonatomic, readonly) NSURL *url;

- (id)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithLangIdentifier:(NSString *)langIdentifier url:(NSURL *)url;

@end
