//
// Created by Martin Gagnon on 12/4/2013.
// Copyright (c) 2013 Mirego. All rights reserved.
//


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
#pragma mark MRGControlPanelPluginDelete
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