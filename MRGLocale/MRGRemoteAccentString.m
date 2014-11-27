//
// Created by Jean-Francois Morin on 14-11-21.
// Copyright (c) 2014 Mirego. All rights reserved.
//

#import "MRGRemoteAccentString.h"


@implementation MRGRemoteAccentString

@synthesize languageIdentifier = _languageIdentifier;

- (instancetype)initWithLanguageIdentifier:(NSString *)languageIdentifier apiKey:(NSString *)apiKey
{
    self = [super init];
    if (self) {
        NSParameterAssert(languageIdentifier);
        NSParameterAssert(apiKey);

        _languageIdentifier = languageIdentifier;
        _apiKey = apiKey;
    }
    return self;
}

//------------------------------------------------------------------------------
#pragma mark Public
//------------------------------------------------------------------------------
- (NSData *)fetchRemoteResource:(NSError **)error
{
    NSString* url = [NSString stringWithFormat:@"http://accent.mirego.com/public_api/latest_revision?language=%@&render_format=strings&render_filename=Localizable.strings", self.languageIdentifier];
    NSMutableURLRequest * urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    NSURLResponse * response = nil;

    [urlRequest setValue:self.apiKey forHTTPHeaderField:@"Authorization"];

    NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest
                                          returningResponse:&response
                                                      error:error];
    return [self convertResponseData:data];
}

//------------------------------------------------------------------------------
#pragma mark Private
//------------------------------------------------------------------------------
- (NSData *)convertResponseData:(NSData *)responseData {
    NSString *stringsResource = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];

    // Replace %s by %@ (used for Android compatibility)
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"%([0-9]+\\$)?s"
                                                                           options:0
                                                                             error:&error];
    NSString *convertedResource = [regex stringByReplacingMatchesInString:stringsResource
                                                                  options:0
                                                                    range:NSMakeRange(0, stringsResource.length)
                                                             withTemplate:@"%$1@"];
    return [convertedResource dataUsingEncoding:NSUTF8StringEncoding];
}

@end