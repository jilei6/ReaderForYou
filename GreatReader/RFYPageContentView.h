//
//  RFYPageContentView.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/01/12.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RFYPage;
@class RFYPageContentView;
@class RFYPageLink;

@protocol PDFPageContentViewDelegate <NSObject>
- (void)contentView:(RFYPageContentView *)contentView
   copyMenuSelected:(NSString *)selectedString;
- (void)contentView:(RFYPageContentView *)contentView
 lookupMenuSelected:(NSString *)selectedString;
- (UIView *)loopeContainerViewForContentView:(RFYPageContentView *)contentView;
@end

@interface RFYPageContentView : UIView
@property (nonatomic, strong) RFYPage *page;
@property (nonatomic, readonly) CGFloat scale;
@property (nonatomic, readonly) CGRect selectionFrame;
@property (nonatomic, weak) id<PDFPageContentViewDelegate> delegate;
- (void)showLoopeAtPoint:(CGPoint)point
                  inView:(UIView *)containerView;
- (void)hideLoope;
- (void)redraw;
- (void)zoomStarted;
- (void)zoomFinished;
@end
