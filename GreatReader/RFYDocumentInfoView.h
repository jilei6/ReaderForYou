//
//  RFYDocumentInfoView.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/02/17.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RFYDocumentInfo;

@interface RFYDocumentInfoView : UIView
@property (nonatomic, strong) RFYDocumentInfo *info;
- (void)show;
- (void)hide;
- (void)showAndHide;
@end
