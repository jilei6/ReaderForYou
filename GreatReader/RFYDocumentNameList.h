//
//  RFYDocumentNameList.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 8/5/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RFYDocumentNameList : NSObject
- (instancetype)initWithCGPDFDocument:(CGPDFDocumentRef)document;
- (NSUInteger)pageNumberForName:(NSString *)name;
@end
