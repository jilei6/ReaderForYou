//
//  RFYDocumentStore.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 5/29/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RFYDocument;
@class RFYRecentDocumentList;
@class RootFolder;

@interface RFYDocumentStore : NSObject
@property (nonatomic, strong, readonly) RFYRecentDocumentList *documentList;
@property (nonatomic, strong, readonly) RootFolder *rootFolder;
- (RFYDocument *)documentAtPath:(NSString *)path;
- (void)addHistory:(RFYDocument *)document;
- (void)deleteDocuments:(NSArray *)documents;
- (void)deleteDocument:(RFYDocument *)document;
@end
