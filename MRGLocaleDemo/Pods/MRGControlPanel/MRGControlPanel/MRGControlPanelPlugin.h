//
//  MRGControlPanelPlugin.h
//  MRGControlPanelDemo
//
//  Created by Dany L'Hebreux on 2013-12-04.
//  Copyright (c) 2013 Mirego. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MRGControlPanelPluginDelegate;

@protocol MRGControlPanelPlugin <NSObject>
@property (nonatomic, readonly) NSString * displayName;
@property (nonatomic, weak) id<MRGControlPanelPluginDelegate> delegate;

+ (id <MRGControlPanelPlugin>)plugin; // New instance of the plugin
- (UIViewController *)viewController; // New instance of the plugin's view controller

@optional
- (BOOL) supportsPath:(NSString *) path; // if app started with ://panel/foo/bar ... /foo/bar will be passed
- (UIViewController *)viewControllerForPath:(NSString *) path; // New instance of the plugin's view controller... see supportsPath
@end

@protocol MRGControlPanelPluginDelegate
- (void)plugin:(id <MRGControlPanelPlugin>)plugin requestReportOfData:(NSData *)data filename:(NSString*) filename additionalInfo:(NSDictionary *)info;
- (void)plugin:(id <MRGControlPanelPlugin>)plugin requestReportOfData:(NSData *)data filename:(NSString*) filename mimeType:(NSString *) mimeType additionalInfo:(NSDictionary *)info;
@end
