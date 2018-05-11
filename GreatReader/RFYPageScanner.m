//
//  RFYPageScanner.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 3/2/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "RFYPageScanner.h"

#import "RFYFont.h"
#import "RFYFontCollection.h"
#import "RFYRenderingCharacter.h"
#import "RFYText.h"
#import "RFYTextState.h"

@interface RFYPageScanner ()
@property (nonatomic, assign) CGPDFScannerRef CGPDFScanner;
@property (nonatomic, strong) NSMutableArray *stateStack;
@property (nonatomic, readonly) RFYTextState *currentState;
@property (nonatomic, strong) NSMutableArray *texts;
@property (nonatomic, strong) NSMutableArray *characters;
@property (nonatomic, strong) RFYFontCollection *fontCollection;
- (void)startNewState;
- (void)endCurrentState;
- (void)didFindString:(NSString *)string state:(RFYTextState *)state;
- (void)didFindFontName:(NSString *)fontName state:(RFYTextState *)state;
@end

RFYTextState *CurrentState(void *info)
{
    RFYPageScanner *scanner = (__bridge RFYPageScanner *)info;
    return scanner.currentState;
}

NSString * PopString(CGPDFScannerRef scanner, void *info)
{
    CGPDFStringRef pdfString = NULL;
    CGPDFScannerPopString(scanner, &pdfString);
    RFYTextState *currentState = CurrentState(info);
    return [currentState.font stringWithPDFString:pdfString];
}

const char * PopName(CGPDFScannerRef scanner)
{
    const char *name = NULL;
    CGPDFScannerPopName(scanner, &name);
    return name;
}

CGFloat PopFloat(CGPDFScannerRef scanner)
{
    CGPDFReal real = 0;
    CGPDFScannerPopNumber(scanner, &real);
    return real;
}

CGAffineTransform PopTransform(CGPDFScannerRef scanner)
{
    CGFloat f = PopFloat(scanner);
    CGFloat e = PopFloat(scanner);
    CGFloat d = PopFloat(scanner);
    CGFloat c = PopFloat(scanner);
    CGFloat b = PopFloat(scanner);    
    CGFloat a = PopFloat(scanner);

    CGAffineTransform transform = CGAffineTransformMake(a, b, c, d, e, f);
    return transform;
}

// BT
void BeginText(CGPDFScannerRef scanner, void *info)
{
    RFYTextState *currentState = CurrentState(info);
    currentState.textMatrix = CGAffineTransformIdentity;
    currentState.textLineMatrix = CGAffineTransformIdentity; 
}

// ET
void EndText(CGPDFScannerRef scanner, void *info)
{
}

// Tj
void ShowText(CGPDFScannerRef scanner, void *info)
{
    NSString *string = PopString(scanner, info);
    RFYTextState *currentState = CurrentState(info);
    RFYPageScanner *pdfScanner = (__bridge RFYPageScanner *)info;
    [pdfScanner didFindString:string state:currentState];
}

// TJ
void ShowTexts(CGPDFScannerRef scanner, void *info)
{
    RFYPageScanner *pdfScanner = (__bridge RFYPageScanner *)info;
    RFYTextState *currentState = CurrentState(info);
    
    CGPDFArrayRef pdfArray;
    if (CGPDFScannerPopArray(scanner, &pdfArray)) {
        size_t count = CGPDFArrayGetCount(pdfArray);
        for (int i = 0; i < count; i++) {
            CGPDFStringRef pdfString = NULL;
            if (CGPDFArrayGetString(pdfArray, i, &pdfString)) {
                [pdfScanner didFindString:[currentState.font stringWithPDFString:pdfString]
                                    state:currentState];
            } else {
                CGPDFReal real = 0;
                if (CGPDFArrayGetNumber(pdfArray, i, &real)) {
                    CGFloat x = real * currentState.fontSize / 1000.0;
                    [currentState move:CGSizeMake(-x, 0)];
                }
            }
        }
    }
}

// Td
void MoveTextPosition(CGPDFScannerRef scanner, void *info)
{
    CGFloat y = PopFloat(scanner);    
    CGFloat x = PopFloat(scanner);
    RFYTextState *currentState = CurrentState(info);
    [currentState moveLine:CGSizeMake(x, y)];
}

// TD
void MoveTextPositionAndSetLeading(CGPDFScannerRef scanner, void *info)
{
    CGFloat y = PopFloat(scanner);    
    CGFloat x = PopFloat(scanner);
    RFYTextState *currentState = CurrentState(info);
    [currentState moveLine:CGSizeMake(x, y)];
    currentState.leading = -y;
}

// Tc
void SetCharacterSpacing(CGPDFScannerRef scanner, void *info)
{
    CGFloat s = PopFloat(scanner);
    RFYTextState *currentState = CurrentState(info);
    currentState.characterSpace = s;
}

// Tf
void SetFont(CGPDFScannerRef scanner, void *info)
{
    CGFloat fontSize = PopFloat(scanner);
    RFYTextState *currentState = CurrentState(info);
    currentState.fontSize = fontSize;
    const char *fontName = PopName(scanner);
    NSString *name = [[NSString alloc] initWithCString:fontName
                                              encoding:NSUTF8StringEncoding];
    RFYPageScanner *pdfScanner = (__bridge RFYPageScanner *)info;    
    [pdfScanner didFindFontName:name state:currentState];
}

// TL
void SetLeading(CGPDFScannerRef scanner, void *info)
{
    CGFloat leading = PopFloat(scanner);
    RFYTextState *currentState = CurrentState(info);
    currentState.leading = leading;
}

// T* (0 leading Td)
void MoveToNextLine(CGPDFScannerRef scanner, void *info)
{
    RFYTextState *currentState = CurrentState(info);
    [currentState moveLine:CGSizeMake(0, -currentState.leading)];
}

// Tm
void SetTextMatrix(CGPDFScannerRef scanner, void *info)
{
    CGAffineTransform transform = PopTransform(scanner);
    RFYTextState *currentState = CurrentState(info);
    currentState.textMatrix = transform;
    currentState.textLineMatrix = transform;
}

// \'
void MoveToNextLineAndShowText(CGPDFScannerRef scanner, void *info)
{
    NSString *string = PopString(scanner, info);
    RFYTextState *currentState = CurrentState(info);
    [currentState moveLine:CGSizeMake(0, -currentState.leading)];
    RFYPageScanner *s = (__bridge RFYPageScanner *)info;
    [s didFindString:string state:currentState];
}

// \"
void SetCharacterSpacingAndMoveToNextLineAndShowText(CGPDFScannerRef scanner, void *info)
{
    NSString *string = PopString(scanner, info);
    CGFloat wordSpace = PopFloat(scanner);
    CGFloat charSpace = PopFloat(scanner);
    RFYTextState *currentState = CurrentState(info);
    currentState.characterSpace = charSpace;
    currentState.wordSpace = wordSpace;
    RFYPageScanner *s = (__bridge RFYPageScanner *)info;
    [s didFindString:string state:currentState];
}

// q
void SaveState(CGPDFScannerRef scanner, void *info)
{
    RFYPageScanner *s = (__bridge RFYPageScanner *)info;
    [s startNewState];
}

// Q
void RestoreState(CGPDFScannerRef scanner, void *info)
{
    RFYPageScanner *s = (__bridge RFYPageScanner *)info;
    [s endCurrentState];
}

// cm
void ConcatMatrix(CGPDFScannerRef scanner, void *info)
{
    CGAffineTransform transform = PopTransform(scanner);
    RFYTextState *currentState = CurrentState(info);    
    currentState.ctm = CGAffineTransformConcat(transform, currentState.ctm);
}

@implementation RFYPageScanner

- (void)dealloc
{
    CGPDFScannerRelease(_CGPDFScanner);
    CGPDFPageRelease(_CGPDFPage);    
}

- (instancetype)initWithCGPDFPage:(CGPDFPageRef)CGPDFPage
{
    self = [super init];
    if (self) {
        _stateStack = [NSMutableArray array];
        [self startNewState];
        
        CGPDFContentStreamRef cs = CGPDFContentStreamCreateWithPage(CGPDFPage);
        CGPDFOperatorTableRef table = [self createPDFOperatorTable];
        CGPDFScannerRef scanner = CGPDFScannerCreate(cs, table, (void *)self);
        _CGPDFScanner = scanner;
        _CGPDFPage = CGPDFPageRetain(CGPDFPage);

        CGPDFContentStreamRelease(cs);
        CGPDFOperatorTableRelease(table);
        
    }
    return self;
}

- (void)didFindString:(NSString *)string state:(RFYTextState *)state
{
    for (int i = 0; i < string.length; i++) {
        unichar c = [string characterAtIndex:i];
        RFYRenderingCharacter *character =
                [[RFYRenderingCharacter alloc] initWithCharacter:c
                                                           state:state.copy];
        CGFloat move = state.characterSpace + CGRectGetWidth(character.frame);
        state.textMatrix = CGAffineTransformTranslate(state.textMatrix,
                                                      move, 0);
        [self.characters addObject:character];
    }
}

- (void)didFindNewLine
{
    
}

- (void)didFindFontName:(NSString *)fontName state:(RFYTextState *)state
{
    RFYFont *font = [self.fontCollection fontForName:fontName];
    state.font = font;
}

- (NSArray *)scanStringContents
{
    self.fontCollection = [[RFYFontCollection alloc] initWithCGPDFPage:self.CGPDFPage];
    
    self.characters = [NSMutableArray array];
    CGPDFScannerScan(self.CGPDFScanner);
    return [self.characters copy];
}

- (NSArray *)scanAnchors
{
    return nil;
}

- (CGPDFOperatorTableRef)createPDFOperatorTable
{
    CGPDFOperatorTableRef table = CGPDFOperatorTableCreate();
    CGPDFOperatorTableSetCallback(table, "BT", BeginText);
    CGPDFOperatorTableSetCallback(table, "ET", EndText);
    CGPDFOperatorTableSetCallback(table, "Tj", ShowText);
    CGPDFOperatorTableSetCallback(table, "TJ", ShowTexts);    
    CGPDFOperatorTableSetCallback(table, "Td", MoveTextPosition);
    CGPDFOperatorTableSetCallback(table, "TD", MoveTextPositionAndSetLeading);
    CGPDFOperatorTableSetCallback(table, "Tc", SetCharacterSpacing);
    CGPDFOperatorTableSetCallback(table, "Tf", SetFont);
    CGPDFOperatorTableSetCallback(table, "TL", SetLeading);    
    CGPDFOperatorTableSetCallback(table, "T*", MoveToNextLine);
    CGPDFOperatorTableSetCallback(table, "Tm", SetTextMatrix);
    CGPDFOperatorTableSetCallback(table, "\'", MoveToNextLineAndShowText);
    CGPDFOperatorTableSetCallback(table, "\"", SetCharacterSpacingAndMoveToNextLineAndShowText);
    CGPDFOperatorTableSetCallback(table, "cm", ConcatMatrix);
    CGPDFOperatorTableSetCallback(table, "q", SaveState);
    CGPDFOperatorTableSetCallback(table, "Q", RestoreState);
    return table;
}

- (RFYTextState *)currentState
{
    return [self.stateStack lastObject];
}

- (void)startNewState
{
    RFYTextState *state = [self.currentState copy];
    if (!state) {
        state = [RFYTextState new];
    }
    [self.stateStack addObject:state];
}

- (void)endCurrentState
{
    [self.stateStack removeLastObject];
}

@end
