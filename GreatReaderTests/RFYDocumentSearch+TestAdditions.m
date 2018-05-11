//
//  RFYDocumentSearch+TestAdditions.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 7/10/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "RFYDocumentSearch+TestAdditions.h"

#import "RFYDocument.h"

@implementation RFYDocumentSearch (TestAdditions)

+ (RFYDocumentSearch *)test_searchWithPDFName:(NSString *)name
{
    NSString *resourcePath = [[NSBundle bundleForClass:self]
                                 pathForResource:name
                                          ofType:@"pdf"];
    RFYDocument *document = [[RFYDocument alloc] initWithPath:resourcePath];
    RFYDocumentSearch *search = [[RFYDocumentSearch alloc] initWithDocument:document];
    return search;
}

@end
