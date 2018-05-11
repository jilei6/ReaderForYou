//
//  RFYDocumentOutlineContainerViewController.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 4/7/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "RFYDocumentOutlineContainerViewController.h"

#import "RFYDocumentOutlineViewController.h"
#import "RFYDocumentBookmarkListViewController.h"

@interface RFYDocumentOutlineContainerViewController ()
@property (nonatomic, strong) IBOutlet UISegmentedControl *segmentedControl;
@end

@implementation RFYDocumentOutlineContainerViewController

- (void)setCurrentViewController:(UIViewController *)currentViewController
{
    if (_currentViewController) {
        [_currentViewController removeFromParentViewController];
        [_currentViewController.view removeFromSuperview];
    }
    _currentViewController = currentViewController;
    [self addChildViewController:currentViewController];
    [self.view addSubview:currentViewController.view];
}

- (RFYDocumentOutlineViewController *)outlineViewController
{
    if (!_outlineViewController) {
        self.outlineViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RFYDocumentOutlineViewController"];
    }
    return _outlineViewController;
}

- (RFYDocumentBookmarkListViewController *)bookmarkListViewController
{
    if (!_bookmarkListViewController) {
        self.bookmarkListViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RFYDocumentBookmarkListViewController"];
    }
    return _bookmarkListViewController;
}

- (IBAction)segmentChanged:(id)sender
{
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0:
            if (self.currentViewController == self.bookmarkListViewController) {
                self.currentViewController = self.outlineViewController;
            }
            return;
        case 1:
            if (self.currentViewController == self.outlineViewController) {
                self.currentViewController = self.bookmarkListViewController;
            }
            return;            
        default:
            return;
    }
}

@end
