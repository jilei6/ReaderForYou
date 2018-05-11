//
//  RFYDocumentSearch.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 7/7/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RFYDocument;
@class RFYDocumentSearch;
@class RFYDocumentSearchResult;

@protocol PDFDocumentSearchDelegate <NSObject>
- (void)search:(RFYDocumentSearch *)search
 didFindString:(RFYDocumentSearchResult *)result;
@end

@interface RFYDocumentSearch : NSObject
- (instancetype)initWithDocument:(RFYDocument *)document;
@property (nonatomic, weak, readonly) RFYDocument *document;
@property (nonatomic, weak) id<PDFDocumentSearchDelegate> delegate;
@property (nonatomic, assign, readonly) BOOL searching;
- (void)searchWithString:(NSString *)keyword;
- (void)cancelSearch;
@end
