//
//  RFYDocumentPageSliderModel.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 7/12/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RFYDocument;

@interface RFYDocumentPageSliderModel : NSObject
- (instancetype)initWithDocument:(RFYDocument *)document;
@property (nonatomic, readonly) NSUInteger currentPage;
@property (nonatomic, readonly) NSUInteger numberOfPages;
@property (nonatomic, readonly) BOOL canGoBack;
@property (nonatomic, readonly) BOOL canGoForward;
@end
