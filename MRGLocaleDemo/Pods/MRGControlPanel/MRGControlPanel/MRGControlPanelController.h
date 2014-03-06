//
// Created by Martin Gagnon on 12/4/2013.
// Copyright (c) 2013 Mirego. All rights reserved.
//


#import <Foundation/Foundation.h>

@protocol MRGControlPanelPlugin;

@protocol MRGControlPanelControllerDelegate;
@class MFMailComposeViewController;

@interface MRGControlPanelController : NSObject
@property (nonatomic, readonly) NSUInteger pluginCount;
@property(nonatomic, weak) id<MRGControlPanelControllerDelegate> delegate;

- (id)initWithPlugins:(NSArray *)plugins deviceId:(NSString *) deviceId;

- (id<MRGControlPanelPlugin>) pluginAtIndex:(NSUInteger) index;
- (UIViewController *)viewControllerForPluginAtIndex:(NSUInteger)index;

@end

@protocol MRGControlPanelControllerDelegate
- (void) shouldPresentMailComposer:(MFMailComposeViewController *) viewController;
@end
