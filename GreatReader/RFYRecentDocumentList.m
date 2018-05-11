//
//  RFYRecentDocumentList.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/02/06.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "RFYRecentDocumentList.h"

#import "Folder.h"
#import "NSArray+GreatReaderAdditions.h"
#import "NSFileManager+GreatReaderAdditions.h"
#import "RFYDocument.h"
#import "RFYDocumentStore.h"

@interface RFYRecentDocumentList ()
@property (nonatomic, strong, readwrite) NSArray *documents;
@property (nonatomic, assign) UIBackgroundTaskIdentifier bgTask;
@property (nonatomic, weak, readwrite) RFYDocumentStore *store;
@end

@implementation RFYRecentDocumentList

- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (instancetype)initWithStore:(RFYDocumentStore *)store
{
    self = [super init];
    if (self) {
        _store = store;
        NSArray *list = [self load];
        _documents = list;
        [NSNotificationCenter.defaultCenter addObserver:self
                                               selector:@selector(documentDeleted:)
                                                   name:PDFDocumentDeletedNotification
                                                 object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self
                                               selector:@selector(didEnterBackground:)
                                                   name:UIApplicationDidEnterBackgroundNotification
                                                 object:nil];
    }
    return self;
}

#pragma mark - Save, Load

- (NSString *)path
{
    NSString * const name = @"RFYRecentDocumentList";
    return [NSString stringWithFormat:@"%@/%@",
                     [NSFileManager grt_privateDocumentsPath],
                     name];
}

- (void)save
{
    NSString *dirPath = [NSFileManager grt_privateDocumentsPath];
    NSFileManager *fm = [NSFileManager new];
    if (![fm fileExistsAtPath:dirPath]) {
        [fm grt_createPrivateDocumentsDirectory];
    }
    [NSKeyedArchiver archiveRootObject:self.documents
                                toFile:self.path];
}

- (void)saveLater
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(save)
                                               object:nil];
    [self performSelector:@selector(save) withObject:nil afterDelay:0.0];
}

- (NSArray *)load
{
    NSArray *list = [NSKeyedUnarchiver unarchiveObjectWithFile:self.path]
            ?: @[];
    return [list grt_filter:^(RFYDocument *document) {
        return (BOOL)!document.fileNotExist;
    }];
}

#pragma mark -

- (NSMutableArray *)documentsProxy
{
    return [self mutableArrayValueForKey:@"documents"];
}

#pragma mark -

- (void)addHistory:(RFYDocument *)document
{
    [self.documentsProxy removeObject:document];
    [self.documentsProxy insertObject:document atIndex:0];
    [self save];
}

- (void)removeHistories:(NSArray *)histories
{
    [self.documentsProxy removeObjectsInArray:histories];
    [self save];
}

- (RFYDocument *)findDocumentAtPath:(NSString *)path
{
    NSString *rPath = [RFYDocument relativePathWithAbsolutePath:path];
    for (RFYDocument *doc in self.documents) {
        NSString *docrPath = [RFYDocument relativePathWithAbsolutePath:doc.path];
        if ([rPath isEqual:docrPath]) {
            return doc;
        }
    }
    return nil;
}

- (NSUInteger)count
{
    return self.documentsProxy.count;
}

- (RFYDocument *)documentAtIndex:(NSUInteger)index
{
    return [self.documentsProxy objectAtIndex:index];
}

#pragma mark - Notifications

- (void)documentDeleted:(NSNotification *)notification
{
    RFYDocument *deletedDocument = notification.object;
    for (RFYDocument *doc in [self.documents copy]) {
        if (deletedDocument == doc) {
            [self.documentsProxy removeObject:doc];
        }
    }    

    [self saveLater];
}

#pragma mark - Did Enter Background

- (void)didEnterBackground:(NSNotification *)notification
{
    self.bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.bgTask];
        self.bgTask = UIBackgroundTaskInvalid;
    }];
    [self save];
    [[UIApplication sharedApplication] endBackgroundTask:self.bgTask];
    self.bgTask = UIBackgroundTaskInvalid;
}

@end
