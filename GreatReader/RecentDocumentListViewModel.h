//
//  RecentDocumentListViewModel.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 5/23/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "DocumentListViewModel.h"

@class RFYRecentDocumentList;

@interface RecentDocumentListViewModel : DocumentListViewModel
- (instancetype)initWithDocumentList:(RFYRecentDocumentList *)documentList;
@end
