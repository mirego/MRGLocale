//
// Copyright (c) 2014, Mirego
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// - Redistributions of source code must retain the above copyright notice,
//   this list of conditions and the following disclaimer.
// - Redistributions in binary form must reproduce the above copyright notice,
//   this list of conditions and the following disclaimer in the documentation
//   and/or other materials provided with the distribution.
// - Neither the name of the Mirego nor the names of its contributors may
//   be used to endorse or promote products derived from this software without
//   specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

#import "MRGControlPanel.h"
#import "MRGControlPanelPlugin.h"
#import "MRGControlPanelViewController.h"
#import "MRGControlPanelController.h"

@implementation MRGControlPanel {
    NSMutableArray * _plugins;
    UIViewController * _rootViewController;
}

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

- (void)addPlugin:(id <MRGControlPanelPlugin>)plugin {
    if (plugin && [plugin conformsToProtocol:@protocol(MRGControlPanelPlugin)])
        [_plugins addObject:plugin];
}

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
