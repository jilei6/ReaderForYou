//
//  RFYFontCollection.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 3/5/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "RFYFontCollection.h"

#import "RFYFont.h"

@interface RFYFontCollection ()
@property (nonatomic, assign) CGPDFDictionaryRef fontDictionary;
@property (nonatomic, strong) NSMutableDictionary *fonts;
- (void)addFont:(RFYFont *)font forName:(NSString *)name;
@end


void PDFFontCollectionGetFont(const char *key, CGPDFObjectRef object, void *info) {
    RFYFontCollection *collection = (__bridge RFYFontCollection *)info;
    NSString *name = [NSString stringWithCString:key encoding:NSASCIIStringEncoding];
    CGPDFDictionaryRef dictionary = NULL;
    if (CGPDFObjectGetValue(object, kCGPDFObjectTypeDictionary, &dictionary)) {
        RFYFont *font = [RFYFont fontWithFontDictionary:dictionary];
        [collection addFont:font forName:name];
    }
}

@implementation RFYFontCollection

- (instancetype)initWithCGPDFPage:(CGPDFPageRef)CGPDFPage
{
    self = [super init];
    if (self) {
        _fonts = [NSMutableDictionary dictionary];
        CGPDFDictionaryRef fontDictionary = [self findFontDictionaryInPage:CGPDFPage];
        if (fontDictionary) {
            CGPDFDictionaryApplyFunction(fontDictionary,
                                         &PDFFontCollectionGetFont,
                                         (__bridge void *)self);
        }
    }
    return self;
}

- (CGPDFDictionaryRef)findFontDictionaryInPage:(CGPDFPageRef)CGPDFPage
{
    CGPDFDictionaryRef dictionary = CGPDFPageGetDictionary(CGPDFPage);    
    CGPDFDictionaryRef resources = NULL;
    if (CGPDFDictionaryGetDictionary(dictionary, "Resources", &resources)) {
        CGPDFDictionaryRef font = NULL;
        if (CGPDFDictionaryGetDictionary(resources, "Font", &font)) {
            return font;
        }
    }
    return NULL;
}

- (void)addFont:(RFYFont *)font forName:(NSString *)name
{
    [self.fonts setObject:font forKey:name];
}

- (RFYFont *)fontForName:(NSString *)name
{
    return [self.fonts objectForKey:name];
}

@end
