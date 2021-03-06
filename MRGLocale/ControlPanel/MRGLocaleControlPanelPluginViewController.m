// Copyright (c) 2015, Mirego
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

#import "MRGLocaleControlPanelPluginViewController.h"
#import "MRGLocaleControlPanelPluginView.h"

#import <MRGLocale.h>
#import <MRGRemoteStringFile.h>

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
        
//        NSArray *remoteStringResources = @[[[MRGRemoteStringFile alloc] initWithLangIdentifier:@"en" url:[NSURL URLWithString:@"http://vroyc.com/en.strings"]],
//          [[MRGRemoteStringFile alloc] initWithLangIdentifier:@"fr" url:[NSURL URLWithString:@"http://vroyc.com/fr.strings"]]];
//        [[MRGLocale sharedInstance] setDefaultRemoteStringResources:remoteStringResources];
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
    _refreshAlertView = [[UIAlertView alloc] initWithTitle:MRGString(@"Refresh?") message:MRGString(@"You can also enter a new URL") delegate:self cancelButtonTitle:MRGString(@"Cancel") otherButtonTitles:MRGString(@"Refresh"), nil];
    _refreshAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
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
            MRGRemoteStringFile *newRemoteStringFile = [[MRGRemoteStringFile alloc] initWithLanguageIdentifier:[MRGLocale systemLangIdentifier] url:[NSURL URLWithString:urlString]];
            [[MRGLocale sharedInstance] setRemoteStringResourceList:@[newRemoteStringFile]];
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            
            __weak MRGLocaleControlPanelPluginViewController *wself = self;
            [[MRGLocale sharedInstance] refreshRemoteStringResourcesWithCompletion:^(NSError *error) {
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
