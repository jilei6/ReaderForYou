//
//  RFYDocumentBookmarkList.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2/24/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RFYDocument;

@interface RFYDocumentBookmarkList : NSObject
@property (nonatomic, strong, readonly) NSArray *bookmarkedSectionList;
@property (nonatomic, readonly) NSArray *bookmarkList;
@property (nonatomic, weak) RFYDocument *document;
- (void)bookmarkAtPage:(NSUInteger)page;
- (void)unbookmarkAtPage:(NSUInteger)page;
- (BOOL)bookmarkedAtPage:(NSUInteger)page;
- (void)toggleBookmarkAtPage:(NSUInteger)page;
@end
