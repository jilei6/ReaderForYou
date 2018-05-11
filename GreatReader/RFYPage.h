//
//  RFYPage.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/01/12.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RFYDocumentCrop;
@class RFYPageLink;
@class RFYPageLinkList;
@class RFYRenderingCharacter;

@interface RFYPage : NSObject
@property (nonatomic, assign) CGPDFPageRef CGPDFPage;
@property (nonatomic, readonly) NSUInteger index;
@property (nonatomic, readonly) CGRect rect;
@property (nonatomic, readonly) CGRect croppedRect;
@property (nonatomic, weak) RFYDocumentCrop *crop;
@property (nonatomic, strong) RFYPageLinkList *linkList;
@property (nonatomic, strong) NSArray *characters;
@property (nonatomic, readonly) NSArray *selectedFrames;
@property (nonatomic, readonly) NSArray *selectedCharacters;
@property (nonatomic, readonly) NSString *selectedString;
@property (nonatomic, strong, readonly) NSArray *characterFrames;
- (instancetype)initWithCGPDFPage:(CGPDFPageRef)CGPDFPage;
- (UIImage *)thumbnailImageWithSize:(CGSize)size cropping:(BOOL)cropping;
- (void)drawInRect:(CGRect)rect inContext:(CGContextRef)context cropping:(BOOL)cropping;
- (RFYRenderingCharacter *)characterAtPoint:(CGPoint)point;
- (RFYRenderingCharacter *)nearestCharacterAtPoint:(CGPoint)point;
- (void)selectWordForCharacter:(RFYRenderingCharacter *)character;
- (void)selectCharactersFrom:(RFYRenderingCharacter *)fromCharacter
                          to:(RFYRenderingCharacter *)toCharacter;
- (void)unselectCharacters;
- (RFYPageLink *)linkAtPoint:(CGPoint)point;
@end
