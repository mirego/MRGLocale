//
// Created by Martin Gagnon on 12/4/2013.
// Copyright (c) 2013 Mirego. All rights reserved.
//


#import <Foundation/Foundation.h>

@protocol MRGControlPanelPlugin;

@interface MRGControlPanelPluginViewCell : UITableViewCell
- (void) configureWithPlugin:(id<MRGControlPanelPlugin>) plugin;
@end