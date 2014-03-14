//
//  MRGLocaleControlPanelPluginViewController.m
//  MRGLocale
//
//  Created by Vincent Roy Chevalier on 2014-03-05.
//  Copyright (c) 2014 Mirego. All rights reserved.
//

#import "MRGLocaleControlPanelPluginViewController.h"
#import "MRGLocaleControlPanelPluginView.h"

#import "MRGLocale.h"
#import "MRGDynamicLocaleRef.h"

@interface MRGLocaleControlPanelPluginViewController () <UIAlertViewDelegate>
@property (nonatomic) MRGLocaleControlPanelPluginView *mainView;
@property (nonatomic) UIAlertView *addAlertView;
@property (nonatomic) UIAlertView *refreshAlertView;
@end

@implementation MRGLocaleControlPanelPluginViewController

- (id)init
{
    self = [super init];
    if (self) {
        _displayName = MRGString(@"MRGLocale");
        
//        NSArray *dynamicLocaleRefs = @[[[MRGDynamicLocaleRef alloc] initWithLangIdentifier:@"en" url:[NSURL URLWithString:@"http://vroyc.com/en.strings"]],
//          [[MRGDynamicLocaleRef alloc] initWithLangIdentifier:@"fr" url:[NSURL URLWithString:@"http://vroyc.com/fr.strings"]]];
//        [[MRGLocale sharedInstance] setDefaultDynamicLocaleRefs:dynamicLocaleRefs];
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    _mainView = [[MRGLocaleControlPanelPluginView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.view = _mainView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshButtonTouched:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonTouched:)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    _addAlertView.delegate = nil;
    _refreshAlertView.delegate = nil;
}

////////////////////////////////////////////////////////////////////////
#pragma mark UIControl Events
////////////////////////////////////////////////////////////////////////

- (void)refreshButtonTouched:(id)sender
{
    MRGDynamicLocaleRef *currentLocaleRef = [[MRGLocale sharedInstance] currentLocaleRef];
    _refreshAlertView = [[UIAlertView alloc] initWithTitle:MRGString(@"Refresh?") message:MRGString(@"You can also enter a new URL") delegate:self cancelButtonTitle:MRGString(@"Cancel") otherButtonTitles:MRGString(@"Refresh"), nil];
    _refreshAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [[_refreshAlertView textFieldAtIndex:0] setText:[currentLocaleRef.url absoluteString]];
    [_refreshAlertView show];
}

- (void)addButtonTouched:(id)sender
{
    _addAlertView = [[UIAlertView alloc] initWithTitle:MRGString(@"Test localizations") message:MRGString(@"Enter a test localizable key") delegate:self cancelButtonTitle:MRGString(@"Cancel") otherButtonTitles:MRGString(@"Change"), nil];
    _addAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [_addAlertView show];
}

////////////////////////////////////////////////////////////////////////
#pragma mark UIAlertView Delegate
////////////////////////////////////////////////////////////////////////

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == _addAlertView && buttonIndex > 0) {
        [_mainView setLabelTextWithKey:[[alertView textFieldAtIndex:0] text]];
        
    } else if (alertView == _refreshAlertView && buttonIndex > 0) {
        NSString *urlString = [[alertView textFieldAtIndex:0] text];
        if (urlString) {
            MRGDynamicLocaleRef *newDynamicLocaleRef = [[MRGDynamicLocaleRef alloc] initWithLangIdentifier:[MRGLocale systemLangIdentifier] url:[NSURL URLWithString:urlString]];
            [[MRGLocale sharedInstance] addLocaleRef:newDynamicLocaleRef];
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            
            __weak MRGLocaleControlPanelPluginViewController *wself = self;
            [[MRGLocale sharedInstance] refreshLocalesWithCompletion:^{
                [wself.mainView refreshLabel];
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                exit(0);
            }];
        }
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark MRGControlPanelPlugin Protocol
////////////////////////////////////////////////////////////////////////

+ (id<MRGControlPanelPlugin>)plugin
{
    return [[MRGLocaleControlPanelPluginViewController alloc] init];
}

- (UIViewController *)viewController
{
    return self;
}

@end
