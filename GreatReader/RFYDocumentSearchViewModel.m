//
//  RFYDocumentSearchViewModel.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 7/9/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "RFYDocumentSearchViewModel.h"

#import "RFYDocumentOutline.h"
#import "RFYDocumentSearch.h"
#import "RFYDocumentSearchResult.h"


@interface PDFDocumentSearchViewSection ()
@property (nonatomic, copy, readwrite) NSString *title;
@property (nonatomic, strong, readwrite) NSArray *results;
@end

@implementation PDFDocumentSearchViewSection
@end


@interface RFYDocumentSearchViewModel () <PDFDocumentSearchDelegate>
@property (nonatomic, strong) RFYDocumentSearch *search;
@property (nonatomic, strong) RFYDocumentOutline *outline;
@property (nonatomic, strong, readwrite) NSArray *sections;
@property (nonatomic, copy) void (^foundBlock)(NSUInteger, NSUInteger);
@property (nonatomic, copy) void (^completionBlock)(BOOL);
@end

@implementation RFYDocumentSearchViewModel

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
{
    if ([key isEqual:@"searching"]) {
        return [NSSet setWithObjects:@"search.searching", nil];
    }
    return NSSet.set;
}

- (instancetype)initWithSearch:(RFYDocumentSearch *)search
                       outline:(RFYDocumentOutline *)outline
{
    self = [super init];
    if (self) {
        _search = search;
        _search.delegate = self;
        _outline = outline;
        _sections = @[];
    }
    return self;
}

- (NSMutableArray *)sectionsProxy
{
    return [self mutableArrayValueForKey:@"sections"];
}

- (void)startSearchWithKeyword:(NSString *)keyword
                    foundBlock:(void (^)(NSUInteger section, NSUInteger row))foundBlock
               completionBlock:(void (^)(BOOL finished))completionBlock
{
    self.foundBlock = foundBlock;
    self.completionBlock = completionBlock;
    [self.sectionsProxy removeAllObjects];
    [self.search searchWithString:keyword];
}

- (void)stopSearch
{
    [self.search cancelSearch];
}

- (void)search:(RFYDocumentSearch *)search
 didFindString:(RFYDocumentSearchResult *)result
{
    PDFDocumentSearchViewSection *lastSection = [self.sections lastObject];
    NSString *lastSectionTitle = lastSection.title ?: @"";
    NSMutableArray *results = [lastSection.results mutableCopy];
    NSString *sectionTitle = [self.outline sectionTitleAtIndex:result.page] ?: @"";
    PDFDocumentSearchViewSection *section = PDFDocumentSearchViewSection.new;
    section.title = sectionTitle;
    if ([lastSectionTitle isEqual:sectionTitle] && self.sections.count > 0) {
        [results addObject:result];
        section.results = [results copy];
        [self.sectionsProxy replaceObjectAtIndex:self.sections.count - 1
                                      withObject:section];
        if (self.foundBlock) {
            self.foundBlock(self.sections.count - 1,
                            section.results.count - 1);
        }
    } else {
        section.results = @[result];
        [self.sectionsProxy addObject:section];
        self.foundBlock(self.sections.count - 1, 0);
    }
}

- (BOOL)searching
{
    return self.search.searching;
}

- (RFYDocumentSearchResult *)resultAtIndexPath:(NSIndexPath *)indexPath
{
    PDFDocumentSearchViewSection *section = self.sections[indexPath.section];
    return section.results[indexPath.row];
}

@end
