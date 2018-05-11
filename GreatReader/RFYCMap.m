//
//  RFYCMap.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 3/8/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "RFYCMap.h"

#import "RFYCMapParser.h"

@interface RFYCMap () <PDFCMapParserDelegate>
@property (nonatomic, assign) NSRange codeSpaceRange;
@property (nonatomic, strong) NSMutableDictionary *characterMapping;
@property (nonatomic, strong) NSMutableDictionary *unicodeFromCID;
@property (nonatomic, strong) NSMutableDictionary *CIDFromUnicode;
@end

@implementation RFYCMap

- (instancetype)initWithStream:(CGPDFStreamRef)stream
{
    self = [super init];
    if (self) {
        _unicodeFromCID = [NSMutableDictionary dictionary];
        _CIDFromUnicode = [NSMutableDictionary dictionary];
        RFYCMapParser *parser = [[RFYCMapParser alloc] initWithStream:stream];
        parser.delegate = self;
        [parser parse];
    }
    return self;
}

- (BOOL)canConvertCID:(char)cid
{
    return [self.unicodeFromCID objectForKey:@(cid)] != nil;
}

- (unichar)unicodeFromCID:(char)cid
{
    NSNumber *num = [self.unicodeFromCID objectForKey:@(cid)];
    return num ? [num unsignedCharValue] : cid;
}

- (char)CIDFromUnicode:(unichar)unicode
{
    NSNumber *num = [self.CIDFromUnicode objectForKey:@(unicode)];
    return num ? [num unsignedCharValue] : unicode;
}

#pragma mark -

- (void)parser:(RFYCMapParser *)parser
foundCodeSpaceRange:(NSRange)range
{
    self.codeSpaceRange = range;
}

- (void)parser:(RFYCMapParser *)parser
  foundMapping:(NSDictionary *)mapping
{
    [self.unicodeFromCID addEntriesFromDictionary:mapping];
    [self.CIDFromUnicode setObject:mapping.allKeys.firstObject
                            forKey:mapping.allValues.firstObject];
}

@end
