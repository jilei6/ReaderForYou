//
//  RFYDocumentPageSlider.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/02/15.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RFYDocumentPageSlider;
@class RFYDocumentPageSliderModel;

@protocol PDFDocumentPageSliderDelegate <NSObject>
@optional
- (void)pageSlider:(RFYDocumentPageSlider *)slider didStartAtIndex:(NSUInteger)index;
- (void)pageSlider:(RFYDocumentPageSlider *)slider didSelectAtIndex:(NSUInteger)index;
- (void)pageSliderBackClicked:(RFYDocumentPageSlider *)slider;
- (void)pageSliderForwardClicked:(RFYDocumentPageSlider *)slider;
@end

@interface RFYDocumentPageSlider : UIView
@property (nonatomic, weak) id<PDFDocumentPageSliderDelegate> delegate;
@property (nonatomic, strong) RFYDocumentPageSliderModel *model;
@end
