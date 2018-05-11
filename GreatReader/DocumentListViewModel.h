//
//  DocumentListViewModel.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 5/23/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RFYDocument;
@class RFYRecentDocumentList;

@interface DocumentListViewModel : NSObject
- (NSString *)title;
- (NSUInteger)count;
- (RFYDocument *)documentAtIndex:(NSUInteger)index;
- (void)reload;
- (void)deleteDocuments:(NSArray *)documents;
- (void)removeDocumentHistories:(NSArray *)documents;
@end
