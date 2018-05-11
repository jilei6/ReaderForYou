//
//  RFYText.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 3/2/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "RFYText.h"

#import "RFYTextState.h"

@implementation RFYText

- (instancetype)initWithText:(NSString *)text
                       state:(RFYTextState *)state
{
    self = [super init];
    if (self) {
        _text = text;
        _state = state;
    }
    return self;
}

@end
