//
// Copyright (c) 2014, Mirego
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

#import <MessageUI/MessageUI.h>
#import "MRGControlPanelController.h"
#import "MRGControlPanelPlugin.h"

@interface MRGControlPanelController () <MRGControlPanelPluginDelegate>
@end

@implementation MRGControlPanelController {
    NSArray* _plugins;
    NSString * _deviceId;
}

- (id)initWithPlugins:(NSArray *)plugins deviceId:(NSString *) deviceId {
    self = [super init];
    if (self) {
        _plugins = plugins;
        _deviceId = deviceId;
    }
    return self;
}

- (NSUInteger)pluginCount {
    return [_plugins count];
}

- (id <MRGControlPanelPlugin>)pluginAtIndex:(NSUInteger)index {
    id <MRGControlPanelPlugin> plugin = [_plugins objectAtIndex:index];
    plugin.delegate = self;
    return plugin;
}

- (UIViewController *)viewControllerForPluginAtIndex:(NSUInteger)index {
    return [self pluginAtIndex:index].viewController;
}


//------------------------------------------------------------------------------
#pragma mark - MRGControlPanelPluginDelete Protocol
//------------------------------------------------------------------------------

- (void)plugin:(id <MRGControlPanelPlugin>)plugin requestReportOfData:(NSData *)data filename:(NSString*) filename additionalInfo:(NSDictionary *)info {
    [self plugin:plugin requestReportOfData:data filename:filename mimeType:@"application/octet-stream" additionalInfo:info];
}

- (void)plugin:(id <MRGControlPanelPlugin>)plugin requestReportOfData:(NSData *)data filename:(NSString *)filename mimeType:(NSString *)mimeType additionalInfo:(NSDictionary *)info {
    MFMailComposeViewController * composer = [[MFMailComposeViewController alloc] init];
    NSString * subject = [NSString stringWithFormat:@"%@ data",plugin.displayName];
    [composer setSubject:subject];
    [composer addAttachmentData:data mimeType:mimeType fileName:filename];

    NSString *body= [self emailHTMLBody:info];
    [composer setMessageBody:body isHTML:YES];

    [self.delegate shouldPresentMailComposer:composer];
}

- (NSString *)emailHTMLBody:(NSDictionary *)info {
    NSString *tableRows = [self tableRowForKey:@"Device Id" value:_deviceId];

    for(NSString * key in info.allKeys) {
        NSString * value = [info objectForKey:key];
        tableRows = [tableRows stringByAppendingFormat:@"%@", [self tableRowForKey:key value:value]];
    }
    NSString * tableFormat = @"<table><tr><th style='text-align:left'>Key</th><th style='text-align:left'>Value</th></tr>%@</table>";
    NSString * body = [NSString stringWithFormat:tableFormat, tableRows];
    return body;
}

- (NSString *) tableRowForKey:(NSString *) key value:(NSString *) value {
    return [NSString stringWithFormat:@"<tr><td width=\"150\">%@</td><td width=\"150\">%@</td></tr>",key,value];

}

@end
