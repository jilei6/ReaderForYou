
//
//  RFYDocumentSearch.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 7/7/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "RFYDocumentSearch.h"

#import "NSArray+GreatReaderAdditions.h"
#import "RFYDocument.h"
#import "RFYPageScanner.h"
#import "RFYRenderingCharacter.h"
#import "RFYDocumentSearchResult.h"

@interface RFYDocumentSearch ()
@property (nonatomic, assign, readwrite) BOOL searching;
@property (nonatomic, assign) BOOL cancel;
@end

@implementation RFYDocumentSearch

- (instancetype)initWithDocument:(RFYDocument *)document
{
    self = [super init];
    if (self) {
        _document = document;
    }
    return self;
}

- (void)cancelSearch
{
    self.cancel = YES;
    while (self.searching) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
    }
    self.cancel = NO;
}

- (void)doneSearching
{
    self.searching = NO;
}

- (void)searchWithString:(NSString *)keyword
{
    if (self.searching) {
        [self cancelSearch];
    }
    self.searching = YES;
    size_t numberOfPages = CGPDFDocumentGetNumberOfPages(self.document.CGPDFDocument);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i = 1; i <= numberOfPages; i++) {
            if (self.cancel) {
                break;
            }
            [self searchWithString:keyword
                            atPage:i];
        }
        [self performSelectorOnMainThread:@selector(doneSearching)
                               withObject:nil
                            waitUntilDone:YES];
    });
}

- (void)searchWithString:(NSString *)keyword
                  atPage:(NSUInteger)index
{
    CGPDFPageRef page = CGPDFDocumentGetPage(self.document.CGPDFDocument, index);
    RFYPageScanner *scanner = [[RFYPageScanner alloc] initWithCGPDFPage:page];
    NSArray *contents = [scanner scanStringContents];
    NSString *text = [[contents grt_map:^(RFYRenderingCharacter *character) {
        return character.stringDescription;
    }] componentsJoinedByString:@""];
    NSRange range = [text rangeOfString:keyword options:NSCaseInsensitiveSearch];
    while (range.location != NSNotFound) {
        RFYDocumentSearchResult *result =
                [self searchResultWithCharacters:contents
                                           range:range
                                          atPage:index];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate search:self
                    didFindString:result];
        });

        NSUInteger start = range.location + range.length;
        NSRange targetRange = NSMakeRange(start,
                                          text.length - start);
        range = [text rangeOfString:keyword
                            options:0
                              range:targetRange];
    }
}

- (RFYDocumentSearchResult *)searchResultWithCharacters:(NSArray *)characters
                                                  range:(NSRange)range
                                                 atPage:(NSUInteger)page
{
    const NSUInteger maxLength = 30;
    NSUInteger left = (maxLength - range.length) / 2;
    NSRange surroundingRange = range;
    if ((int)(surroundingRange.location - left) < 0) {
        surroundingRange.location = 0;
        surroundingRange.length = MIN(maxLength, characters.count);
    } else {
        surroundingRange.location = surroundingRange.location - left;
        surroundingRange.length = MIN(maxLength, characters.count - surroundingRange.location);
        if (surroundingRange.length < maxLength) {
            NSInteger location = surroundingRange.location - (maxLength - surroundingRange.length);
            if (location < 0) {
                location = 0;
            }
            surroundingRange.location = location;
            surroundingRange.length = characters.count - surroundingRange.location;
        }
    }
    
    NSString *text = [[[characters subarrayWithRange:surroundingRange] grt_map:^(RFYRenderingCharacter *character) {
        return character.stringDescription;
    }] componentsJoinedByString:@""];

    RFYDocumentSearchResult *result =
            [RFYDocumentSearchResult resultWithSurroundingText:text
                                                         range:NSMakeRange(range.location - surroundingRange.location, range.length)
                                                        atPage:page];
    return result;
}

@end
