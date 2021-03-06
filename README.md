# MRGLocale

## What is it?

`MRGLocale` gives you 2 super features:

- Change the preferred language in-app
- Update your localizations without building your app

## How to use it

### First things first

- Add `MRGLocale` in your `Podfile`
- Run `pod install` in your terminal at the root of your project

### Use it for real

Since the pod is installed, you no longer use `NSLocalizedString()`. Use `MRGString(key)` or `MRGStringFromTable(key, table)`.

### Changing preferred language

```objc
[[MRGLocale sharedInstance] setLanguageBundleWithLanguageISO639Identifier:@"fr_CA"];
```

### Updating your localizations dynamically

Say you want to update your localizations with a file on S3:

```objc
MRGRemoteStringFile *remoteStringFile = [[MRGRemoteStringFile alloc] initWithLanguageIdentifier:@"en" url:[NSURL URLWithString:@"https://bucket.s3.amazonaws.com/Localizables.json"];

[[MRGLocale sharedInstance] setRemoteStringResourceList:@[remoteStringFile]];
```

The code above creates your remote string resources for your updatable localizations. In order to check for updates, you only need to periodically call the following method:
```objc
[[MRGLocale sharedInstance] refreshRemoteStringResourcesWithCompletion:completionBlock];
```
`- (void)applicationDidBecomeActive:(UIApplication *)application` in the app delegate would be a great place. The updates will only be available after you kill and restart the app.

### Creating a customized "Remote String Resource" for your customized API

Create a class that conforms to the `MRGRemoteStringResource` protocol. Long story short, it needs to implement:
```objc
- (NSString *)languageIdentifier;
- (NSData *)fetchRemoteResource:(NSError **)error;
```

## Backstage secrets

If a translation is not available from the remote string resource, `MRGLocale` will fallback to the app bundle's `Localizable.strings`

## Converting an old project to MRGLocale
In Xcode, use the regular expression feature of find and replace all to convert occurences of `NSLocalizedString` with `MRGString`.

- "find" `NSLocalizedString\(@"([^\)"]*)"([^\)]*)\)` and "replace" with `MRGString(@"$1")` for `NSLocalizedString` occurences
- "find" `NSLocalizedStringFromTable\(@"([^\)"]*)",( )?@"([^\)"]*)"([^\)]*)\)` and "replace" with `MRGStringFromTable(@"$1", @"$3")` for `NSLocalizedStringFromTable` occurences

*Note that `NSLocalizedStringFromTableInBundle` and `NSLocalizedStringWithDefaultValue` are currently not supported by `MRGLocale`*

## Known issues

If you're using MRGLocale in a Watch or an App Extension, make sure you link against the `MRGLocale/Core` subspec so it doesn't link the [MRGControlPanel](https://github.com/mirego/MRGControlPanel) as well (it uses API like UIAlertView and UIApplication's sharedApplication methods that are not allowed in an extension).

## License

`MRGLocale` is © 2016 [Mirego](http://www.mirego.com) and may be freely distributed under the [New BSD license](http://opensource.org/licenses/BSD-3-Clause).  See the [`LICENSE.md`](https://github.com/mirego/MRGLocale/blob/master/LICENSE.md) file.

## About Mirego

[Mirego](http://mirego.com) is a team of passionate people who believe that work is a place where you can innovate and have fun. We're a team of [talented people](http://life.mirego.com) who imagine and build beautiful Web and mobile applications. We come together to share ideas and [change the world](http://mirego.org).

We also [love open-source software](http://open.mirego.com) and we try to give back to the community as much as we can.
