//
//  RFYDocumentOutlineContainerViewController.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 4/7/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RFYDocumentOutlineViewController;
@class RFYDocumentBookmarkListViewController;

@interface RFYDocumentOutlineContainerViewController : UIViewController
@property (nonatomic, strong) RFYDocumentOutlineViewController *outlineViewController;
@property (nonatomic, strong) RFYDocumentBookmarkListViewController *bookmarkListViewController;
@property (nonatomic, strong) UIViewController *currentViewController;
@end
