//
//  RFYPageLinkList.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 7/29/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RFYDocumentNameList;
@class RFYPageLink;

@interface RFYPageLinkList : NSObject
- (instancetype)initWithCGPDFPage:(CGPDFPageRef)cgPage
                         nameList:(RFYDocumentNameList *)nameList;
@property (nonatomic, readonly) NSArray *links;
@end
