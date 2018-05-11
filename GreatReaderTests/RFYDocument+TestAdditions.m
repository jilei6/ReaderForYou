//
//  RFYDocument+TestAdditions.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 7/23/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "RFYDocument+TestAdditions.h"

#import "RFYDocument.h"

@implementation RFYDocument (TestAdditions)

+ (RFYDocument *)test_documentWithPDFName:(NSString *)name
{
    NSString *resourcePath = [[NSBundle bundleForClass:self]
                                 pathForResource:name
                                          ofType:@"pdf"];
    RFYDocument *document = [[RFYDocument alloc] initWithPath:resourcePath];
    return document;
}

@end
