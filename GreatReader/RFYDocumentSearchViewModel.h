//
//  RFYDocumentSearchViewModel.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 7/9/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RFYDocumentOutline;
@class RFYDocumentSearch;
@class RFYDocumentSearchResult;

@interface RFYDocumentSearchViewModel : NSObject
- (instancetype)initWithSearch:(RFYDocumentSearch *)search
                       outline:(RFYDocumentOutline *)outline;
- (void)startSearchWithKeyword:(NSString *)keyword
                    foundBlock:(void (^)(NSUInteger, NSUInteger))foundBlock
               completionBlock:(void (^)(BOOL))completionBlock;
- (void)stopSearch;
- (RFYDocumentSearchResult *)resultAtIndexPath:(NSIndexPath *)indexPath;
@property (nonatomic, strong, readonly) NSArray *sections;
@property (nonatomic, readonly) BOOL searching;
@end

@interface PDFDocumentSearchViewSection : NSObject
@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, strong, readonly) NSArray *results;
@end
