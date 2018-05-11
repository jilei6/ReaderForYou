    //
//  RFYFontDescriptor.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 3/11/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "RFYFontDescriptor.h"

#import "RFYUtils.h"

@interface RFYFontDescriptor ()
@property (nonatomic, assign, readwrite) CGFloat descent;
@property (nonatomic, assign, readwrite) CGFloat ascent;
@end

@implementation RFYFontDescriptor

- (instancetype)initWithFontDescriptorDictionary:(CGPDFDictionaryRef)dictionary
{
    if (!dictionary) return nil;

    self = [super init];
    if (self) {
        _ascent = (CGFloat)PDFDictionaryGetInteger(dictionary, "Ascent");
        _descent = (CGFloat)PDFDictionaryGetInteger(dictionary, "Descent");
    }
    return self;
}

- (instancetype)initWithBaseFont:(NSString *)baseFont
{
    if (!baseFont) return nil;

    self = [super init];
    if (self) {
        UIFont *font = [UIFont fontWithName:baseFont size:10];
        _ascent = [font ascender] * 100;
        _descent = [font descender] * 100;
    }
    return self;
}

@end
