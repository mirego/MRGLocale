//
//  MRGControlPanel.m
//  MRGControlPanelDemo
//
//  Created by Dany L'Hebreux on 2013-12-04.
//  Copyright (c) 2013 Mirego. All rights reserved.
//

#import "MRGControlPanel.h"
#import "MRGControlPanelPlugin.h"
#import "MRGControlPanelViewController.h"
#import "MRGControlPanelController.h"

@implementation MRGControlPanel {
    NSMutableArray * _plugins;
    UIViewController * _rootViewController;
}

//------------------------------------------------------------------------------
#pragma mark Constructor
//------------------------------------------------------------------------------
- (id)init {
    self = [super init];
    if (self) {
        _plugins = [[NSMutableArray alloc] initWithCapacity:5];
    }

    return self;
}

+ (BOOL)isControlPanelURL:(NSURL *)url {
    NSString *validRouteRegex = @"^.*:\\/\\/panel($|\\/)";
    return  ([url.absoluteString rangeOfString:validRouteRegex options:NSRegularExpressionSearch].location != NSNotFound);
}

+ (MRGControlPanel *)controlPanel {
    return [[MRGControlPanel alloc] init];
}

//------------------------------------------------------------------------------
#pragma mark Plugins modifier
//------------------------------------------------------------------------------
- (void)addPlugin:(id <MRGControlPanelPlugin>)plugin {
    if (plugin && [plugin conformsToProtocol:@protocol(MRGControlPanelPlugin)])
        [_plugins addObject:plugin];
}

//------------------------------------------------------------------------------
#pragma mark Property getter/setter
//------------------------------------------------------------------------------
- (NSUInteger)pluginsCount {
    return [_plugins count];
}

- (UIViewController *)rootViewController {
    if (!_rootViewController) {
        MRGControlPanelController * controller = [[MRGControlPanelController alloc] initWithPlugins:_plugins deviceId:self.deviceId];
        MRGControlPanelViewController * viewController = [[MRGControlPanelViewController alloc] initWithController:controller];
        UINavigationController * navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
        _rootViewController = navigationController;
    }
    return _rootViewController;
}

- (NSString *)deviceId {
    NSUUID * deviceIdForVendor = [[UIDevice currentDevice] identifierForVendor];
    return [deviceIdForVendor UUIDString];
}

- (BOOL)openURL:(NSURL *)url {
    NSString * urlStr = [url absoluteString];
    NSRange range = [urlStr rangeOfString:@"://panel/"];
    if (range.length > 0) {
        urlStr = [urlStr substringFromIndex:range.location + range.length -1];
        for (id<MRGControlPanelPlugin> plugin in _plugins) {
            if ([plugin respondsToSelector:@selector(supportsPath:)] && [plugin supportsPath:urlStr] && [plugin respondsToSelector:@selector(viewControllerForPath:)]) {
                UIViewController * viewController = [plugin viewControllerForPath:urlStr];
                UINavigationController * navController = (UINavigationController *)[self rootViewController];
                [navController pushViewController:viewController animated:YES];
            }
        }
        return YES;
    } else {
        return NO;
    }
}

@end
