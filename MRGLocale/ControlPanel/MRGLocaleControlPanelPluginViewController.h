//
//  MRGLocaleControlPanelPluginViewController.h
//  MRGLocale
//
//  Created by Vincent Roy Chevalier on 2014-03-05.
//  Copyright (c) 2014 Mirego. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MRGControlPanel/MRGControlPanelPlugin.h>

@interface MRGLocaleControlPanelPluginViewController : UIViewController <MRGControlPanelPlugin>

@property (nonatomic, readonly) NSString * displayName;
@property (nonatomic, weak) id<MRGControlPanelPluginDelegate> delegate;

@end
