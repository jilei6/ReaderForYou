//
//  RFYText.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 3/2/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RFYTextState;

@interface RFYText : NSObject
- (instancetype)initWithText:(NSString *)text
                       state:(RFYTextState *)state;
@property (nonatomic, strong) RFYTextState *state;
@property (nonatomic, copy) NSString *text;
@end
