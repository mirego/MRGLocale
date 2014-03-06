//
//  MRGControlPanel.h
//  MRGControlPanelDemo
//
//  Created by Dany L'Hebreux on 2013-12-04.
//  Copyright (c) 2013 Mirego. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MRGControlPanelPlugin;

@interface MRGControlPanel : NSObject
@property (nonatomic, readonly) NSUInteger pluginsCount;
@property(nonatomic, readonly) UIViewController *rootViewController;
@property (nonatomic, readonly) NSString * deviceId;

+ (MRGControlPanel *)controlPanel;
+ (BOOL)isControlPanelURL:(NSURL *)url;
- (void)addPlugin:(id <MRGControlPanelPlugin>)plugin;
- (BOOL)openURL:(NSURL *)url;
@end
