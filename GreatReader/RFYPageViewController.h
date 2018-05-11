//
//  RFYPageViewController.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/01/12.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RFYPage;
@class RFYPageContentView;
@class RFYDocumentViewController;

@interface RFYPageViewController : UIViewController
- (instancetype)initWithPage:(RFYPage *)page;
@property (nonatomic, weak) RFYDocumentViewController *documentViewController;
@property (nonatomic, readonly) CGRect contentFrame;
@property (nonatomic, strong, readonly) RFYPageContentView *contentView;
@property (nonatomic, readonly) CGRect frameThatFits;
@property (nonatomic, strong, readonly) RFYPage *page;
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, copy) void (^tapAction)(void);
@end
