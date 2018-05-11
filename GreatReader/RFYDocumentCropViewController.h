//
//  RFYDocumentCropViewController.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/01/21.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RFYDocument;
@class RFYDocumentCrop;

@interface RFYDocumentCropViewController : UIViewController
@property (nonatomic, strong) RFYDocumentCrop *crop;
@property (nonatomic, strong) RFYDocument *document;
@property (nonatomic, assign) BOOL even;
@end

@interface PDFDocumentCropLayoutView : UIView
@end
