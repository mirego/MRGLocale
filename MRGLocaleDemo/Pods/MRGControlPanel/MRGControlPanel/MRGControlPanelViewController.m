//
// Created by Martin Gagnon on 12/4/2013.
// Copyright (c) 2013 Mirego. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import "MRGControlPanelViewController.h"
#import "MRGControlPanelView.h"
#import "MRGControlPanelController.h"
#import "MRGControlPanelPluginViewCell.h"

@interface MRGControlPanelViewController () <UITableViewDelegate, UITableViewDataSource, MRGControlPanelControllerDelegate, UINavigationControllerDelegate, MFMailComposeViewControllerDelegate>
@end

@implementation MRGControlPanelViewController {
    MRGControlPanelController * _controller;
}

- (id) initWithController:(MRGControlPanelController*) controller {
    self = [super init];
    if (self) {
        _controller = controller;
        _controller.delegate = self;
        self.title = @"Control Panel";
    }
    return self;
}


- (void)loadView {
    MRGControlPanelView * view = [[MRGControlPanelView alloc] initWithFrame:CGRectZero];
    view.tableView.delegate = self;
    view.tableView.dataSource = self;
    [view.tableView reloadData];
    self.view = view;
}


//------------------------------------------------------------------------------
#pragma mark UITableViewDatasource
//------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_controller pluginCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MRGControlPanelPluginViewCell * viewCell = [tableView dequeueReusableCellWithIdentifier:@"pluginViewCell"];
    if (!viewCell) {
        viewCell = [[MRGControlPanelPluginViewCell alloc] initWithFrame:CGRectZero];
    }
    viewCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    [viewCell configureWithPlugin:[_controller pluginAtIndex:(NSUInteger)indexPath.row]];
    return viewCell;
}

//------------------------------------------------------------------------------
#pragma mark UITableViewDelegate
//------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.navigationController pushViewController:[_controller viewControllerForPluginAtIndex:indexPath.row] animated:YES];
}

//------------------------------------------------------------------------------
#pragma mark MRGControlPanelControllerDelegate
//------------------------------------------------------------------------------
- (void)shouldPresentMailComposer:(MFMailComposeViewController *)viewController {
    viewController.mailComposeDelegate = self;
    [self presentViewController:viewController animated:YES completion:^{}];
}

//------------------------------------------------------------------------------
#pragma mark MFMailViewControllerDelegate
//------------------------------------------------------------------------------
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    if (error || (result == MFMailComposeResultFailed))
        [[[UIAlertView alloc] initWithTitle:@"Cannot send message" message:@"The message cannot be send, please validate your email configuration in the settings pane and that network is reachable." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];

    [controller dismissViewControllerAnimated:YES completion:^{}];
}



@end