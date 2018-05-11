//
//  RFYCMapParser.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 3/8/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RFYCMapParser;

@protocol PDFCMapParserDelegate <NSObject>
- (void)parser:(RFYCMapParser *)parser
foundCodeSpaceRange:(NSRange)range;
- (void)parser:(RFYCMapParser *)parser
  foundMapping:(NSDictionary *)mapping;
@end

@interface RFYCMapParser : NSObject
- (instancetype)initWithStream:(CGPDFStreamRef)stream;
- (void)parse;
@property (nonatomic, weak) id<PDFCMapParserDelegate> delegate;
@end
