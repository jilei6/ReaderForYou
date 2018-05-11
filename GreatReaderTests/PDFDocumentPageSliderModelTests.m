//
//  PDFDocumentPageSliderModelTests.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 7/23/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <KVOController/FBKVOController.h>

#import "RFYDocument.h"
#import "RFYDocument+TestAdditions.h"
#import "RFYDocumentPageSliderModel.h"
#import "RFYDocumentBackForwardList.h"

@interface PDFDocumentPageSliderModelTests : XCTestCase

@end

@implementation PDFDocumentPageSliderModelTests

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

- (void)testObservation
{
    RFYDocument *document = [RFYDocument test_documentWithPDFName:@"OutlineTests"];
    RFYDocumentPageSliderModel *model = [[RFYDocumentPageSliderModel alloc]
                                            initWithDocument:document];
    FBKVOController *kvoController = [FBKVOController controllerWithObserver:self];

    __block BOOL ok1 = NO;
    [kvoController observe:model
                   keyPath:@"currentPage"
                   options:0
                     block:^(id observer, id object, NSDictionary *change) {
        ok1 = YES;
    }];
    [document goTo:2 addHistory:YES];
    XCTAssertTrue(ok1);

    __block BOOL ok2 = NO;
    [kvoController observe:model
                   keyPath:@"canGoBack"
                   options:0
                     block:^(id observer, id object, NSDictionary *change) {
        ok2 = model.canGoBack;
    }];
    [document goTo:3 addHistory:YES];
    XCTAssertTrue(ok2);

    __block BOOL ok3 = NO;
    [kvoController observe:model
                   keyPath:@"canGoForward"
                   options:0
                     block:^(id observer, id object, NSDictionary *change) {
        ok3 = model.canGoForward;
    }];
    [document goTo:1 addHistory:YES];
    XCTAssertFalse(ok3);
    [document goBack];
    XCTAssertTrue(ok3);    
}

@end
