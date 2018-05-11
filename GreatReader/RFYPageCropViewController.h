//
//  RFYPageCropViewController.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/01/21.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "RFYPageViewController.h"

@class RFYDocumentCrop;

@interface RFYPageCropViewController : RFYPageViewController
@property (nonatomic, strong) RFYDocumentCrop *crop;
@property (nonatomic, readonly) CGRect cropRect;
@end
