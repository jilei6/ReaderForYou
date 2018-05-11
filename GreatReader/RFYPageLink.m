//
//  RFYPageLink.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 7/30/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "RFYPageLink.h"

@interface RFYPageLink ()
@property (nonatomic, readwrite, assign) NSUInteger pageNumber;
@property (nonatomic, readwrite, assign) CGRect rect;
@end

@implementation RFYPageLink

- (instancetype)initWithPageNumber:(NSUInteger)pageNumber
                               rect:(CGRect)rect
{
    self = [super init];
    if (self) {
        _pageNumber = pageNumber;
        _rect = rect;
    }
    return self;
}

@end
