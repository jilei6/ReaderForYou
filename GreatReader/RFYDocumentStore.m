//
//  RFYDocumentStore.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 5/29/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "RFYDocumentStore.h"

#import "RootFolder.h"
#import "RFYDocument.h"
#import "RFYRecentDocumentList.h"

@interface RFYDocumentStore ()
@property (nonatomic, strong, readwrite) RFYRecentDocumentList *documentList;
@property (nonatomic, strong, readwrite) RootFolder *rootFolder;
@end

@implementation RFYDocumentStore

- (instancetype)init
{
    self = [super init];
    if (self) {
        _documentList = [[RFYRecentDocumentList alloc] initWithStore:self];
    }
    return self;
}

- (RFYDocument *)documentAtPath:(NSString *)path
{
    RFYDocument *document = [self.documentList findDocumentAtPath:path];
    if (!document) {
        document = [[RFYDocument alloc] initWithPath:path];
    }
    document.store = self;    
    return document;
}

- (RootFolder *)rootFolder
{
    if (!_rootFolder) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask,
                                                             YES);        
        _rootFolder = [[RootFolder alloc] initWithPath:paths.firstObject
                                                 store:self];
    }
    return _rootFolder;
}

- (void)addHistory:(RFYDocument *)document
{
    [self.documentList addHistory:document];
}

- (void)deleteDocuments:(NSArray *)documents
{
    [documents enumerateObjectsUsingBlock:^(RFYDocument *document,
                                            NSUInteger idx,
                                            BOOL *stop) {
        [self deleteDocument:document];
    }];
}

- (void)deleteDocument:(RFYDocument *)document
{
    [document delete];
}

@end
