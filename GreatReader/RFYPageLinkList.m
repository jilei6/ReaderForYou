//
//  RFYPageLinkList.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 7/29/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "RFYPageLinkList.h"

#import "RFYDocumentNameList.h"
#import "RFYPageLink.h"
#import "RFYUtils.h"

@implementation RFYPageLinkList

- (instancetype)initWithCGPDFPage:(CGPDFPageRef)cgPage
                         nameList:(RFYDocumentNameList *)nameList
{
    self = [super init];
    if (self) {
        _links = [self parse:cgPage
                    nameList:nameList];
    }
    return self;
}

- (NSArray *)parse:(CGPDFPageRef)cgPage
          nameList:(RFYDocumentNameList *)nameList
{
    NSMutableArray *results = NSMutableArray.array;
    
    CGPDFDictionaryRef dic = CGPDFPageGetDictionary(cgPage);
    CGPDFArrayRef annots = PDFDictionaryGetArray(dic, "Annots");
    for (int i = 0; i < CGPDFArrayGetCount(annots); i++) {
        CGPDFDictionaryRef a = PDFArrayGetDictionary(annots, i);
        const char *subtype = PDFDictionaryGetName(a, "Subtype");
        if (!strcmp(subtype, "Link")) {
            CGPDFObjectRef dest = PDFDictionaryGetObject(a, "Dest");
            NSString *key = [self stringForDest:dest];            
            NSUInteger pageNumber = [nameList pageNumberForName:key];
            if (pageNumber != NSNotFound) {
                CGPDFArrayRef rect = PDFDictionaryGetArray(a, "Rect");
                CGFloat minX = PDFArrayGetNumber(rect, 0);
                CGFloat minY = PDFArrayGetNumber(rect, 1);
                CGFloat maxX = PDFArrayGetNumber(rect, 2);
                CGFloat maxY = PDFArrayGetNumber(rect, 3);
                CGRect cgrect = CGRectMake(minX, minY, maxX - minX, maxY - minY);
                RFYPageLink *link = [[RFYPageLink alloc] initWithPageNumber:pageNumber
                                                                       rect:cgrect];
                [results addObject:link];
            }
        }
    }

    return results;
}

- (NSString *)stringForDest:(CGPDFObjectRef)dest
{
    switch (CGPDFObjectGetType(dest)) {
        case kCGPDFObjectTypeName: {
            const char *name = NULL;
            CGPDFObjectGetValue(dest, kCGPDFObjectTypeName, &name);
            return [[NSString alloc] initWithCString:name encoding:NSUTF8StringEncoding];
        }
        case kCGPDFObjectTypeString: {
            CGPDFStringRef str = NULL;
            CGPDFObjectGetValue(dest, kCGPDFObjectTypeString, &str);
            return (__bridge_transfer NSString *)CGPDFStringCopyTextString(str);
        }
        case kCGPDFObjectTypeArray: {
            return nil;
        }
        default: {
            return nil;
        }
    }
}

@end
