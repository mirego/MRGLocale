//
//  MRGLocale.h
//  MRGLocale
//
//  Created by Vincent Roy Chevalier on 2014-03-05.
//  Copyright (c) 2014 Mirego. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MRGRemoteStringFile;

@interface MRGLocale : NSObject

+ (MRGLocale *)sharedInstance;

// Language
+ (NSString *)systemLangIdentifier;

- (NSString *)getLanguageISO639Identifier;
- (void)setLanguageBundleWithLanguageISO639Identifier:(NSString *)languageIdentifier;

// Strings
- (NSString *)localizedStringForKey:(NSString *)key;
- (NSString *)localizedStringForKey:(NSString *)key inTable:(NSString *)tableName;

// Remote strings
- (MRGRemoteStringFile *)currentRemoteStringResource;

- (void)setDefaultRemoteStringResources:(NSArray *)remoteStringResources;
- (void)addRemoteStringResource:(MRGRemoteStringFile *)remoteStringResource;

- (void)refreshRemoteStringResourcesWithCompletion:(void(^)())completion;

@end

#define MRGString(key) \
[[MRGLocale sharedInstance] localizedStringForKey:(key)]

#define MRGStringFromTable(key, table) \
[[MRGLocale sharedInstance] localizedStringForKey:(key) inTable:(table)]
