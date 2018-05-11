//
//  RecentDocumentListViewModel.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 5/23/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "RecentDocumentListViewModel.h"

#import "RFYDocument.h"
#import "RFYDocumentStore.h"
#import "RFYRecentDocumentList.h"

@interface RecentDocumentListViewModel ()
@property (nonatomic, strong) RFYRecentDocumentList *documentList;
@end

@implementation RecentDocumentListViewModel

- (instancetype)initWithDocumentList:(RFYRecentDocumentList *)documentList
{
    self = [super init];
    if (self) {
        _documentList = documentList;
    }
    return self;
}

- (NSString *)title
{
    return LocalizedString(@"home.recently-read");
}

- (NSUInteger)count
{
    return self.documentList.count;
}

- (RFYDocument *)documentAtIndex:(NSUInteger)index
{
    return [self.documentList documentAtIndex:index];
}

- (void)deleteDocuments:(NSArray *)documents
{
    [self.documentList.store deleteDocuments:documents];
}

- (void)removeDocumentHistories:(NSArray *)documents
{
    [self.documentList removeHistories:documents];
}

@end
