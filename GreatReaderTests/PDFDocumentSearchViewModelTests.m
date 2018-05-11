//
//  PDFDocumentSearchViewModelTests.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 7/10/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "FBKVOController.h"
#import "RFYDocument.h"
#import "RFYDocumentSearch+TestAdditions.h"
#import "RFYDocumentSearch.h"
#import "RFYDocumentSearchViewModel.h"

@interface PDFDocumentSearchViewModelTests : XCTestCase
@end

@implementation PDFDocumentSearchViewModelTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testStartSearchWithKeyword
{
    RFYDocumentSearch *search = [RFYDocumentSearch test_searchWithPDFName:@"PDFDocumentSearchTests3"];
    RFYDocumentSearchViewModel *viewModel = [[RFYDocumentSearchViewModel alloc] initWithSearch:search
                                                                                       outline:[[search document] outline]];
    XCTAssertTrue(viewModel.sections.count == 0, @"");

    __block int c = 0;
    [viewModel startSearchWithKeyword:@"xxx"
                           foundBlock:^(NSUInteger section, NSUInteger row) {
        if (c == 0) {
            XCTAssertTrue(section == 0, @"");
            XCTAssertTrue(row == 0, @"");            
        } else if (c == 1) {
            XCTAssertTrue(section == 0, @"");
            XCTAssertTrue(row == 1, @"");
        }
        c++;
    } completionBlock:^(BOOL finished) {}];

    XCTAssertTrue(viewModel.searching, @"");
    
    CGFloat timeout = 0;
    PDFDocumentSearchViewSection *section = nil;
    while (section.results.count != 2) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        timeout += 0.1;
        XCTAssertTrue(timeout < 2, @"");
        if (timeout >= 2) break;        
        section = [viewModel.sections firstObject];        
    }

    XCTAssertTrue(!viewModel.searching, @"");
}

- (void)testObserveSearching
{
    RFYDocumentSearch *search = [RFYDocumentSearch test_searchWithPDFName:@"PDFDocumentSearchTests3"];
    RFYDocumentSearchViewModel *viewModel = [[RFYDocumentSearchViewModel alloc] initWithSearch:search
                                                                                       outline:[[search document] outline]];
    FBKVOController *kvoController = [FBKVOController controllerWithObserver:self];
    __block int count = 0;
    [kvoController observe:viewModel
                   keyPath:@"searching"
                   options:0
                     block:^(id test, RFYDocumentSearchViewModel *vmi, NSDictionary *change) {
        count++;
    }];
    
    [viewModel startSearchWithKeyword:@"xxx"
                           foundBlock:^(NSUInteger section, NSUInteger row) {
    } completionBlock:^(BOOL finished) {}];
    
    CGFloat timeout = 0;
    while (count != 2) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        timeout += 0.1;
        XCTAssertTrue(timeout < 2, @"");
        if (timeout >= 2) break;        
    }
}

- (void)testStop
{
    RFYDocumentSearch *search = [RFYDocumentSearch test_searchWithPDFName:@"PDFDocumentSearchTests3"];
    RFYDocumentSearchViewModel *viewModel = [[RFYDocumentSearchViewModel alloc] initWithSearch:search
                                                                                       outline:[[search document] outline]];
    [viewModel startSearchWithKeyword:@"xxx"
                           foundBlock:^(NSUInteger section, NSUInteger row) {
    } completionBlock:^(BOOL finished) {}];
    [viewModel stopSearch];

    XCTAssertTrue(!viewModel.searching, @"");
}

@end
