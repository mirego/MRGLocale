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

@interface MRGLocaleControlPanelPluginViewController ()
@property (nonatomic) MRGLocaleControlPanelPluginView *mainView;
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
}

////////////////////////////////////////////////////////////////////////
#pragma mark UIControl Events
////////////////////////////////////////////////////////////////////////

- (void)refreshButtonTouched:(id)sender
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:MRGString(@"Refresh?")
                                                                   message:MRGString(@"You can also enter a new URL")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:nil];
    [alert addAction:[UIAlertAction actionWithTitle:MRGString(@"Cancel") style:UIAlertActionStyleCancel handler:nil]];

    __weak MRGLocaleControlPanelPluginViewController *wself = self;
    [alert addAction:[UIAlertAction actionWithTitle:MRGString(@"Refresh") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *urlString = alert.textFields.firstObject.text;
        if (!urlString) return;
        MRGRemoteStringFile *remoteStringFile = [[MRGRemoteStringFile alloc] initWithLanguageIdentifier:[MRGLocale systemLangIdentifier] url:[NSURL URLWithString:urlString]];
        [[MRGLocale sharedInstance] setRemoteStringResourceList:@[remoteStringFile]];
        [[MRGLocale sharedInstance] refreshRemoteStringResourcesWithCompletion:^(NSError *error) {
            [wself.mainView refreshLabel];
            exit(0);
        }];
    }]];

    [self presentViewController:alert animated:YES completion:nil];
}

- (void)addButtonTouched:(id)sender
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:MRGString(@"Test localizations")
                                                                   message:MRGString(@"Enter a test localizable key")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:nil];
    [alert addAction:[UIAlertAction actionWithTitle:MRGString(@"Cancel") style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:MRGString(@"Change") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self->_mainView setLabelTextWithKey:alert.textFields.firstObject.text];
    }]];

    [self presentViewController:alert animated:YES completion:nil];
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
