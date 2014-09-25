//
//  MRGLocale.h
//  MRGLocale
//
//  Created by Vincent Roy Chevalier on 2014-03-05.
//  Copyright (c) 2014 Mirego. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MRGDynamicLocaleRef.h"

@interface MRGLocale : NSObject

+ (MRGLocale *)sharedInstance;

- (NSString *)localizedStringForKey:(NSString *)key;
- (NSString *)localizedStringForKey:(NSString *)key inTable:(NSString *)tableName;

+ (NSString *)systemLangIdentifier;
- (MRGDynamicLocaleRef *)currentLocaleRef;

- (void)setDefaultDynamicLocaleRefs:(NSArray *)localeRefs;
- (void)addLocaleRef:(MRGDynamicLocaleRef *)localeRef;

- (void)refreshLocalesWithCompletion:(void(^)())completion;

@end

#define MRGString(key) \
[[MRGLocale sharedInstance] localizedStringForKey:(key)]

#define MRGStringFromTable(key, table) \
[[MRGLocale sharedInstance] localizedStringForKey:(key) inTable:(table)]
