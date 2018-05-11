//
//  RFYRecentDocumentList.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/02/06.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RFYDocument;
@class RFYDocumentStore;

@interface RFYRecentDocumentList : NSObject
@property (nonatomic, assign, readonly) NSUInteger count;
@property (nonatomic, strong, readonly) NSArray *documents;
@property (nonatomic, weak, readonly) RFYDocumentStore *store;
- (instancetype)initWithStore:(RFYDocumentStore *)store;
- (RFYDocument *)documentAtIndex:(NSUInteger)index;
- (void)addHistory:(RFYDocument *)document;
- (RFYDocument *)findDocumentAtPath:(NSString *)path;
- (void)removeHistories:(NSArray *)histories;
@end
