//
//  RFYDocumentInfo.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/02/17.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "RFYDocumentInfo.h"

#import "RFYDocument.h"
#import "RFYDocumentOutline.h"

@interface RFYDocumentInfo ()
@property (nonatomic, strong) RFYDocument *document;
@end

@implementation RFYDocumentInfo

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
{
    if ([key isEqualToString:@"pageDescription"]) {
        return [NSSet setWithObjects:@"document.currentPage", nil];
    }
    return [NSSet set];
}

- (instancetype)initWithDocument:(RFYDocument *)document
{
    self = [super init];
    if (self) {
        _document = document;
    }
    return self;
}

- (NSString *)pageDescription
{
    return [NSString stringWithFormat:@"%d/%d",
                     (int)self.document.currentPage,
                     (int)self.document.numberOfPages];
}

- (NSString *)sectionTitle
{
    return [self.document.outline sectionTitleAtIndex:self.document.currentPage];
}

- (NSString *)title
{
    return self.document.name;
}

@end
