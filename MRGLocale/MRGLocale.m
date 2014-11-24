//
//  MRGLocale.m
//  MRGLocale
//
//  Created by Vincent Roy Chevalier on 2014-03-05.
//  Copyright (c) 2014 Mirego. All rights reserved.
//

#import "MRGLocale.h"
#import "MRGRemoteStringFile.h"

#import <sys/xattr.h>


static NSString *const MRGLocaleFile = @"Localizable.strings";

static NSString *const RemoteStringFileUserDefaultKey = @"MRGLocale:RemoteStringFileUserDefaultKey";

@interface MRGLocale ()
@property (nonatomic) NSArray *remoteStringResources;
@property (nonatomic, assign) BOOL hasRemoteStringFiles;

@property (nonatomic) NSBundle *languageBundle;
@property (nonatomic) NSString *languageIdentifier;
@end

@implementation MRGLocale

- (id)init
{
    self = [super init];
    if (self) {
        _hasRemoteStringFiles = [self archivedRemoteStringResources].count > 0 ? YES : NO;
        _remoteStringResources = [NSMutableArray arrayWithCapacity:2];
        _languageBundle = nil;
        _languageIdentifier = @"";
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
    self.languageIdentifier = languageIdentifier;
    self.languageBundle = [[NSBundle alloc] initWithPath:[bundlePath stringByDeletingLastPathComponent]];
}

- (NSString *)getLanguageISO639Identifier
{
    return self.languageIdentifier;
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
    if (self.hasRemoteStringFiles) retVal = [[self remoteStringResourceBundle] localizedStringForKey:key value:nil table:[self defaultLocaleTable]];
    if (!retVal || [retVal isEqualToString:key]) {
        if (self.languageBundle != nil) {
            retVal = NSLocalizedStringFromTableInBundle(key, tableName, self.languageBundle, nil);
        } else {
            retVal = NSLocalizedStringFromTable(key, tableName, nil);
        }
    }
    return retVal;
}

//------------------------------------------------------------------------------
#pragma mark Public remote strings method
//------------------------------------------------------------------------------
- (MRGRemoteStringFile *)currentRemoteStringResource
{
    NSString *systemLangIdentifier = [MRGLocale systemLangIdentifier];
    MRGRemoteStringFile *currentRemoteStringResource = nil;
    for (MRGRemoteStringFile *remoteStringResource in self.remoteStringResources) {
        if ([remoteStringResource.languageIdentifier isEqualToString:systemLangIdentifier]) {
            currentRemoteStringResource = remoteStringResource;
            break;
        }
    }
    return currentRemoteStringResource;
}

- (void)setDefaultRemoteStringResources:(NSArray *)remoteStringResources
{
    for (id remoteStringResource in remoteStringResources) {
        if ([remoteStringResource isKindOfClass:[MRGRemoteStringFile class]]) {
            MRGRemoteStringFile *newRemoteStringResource = (MRGRemoteStringFile *) remoteStringResource;
            MRGRemoteStringFile *previousRemoteStringResource = [self remoteStringResourceWithLangIdentifier:newRemoteStringResource.languageIdentifier];
            if (!previousRemoteStringResource) {
                [self saveRemoteStringResource:newRemoteStringResource];
            }
        }
    }
    self.remoteStringResources = [self archivedRemoteStringResources];
}

- (void)addRemoteStringResource:(MRGRemoteStringFile *)remoteStringResource
{
    [self saveRemoteStringResource:remoteStringResource];
    self.remoteStringResources = [self archivedRemoteStringResources];
}

- (void)refreshRemoteStringResourcesWithCompletion:(void(^)())completion;
{
    __weak MRGLocale *wself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (MRGRemoteStringFile *remoteStringResource in wself.remoteStringResources) {
            NSData *localeData = [NSData dataWithContentsOfURL:remoteStringResource.url];
            [wself writeLocaleFileData:localeData withLocaleRemoteStringResource:remoteStringResource];
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            wself.hasRemoteStringFiles = YES;
            if (completion) completion();
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

- (void)writeLocaleFileData:(NSData *)data withLocaleRemoteStringResource:(MRGRemoteStringFile *)remoteStringResource
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

- (NSString *)filePathForRemoteStringResource:(MRGRemoteStringFile *)remoteStringResource
{
    NSString *localeFilePath = [[self directoryPathForRemoteStringResource:remoteStringResource] stringByAppendingPathComponent:MRGLocaleFile];
    return localeFilePath;
}

- (NSString *)directoryPathForRemoteStringResource:(MRGRemoteStringFile *)remoteStringResource
{
     NSString *localePathComp = [NSString stringWithFormat:@"%@.lproj", remoteStringResource.languageIdentifier];
    NSString * dirPath = [[self remoteStringResourceBundlePath] stringByAppendingPathComponent:localePathComp];
    if (![[NSFileManager defaultManager] fileExistsAtPath:dirPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return dirPath;
}

- (NSBundle *)remoteStringResourceBundle
{
    NSBundle *remoteStringResources = [[NSBundle alloc] initWithPath:[self remoteStringResourceBundlePath]];
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


- (void)saveRemoteStringResource:(MRGRemoteStringFile *)remoteStringResource
{
    NSInteger indexToReplace = NSNotFound;
    NSMutableArray *remoteStringResources = [NSMutableArray arrayWithArray:[self archivedRemoteStringResources]];
    if (!remoteStringResources) remoteStringResources = [NSMutableArray arrayWithCapacity:2];
    
    for (NSUInteger c = 0; c < remoteStringResources.count; c++) {
        id indexRemoteStringResource = [remoteStringResources objectAtIndex:c];
        if ([indexRemoteStringResource isKindOfClass:[MRGRemoteStringFile class]] && [[(MRGRemoteStringFile *) indexRemoteStringResource languageIdentifier] isEqualToString:remoteStringResource.languageIdentifier]) {
            indexToReplace = c;
            break;
        }
    }
    
    if (indexToReplace == NSNotFound) {
        [remoteStringResources addObject:remoteStringResource];
    } else {
        [remoteStringResources replaceObjectAtIndex:indexToReplace withObject:remoteStringResource];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:remoteStringResources] forKey:RemoteStringFileUserDefaultKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (MRGRemoteStringFile *)remoteStringResourceWithLangIdentifier:(NSString *)langIdentifier
{
    MRGRemoteStringFile *retVal = nil;
    NSArray *remoteStringResources = [self archivedRemoteStringResources];
    for (id remoteStringResource in remoteStringResources) {
        if ([remoteStringResource isKindOfClass:[MRGRemoteStringFile class]] && [[(MRGRemoteStringFile *) remoteStringResource languageIdentifier] isEqualToString:langIdentifier]) {
            retVal = (MRGRemoteStringFile *) remoteStringResource;
            break;
        }
    }
    return retVal;
}

- (NSArray *)archivedRemoteStringResources
{
    NSArray *result = nil;
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSData *remoteStringResource = [[NSUserDefaults standardUserDefaults] objectForKey:RemoteStringFileUserDefaultKey];
    
    if (remoteStringResource != nil) {
        result = [NSKeyedUnarchiver unarchiveObjectWithData:remoteStringResource];
    }
    return result;
}


+ (BOOL)addSkipBackupToFileAtPath:(NSString *)path {
    if (!path) return NO;
    
    if (&NSURLIsExcludedFromBackupKey == nil) { // iOS <= 5.0.1
        const char *systemFilePath = [path fileSystemRepresentation];
        const char *attrName = "com.apple.MobileBackup";
        u_int8_t attrValue = 1;
        
        int result = setxattr(systemFilePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
        return (result == 0);
    }
    else { // iOS >= 5.1
        NSError *error = nil;
        NSURL *url = [NSURL fileURLWithPath:path];
        [url setResourceValue:@(YES) forKey:NSURLIsExcludedFromBackupKey error:&error];
        return (error == nil);
    }
}

@end
