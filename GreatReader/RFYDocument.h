//
//  RFYDocument.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/01/10.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "File.h"

@class RFYDocumentBackForwardList;
@class RFYDocumentBookmarkList;
@class RFYDocumentCrop;
@class RFYDocumentOutline;
@class RFYDocumentSearch;
@class RFYDocumentStore;
@class RFYPage;

extern NSString * const PDFDocumentDeletedNotification;

@interface RFYDocument : File <NSCoding>
@property (nonatomic, assign, readonly) NSUInteger numberOfPages;
@property (nonatomic, strong, readonly) RFYDocumentOutline *outline;
@property (nonatomic, strong, readonly) RFYDocumentCrop *crop;
@property (nonatomic, strong, readonly) RFYDocumentBookmarkList *bookmarkList;
@property (nonatomic, strong, readonly) RFYDocumentSearch *search;
@property (nonatomic, strong, readonly) UIImage *thumbnailImage;
@property (nonatomic, assign, readonly) CGPDFDocumentRef CGPDFDocument;
@property (nonatomic, assign, readonly) NSUInteger currentPage;
@property (nonatomic, assign) CGFloat brightness;
@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, readonly) BOOL currentPageBookmarked;
@property (nonatomic, weak) RFYDocumentStore *store;
@property (nonatomic, strong, readonly) RFYDocumentBackForwardList *backForwardList;
- (RFYPage *)pageAtIndex:(NSUInteger)index;
- (void)toggleRibbon;
- (void)delete;
- (void)goBack;
- (void)goForward;
- (void)goTo:(NSUInteger)page
  addHistory:(BOOL)addHistory;
+ (NSString *)absolutePathWithRelativePath:(NSString *)relativePath;
+ (NSString *)relativePathWithAbsolutePath:(NSString *)absolutePath;
@end
