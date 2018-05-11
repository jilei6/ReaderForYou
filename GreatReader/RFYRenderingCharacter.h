//
//  RFYRenderingCharacter.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 3/10/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RFYTextState;

@interface RFYRenderingCharacter : NSObject
@property (nonatomic, assign) unichar c;
@property (nonatomic, strong) RFYTextState *state;
@property (nonatomic, readonly) CGRect frame;
@property (nonatomic, readonly) NSString *stringDescription;
- (instancetype)initWithCharacter:(unichar)c
                            state:(RFYTextState *)state;
- (BOOL)isNotWordCharater;
- (BOOL)isSameLineAs:(RFYRenderingCharacter *)character;
@end
