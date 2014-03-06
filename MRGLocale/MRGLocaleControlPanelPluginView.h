//
//  MRGLocaleControlPanelPluginView.h
//  MRGLocale
//
//  Created by Vincent Roy Chevalier on 2014-03-05.
//  Copyright (c) 2014 Mirego. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRGLocaleControlPanelPluginView : UIView

- (void)refreshLabel;
- (void)setLabelTextWithKey:(NSString *)key;

@end
