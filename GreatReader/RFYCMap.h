//
//  RFYCMap.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 3/8/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RFYCMap : NSObject
- (instancetype)initWithStream:(CGPDFStreamRef)stream;
- (unichar)unicodeFromCID:(char)cid;
- (char)CIDFromUnicode:(unichar)unicode;
- (BOOL)canConvertCID:(char)cid;
@end
