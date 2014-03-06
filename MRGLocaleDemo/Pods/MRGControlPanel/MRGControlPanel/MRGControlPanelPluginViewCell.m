//
// Created by Martin Gagnon on 12/4/2013.
// Copyright (c) 2013 Mirego. All rights reserved.
//


#import "MRGControlPanelPluginViewCell.h"
#import "MRGControlPanelPlugin.h"


@implementation MRGControlPanelPluginViewCell {
}

- (id) initWithFrame:(CGRect) frame {
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

- (void)configureWithPlugin:(id <MRGControlPanelPlugin>)plugin {
    self.textLabel.text = plugin.displayName;
}


@end