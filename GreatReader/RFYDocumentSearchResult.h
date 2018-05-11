//
//  RFYDocumentSearchResult.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 7/7/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RFYDocumentSearchResult : NSObject
+ (RFYDocumentSearchResult *)resultWithSurroundingText:(NSString *)surroundingText
                                                 range:(NSRange)range
                                                atPage:(NSUInteger)page;
@property (nonatomic, assign, readonly) NSUInteger page;
@property (nonatomic, assign, readonly) NSRange range;
@property (nonatomic, copy, readonly) NSString *surroundingText;
@end


@interface RFYDocumentSearchResult (TableViewCellAdditions)
@property (nonatomic, readonly) NSAttributedString *attributedDescription;
@end

