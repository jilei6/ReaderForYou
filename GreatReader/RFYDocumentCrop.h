//
//  RFYDocumentCrop.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/01/21.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RFYPage;

typedef NS_ENUM(NSUInteger, PDFDocumentCropMode) {
    PDFDocumentCropModeNone,
    PDFDocumentCropModeSame,            
    PDFDocumentCropModeDifferent,
};

@interface RFYDocumentCrop : NSObject
@property (nonatomic, assign) CGRect oddCropRect;
@property (nonatomic, assign) CGRect evenCropRect;
@property (nonatomic, assign) PDFDocumentCropMode mode;
@property (nonatomic, readonly) BOOL enabled;
- (CGRect)cropRectAtPage:(NSUInteger)page;
@end
