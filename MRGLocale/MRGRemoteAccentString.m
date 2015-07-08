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
    NSString* url = [NSString stringWithFormat:@"https://accent.mirego.com/public_api/latest_revision?language=%@&render_format=strings&render_filename=Localizable.strings", self.languageIdentifier];
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
