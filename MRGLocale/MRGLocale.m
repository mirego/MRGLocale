//
//  MRGLocale.m
//  MRGLocale
//
//  Created by Vincent Roy Chevalier on 2014-03-05.
//  Copyright (c) 2014 Mirego. All rights reserved.
//

#import "MRGLocale.h"
#import "MRGDynamicLocaleRef.h"

#import <sys/xattr.h>


static NSString *const kMRGLocaleFile = @"Localizable.strings";
static NSString *const kMRGLocaleFileLangIdentifierKey = @"MRGLocaleLang";

static NSString *const kDynamicLocalesRefUserDefaultKey = @"MRGLocale:kDynamicLocalesRefUserDefaultKey";

@interface MRGLocale ()
@property (nonatomic) NSArray *localeRefs;
@property (nonatomic, assign) BOOL hasDynamicLocales;

@property (nonatomic) NSBundle *languageBundle;
@property (nonatomic) NSString *languageIdentifier;
@end

@implementation MRGLocale

- (id)init
{
    self = [super init];
    if (self) {
        _hasDynamicLocales = [self archivedDynamicLocaleRefs].count > 0 ? YES : NO;
        _localeRefs = [NSMutableArray arrayWithCapacity:2];
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

/////////////////////////////////////////////////////////////////////////////////
#pragma mark Public methods
/////////////////////////////////////////////////////////////////////////////////

- (void)setLanguageBundleWithLanguageISO639Identifier:(NSString *)languageIdentifier
{
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"Localizable" ofType:@"strings" inDirectory:nil forLocalization:languageIdentifier];
    _languageIdentifier = languageIdentifier;
    _languageBundle = [[NSBundle alloc] initWithPath:[bundlePath stringByDeletingLastPathComponent]];
}

- (NSString *)getLanguageISO639Identifier
{
    return _languageIdentifier;
}

- (NSString *)localizedStringForKey:(NSString *)key
{
    return [self localizedStringForKey:key inTable:nil];
}

- (NSString *)localizedStringForKey:(NSString *)key inTable:(NSString *)tableName
{
    NSParameterAssert(key);
    NSString *retVal = nil;
    if (self.hasDynamicLocales) retVal = [[self dynamicLocalesBundle] localizedStringForKey:key value:nil table:[self defaultLocaleTable]];
    if (!retVal || [retVal isEqualToString:key]) {
        if (_languageBundle != nil) {
            retVal = NSLocalizedStringFromTableInBundle(key, tableName, _languageBundle, nil);
        } else {
            retVal = NSLocalizedStringFromTable(key, tableName, nil);
        }
    }
    return retVal;
}

+ (NSString *)systemLangIdentifier
{
    return [[NSLocale preferredLanguages] objectAtIndex:0];
}

- (MRGDynamicLocaleRef *)currentLocaleRef
{
    NSString *systemLangIdentifier = [MRGLocale systemLangIdentifier];
    MRGDynamicLocaleRef *currentLocaleRef = nil;
    for (MRGDynamicLocaleRef *ref in _localeRefs) {
        if ([ref.langIdentifier isEqualToString:systemLangIdentifier]) {
            currentLocaleRef = ref;
            break;
        }
    }
    return currentLocaleRef;
}

- (void)setDefaultDynamicLocaleRefs:(NSArray *)localeRefs
{
    for (id ref in localeRefs) {
        if ([ref isKindOfClass:[MRGDynamicLocaleRef class]]) {
            MRGDynamicLocaleRef *newRef = (MRGDynamicLocaleRef *)ref;
            MRGDynamicLocaleRef *previousLocaleRef = [self dynamicLocaleRefWithLangIdentifier:newRef.langIdentifier];
            if (!previousLocaleRef) {
                [self saveDynamicLocaleRef:newRef];
            }
        }
    }
    _localeRefs = [self archivedDynamicLocaleRefs];
}

- (void)addLocaleRef:(MRGDynamicLocaleRef *)localeRef
{
    [self saveDynamicLocaleRef:localeRef];
    _localeRefs = [self archivedDynamicLocaleRefs];
}

- (void)refreshLocalesWithCompletion:(void(^)())completion;
{
    __weak MRGLocale *wself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (MRGDynamicLocaleRef *localeRef in wself.localeRefs) {
            NSData *localeData = [NSData dataWithContentsOfURL:localeRef.url];
            [wself writeLocaleFileData:localeData withLocaleRef:localeRef];
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            wself.hasDynamicLocales = YES;
            if (completion) completion();
        });
    });
}

/////////////////////////////////////////////////////////////////////////////////
#pragma mark Private methods
/////////////////////////////////////////////////////////////////////////////////

- (NSString *)defaultLocaleTable
{
    return [kMRGLocaleFile stringByDeletingPathExtension];
}

- (void)writeLocaleFileData:(NSData *)data withLocaleRef:(MRGDynamicLocaleRef *)ref
{
    NSString *localeFilePath = [self dynamicLocaleFilePathFromRef:ref];
    if (data) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:localeFilePath]) {
            [[NSFileManager defaultManager] removeItemAtPath:localeFilePath error:nil];
        }
        [[NSFileManager defaultManager] createFileAtPath:localeFilePath contents:data attributes:nil];
        
    } else if (![[NSFileManager defaultManager] fileExistsAtPath:localeFilePath]) {
        [[NSFileManager defaultManager] createFileAtPath:localeFilePath contents:data attributes:nil];
    }
}

- (NSString *)dynamicLocaleFilePathFromRef:(MRGDynamicLocaleRef *)ref
{
    NSString *localeFilePath = [[self dynamicLocaleDirPathFromRef:ref] stringByAppendingPathComponent:kMRGLocaleFile];
    return localeFilePath;
}

- (NSString *)dynamicLocaleDirPathFromRef:(MRGDynamicLocaleRef *)ref
{
     NSString *localePathComp = [NSString stringWithFormat:@"%@.lproj", ref.langIdentifier];
    NSString * dirPath = [[self dynamicLocalesBundlePath] stringByAppendingPathComponent:localePathComp];
    if (![[NSFileManager defaultManager] fileExistsAtPath:dirPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return dirPath;
}

- (NSBundle *)dynamicLocalesBundle
{
    NSBundle *dynamicLocales = [[NSBundle alloc] initWithPath:[self dynamicLocalesBundlePath]];
    return dynamicLocales;
}

- (NSString *)dynamicLocalesBundlePath
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


- (void)saveDynamicLocaleRef:(MRGDynamicLocaleRef *)newRef
{
    NSInteger indexToReplace = NSNotFound;
    NSMutableArray *dynamicLocaleRefs = [NSMutableArray arrayWithArray:[self archivedDynamicLocaleRefs]];
    if (!dynamicLocaleRefs) dynamicLocaleRefs = [NSMutableArray arrayWithCapacity:2];
    
    for (NSUInteger c = 0; c < dynamicLocaleRefs.count; c++) {
        id ref = [dynamicLocaleRefs objectAtIndex:c];
        if ([ref isKindOfClass:[MRGDynamicLocaleRef class]] && [[(MRGDynamicLocaleRef *)ref langIdentifier] isEqualToString:newRef.langIdentifier]) {
            indexToReplace = c;
            break;
        }
    }
    
    if (indexToReplace == NSNotFound) {
        [dynamicLocaleRefs addObject:newRef];
    } else {
        [dynamicLocaleRefs replaceObjectAtIndex:indexToReplace withObject:newRef];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:dynamicLocaleRefs] forKey:kDynamicLocalesRefUserDefaultKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (MRGDynamicLocaleRef *)dynamicLocaleRefWithLangIdentifier:(NSString *)langIdentifier
{
    MRGDynamicLocaleRef *retVal = nil;
    NSArray *dynamicLocaleRefs = [self archivedDynamicLocaleRefs];
    for (id ref in dynamicLocaleRefs) {
        if ([ref isKindOfClass:[MRGDynamicLocaleRef class]] && [[(MRGDynamicLocaleRef *)ref langIdentifier] isEqualToString:langIdentifier]) {
            retVal = (MRGDynamicLocaleRef *)ref;
            break;
        }
    }
    return retVal;
}

- (NSArray *)archivedDynamicLocaleRefs
{
    NSArray *result = nil;
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSData *dynamicLocalesRef = [[NSUserDefaults standardUserDefaults] objectForKey:kDynamicLocalesRefUserDefaultKey];
    
    if (dynamicLocalesRef != nil) {
        result = [NSKeyedUnarchiver unarchiveObjectWithData:dynamicLocalesRef];
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
