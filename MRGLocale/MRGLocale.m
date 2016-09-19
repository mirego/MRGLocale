// Copyright (c) 2015, Mirego
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// - Redistributions of source code must retain the above copyright notice,
//   this list of conditions and the following disclaimer.
// - Redistributions in binary form must reproduce the above copyright notice,
//   this list of conditions and the following disclaimer in the documentation
//   and/or other materials provided with the distribution.
// - Neither the name of the Mirego nor the names of its contributors may
//   be used to endorse or promote products derived from this software without
//   specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

#import "MRGLocale.h"
#import "MRGRemoteStringResource.h"

#import <sys/xattr.h>

static NSString *const MRGLocaleFile = @"Localizable.strings";

@interface MRGLocale ()
@property (nonatomic) NSMutableArray *remoteStringResources;
@property (nonatomic, assign) BOOL hasRemoteStringResources;

@property (nonatomic) NSBundle *localLanguageBundleOverride;
@property (nonatomic) NSString *languageIdentifierOverride;
@end

@implementation MRGLocale

- (id)init
{
    self = [super init];
    if (self) {
        _hasRemoteStringResources = NO;
        _remoteStringResources = [NSMutableArray arrayWithCapacity:2];
        _localLanguageBundleOverride = nil;
        _languageIdentifierOverride = @"";
    }
    return self;
}

+ (MRGLocale *)sharedInstance
{
    static MRGLocale *locale;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        locale = [[MRGLocale alloc] init];
    });
    return locale;
}

//------------------------------------------------------------------------------
#pragma mark Public language methods
//------------------------------------------------------------------------------
+ (NSString *)systemLangIdentifier
{
    return [[NSLocale preferredLanguages] objectAtIndex:0];
}

- (void)setLanguageBundleWithLanguageISO639Identifier:(NSString *)languageIdentifier
{
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"Localizable" ofType:@"strings" inDirectory:nil forLocalization:languageIdentifier];
    self.languageIdentifierOverride = languageIdentifier;
    self.localLanguageBundleOverride = [[NSBundle alloc] initWithPath:[bundlePath stringByDeletingLastPathComponent]];
}

- (NSString *)getLanguageISO639Identifier
{
    return self.languageIdentifierOverride;
}

//------------------------------------------------------------------------------
#pragma mark Public strings methods
//------------------------------------------------------------------------------
- (NSString *)localizedStringForKey:(NSString *)key
{
    return [self localizedStringForKey:key inTable:nil];
}

- (NSString *)localizedStringForKey:(NSString *)key inTable:(NSString *)tableName
{
    NSParameterAssert(key);
    NSString *retVal = nil;
    if (self.hasRemoteStringResources) {
        retVal = [[self remoteStringResourceBundle] localizedStringForKey:key value:nil table:[self defaultLocaleTable]];
    }
    if ((!retVal || [retVal isEqualToString:key]) && tableName) {
        if (self.localLanguageBundleOverride != nil) {
            retVal = NSLocalizedStringFromTableInBundle(key, tableName, self.localLanguageBundleOverride, nil);
        } else {
            retVal = NSLocalizedStringFromTable(key, tableName, nil);
        }
    }
    if (!retVal || [retVal isEqualToString:key]) {
        if (self.localLanguageBundleOverride != nil) {
            retVal = NSLocalizedStringFromTableInBundle(key, nil, self.localLanguageBundleOverride, nil);
        } else {
            retVal = NSLocalizedStringFromTable(key, nil, nil);
        }
    }
    return retVal;
}

//------------------------------------------------------------------------------
#pragma mark Public remote strings method
//------------------------------------------------------------------------------
- (void)setRemoteStringResourceList:(NSArray *)remoteStringResources
{
    for (id<MRGRemoteStringResource> remoteStringResource in remoteStringResources) {
        [self addRemoteStringResource:remoteStringResource];
    }

    self.hasRemoteStringResources = remoteStringResources.count > 0;
}

- (void)refreshRemoteStringResourcesWithCompletion:(void(^)(NSError *error))completion;
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error = nil;

        NSMutableSet *requestedLanguages = [NSMutableSet setWithCapacity:2];
        NSUInteger index = 0;
        while (!error && index < self.remoteStringResources.count) {
            id<MRGRemoteStringResource> remoteStringResource = self.remoteStringResources[index];
            NSData* stringData = [remoteStringResource fetchRemoteResource:&error];

            if (error == nil) {
                [self writeLocaleFileData:stringData withLocaleRemoteStringResource:remoteStringResource];
            }

            [requestedLanguages addObject:remoteStringResource.languageIdentifier];
            index++;
        }

        NSArray *languagesDirectories = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self remoteStringResourceBundlePath] error:nil];
        for (NSString *languageDirectory in languagesDirectories) {
            NSString* language = [languageDirectory stringByDeletingPathExtension];
            if (![requestedLanguages containsObject:language]) {
                [[NSFileManager defaultManager] removeItemAtPath:[self directoryPathForLanguageIdentifier:language] error:nil];
            }
        }

        dispatch_sync(dispatch_get_main_queue(), ^{
            if (completion != nil) {
                completion(error);
            }
        });
    });
}

//------------------------------------------------------------------------------
#pragma mark Private methods
//------------------------------------------------------------------------------
- (NSString *)defaultLocaleTable
{
    return [MRGLocaleFile stringByDeletingPathExtension];
}

- (void)writeLocaleFileData:(NSData *)data withLocaleRemoteStringResource:(id<MRGRemoteStringResource>)remoteStringResource
{
    NSString *localeFilePath = [self filePathForRemoteStringResource:remoteStringResource];
    if (data) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:localeFilePath]) {
            [[NSFileManager defaultManager] removeItemAtPath:localeFilePath error:nil];
        }
        [[NSFileManager defaultManager] createFileAtPath:localeFilePath contents:data attributes:nil];

    } else if (![[NSFileManager defaultManager] fileExistsAtPath:localeFilePath]) {
        [[NSFileManager defaultManager] createFileAtPath:localeFilePath contents:data attributes:nil];
    }
}

- (NSString *)filePathForRemoteStringResource:(id<MRGRemoteStringResource>)remoteStringResource
{
    NSString *localeFilePath = [[self directoryPathForRemoteStringResource:remoteStringResource] stringByAppendingPathComponent:MRGLocaleFile];
    return localeFilePath;
}

- (NSString *)directoryPathForRemoteStringResource:(id<MRGRemoteStringResource>)remoteStringResource
{
    return [self directoryPathForLanguageIdentifier:remoteStringResource.languageIdentifier];
}

- (NSString *)directoryPathForLanguageIdentifier:(NSString *)languageIdentifier
{
    NSString *localePathComp = [NSString stringWithFormat:@"%@.lproj", languageIdentifier];
    NSString * dirPath = [[self remoteStringResourceBundlePath] stringByAppendingPathComponent:localePathComp];
    if (![[NSFileManager defaultManager] fileExistsAtPath:dirPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return dirPath;
}

- (NSBundle *)remoteStringResourceBundle
{
    NSBundle *remoteStringResources = [[NSBundle alloc] initWithPath:[self remoteStringResourceBundlePath]];
    NSString *languageIdentifierOverride = self.languageIdentifierOverride;

    const BOOL hasLanguageOverride =  languageIdentifierOverride.length > 0;
    if (hasLanguageOverride) {
        NSString *bundlePath = [remoteStringResources pathForResource:@"Localizable" ofType:@"strings" inDirectory:nil forLocalization:languageIdentifierOverride];
        remoteStringResources = [[NSBundle alloc] initWithPath:[bundlePath stringByDeletingLastPathComponent]];
    }

    return remoteStringResources;
}

- (NSString *)remoteStringResourceBundlePath
{
    NSString *applicationSupportDir = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) lastObject];
    NSString *localesDir = [applicationSupportDir stringByAppendingPathComponent:@"MRGLocale"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:localesDir]) {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:localesDir withIntermediateDirectories:YES attributes:nil error:&error];
        if (!error) {
            [MRGLocale addSkipBackupToFileAtPath:localesDir];
        }
    }
    return localesDir;
}

- (void)addRemoteStringResource:(id<MRGRemoteStringResource>)remoteStringResource
{
    NSAssert([remoteStringResource conformsToProtocol:@protocol(MRGRemoteStringResource)], nil);

    [self.remoteStringResources addObject:remoteStringResource];
}

+ (BOOL)addSkipBackupToFileAtPath:(NSString *)path {
    if (!path) return NO;

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wtautological-pointer-compare"
#pragma GCC diagnostic ignored "-Wunreachable-code"
    if (&NSURLIsExcludedFromBackupKey == nil) { // iOS <= 5.0.1
        const char *systemFilePath = [path fileSystemRepresentation];
        const char *attrName = "com.apple.MobileBackup";
        u_int8_t attrValue = 1;

        int result = setxattr(systemFilePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
        return (result == 0);
        
    } else { // iOS >= 5.1
        NSError *error = nil;
        NSURL *url = [NSURL fileURLWithPath:path];
        [url setResourceValue:@(YES) forKey:NSURLIsExcludedFromBackupKey error:&error];
        return (error == nil);
    }
#pragma GCC diagnostic pop
}

@end
