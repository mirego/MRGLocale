# MRGControlPanel
The Control panel of your dream

### Installation with CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries like this super control panel in your projects.

#### Podfile

```ruby
platform :ios, '7.0'
pod TODO
```

#### Project Setup

```objective-c
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if ([MRGControlPanel isControlPanelURL:url]) {
	    _panel = [MRGControlPanel controlPanel];
    	[_panel addPlugin:[MRGControlPanelSamplePlugin plugin]];
	    self.window.rootViewController = [_panel rootViewController];
	    [self.window makeKeyAndVisible];
    }
    return YES;
}
```

#### Plugin how to

* Add MRGControlPanel as a dependency in your project
* Create a class that implement MRGControlPanelPlugin protocol
* [_panel addPlugin:[YourAwesomePlugin plugin]];

See MRGControlPanelSamplePlugin.