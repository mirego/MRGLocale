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

#import <MessageUI/MessageUI.h>
#import "MRGControlPanelViewController.h"
#import "MRGControlPanelController.h"
#import "MRGControlPanelPluginViewCell.h"

@interface MRGControlPanelViewController () <UITableViewDelegate, UITableViewDataSource, MRGControlPanelControllerDelegate, UINavigationControllerDelegate, MFMailComposeViewControllerDelegate>
@end

@implementation MRGControlPanelViewController {
    MRGControlPanelController * _controller;
}

- (id)initWithController:(MRGControlPanelController*) controller {
    self = [super init];
    if (self) {
        _controller = controller;
        _controller.delegate = self;
        self.title = @"Control Panel";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView reloadData];
}


//------------------------------------------------------------------------------
#pragma mark - UITableViewDataSource Protocol
//------------------------------------------------------------------------------

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_controller pluginCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MRGControlPanelPluginViewCell *viewCell = [tableView dequeueReusableCellWithIdentifier:@"pluginViewCell"];
    if (!viewCell) {
        viewCell = [[MRGControlPanelPluginViewCell alloc] initWithFrame:CGRectZero];
    }
    viewCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    [viewCell configureWithPlugin:[_controller pluginAtIndex:(NSUInteger)indexPath.row]];
    return viewCell;
}


//------------------------------------------------------------------------------
#pragma mark - UITableViewDelegate Protocol
//------------------------------------------------------------------------------

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.navigationController pushViewController:[_controller viewControllerForPluginAtIndex:indexPath.row] animated:YES];
}


//------------------------------------------------------------------------------
#pragma mark - MRGControlPanelControllerDelegate Protocol
//------------------------------------------------------------------------------

- (void)shouldPresentMailComposer:(MFMailComposeViewController *)viewController {
    viewController.mailComposeDelegate = self;
    [self presentViewController:viewController animated:YES completion:^{}];
}


//------------------------------------------------------------------------------
#pragma mark - MFMailViewControllerDelegate Protocol
//------------------------------------------------------------------------------

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    if (error || (result == MFMailComposeResultFailed)) {
        [[[UIAlertView alloc] initWithTitle:@"Cannot send message" message:@"The message cannot be send, please validate your email configuration in the settings pane and that network is reachable." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }

    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
