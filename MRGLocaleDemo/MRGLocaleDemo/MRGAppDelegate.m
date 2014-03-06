//
//  MRGAppDelegate.m
//  MRGLocaleDemo
//
//  Created by Vincent Roy Chevalier on 2014-03-06.
//  Copyright (c) 2014 Mirego. All rights reserved.
//

#import "MRGAppDelegate.h"
#import <MRGControlPanel/MRGControlPanel.h>
#import "MRGLocaleControlPanelPluginViewController.h"

@implementation MRGAppDelegate
{
    MRGControlPanel * _panel;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([MRGControlPanel isControlPanelURL:url]) {
        [self showControlPanel];
        [_panel openURL:url];
    }
    return YES;
}

- (void)showControlPanel {
    _panel = [MRGControlPanel controlPanel];
    [_panel addPlugin:[MRGLocaleControlPanelPluginViewController plugin]];
    self.window.rootViewController = [_panel rootViewController];
    [self.window makeKeyAndVisible];
}

@end
