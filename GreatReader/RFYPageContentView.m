//
//  RFYPageContentView.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/01/12.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "RFYPageContentView.h"

#import <QuartzCore/QuartzCore.h>

#import "NSArray+GreatReaderAdditions.h"
#import "RFYPage.h"
#import "RFYPageLink.h"
#import "RFYPageLinkList.h"
#import "RFYPageContentTiledLayer.h"
#import "RFYPageLoopeView.h"
#import "RFYPageSelectionKnob.h"
#import "RFYRenderingCharacter.h"

@interface PDFPageContentTileView : UIView
@property (nonatomic, strong) RFYPage *page;
@property (nonatomic, assign) CGRect rect;
@end

@implementation PDFPageContentTileView

+ (Class)layerClass
{
    return [RFYPageContentTiledLayer class];
}

- (void)drawLayer:(CALayer*)layer inContext:(CGContextRef)context
{
    if (CGRectEqualToRect(self.rect, CGRectZero)) {
        self.rect = self.bounds;
    }
    [self.page drawInRect:self.rect inContext:context cropping:YES];
}

@end

@interface RFYPageContentView () <UIGestureRecognizerDelegate>
@property (nonatomic, strong) PDFPageContentTileView *tileView;
@property (nonatomic, strong) NSMutableArray *selectionViews;
@property (nonatomic, strong) RFYPageSelectionKnob *selectionStartKnob;
@property (nonatomic, strong) RFYPageSelectionKnob *selectionEndKnob;
@property (nonatomic, strong) RFYPageLoopeView *loopeView;
@end

@implementation RFYPageContentView

- (void)dealloc
{
    self.tileView.layer.delegate = nil;
    [self removeObserver:self forKeyPath:@"page.selectedFrames"];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGRect tileFrame = frame;
        tileFrame.origin.x = 0;
        tileFrame.origin.y = 0;
        _tileView = [[PDFPageContentTileView alloc] initWithFrame:tileFrame];
        _tileView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_tileView];

        _selectionViews = [NSMutableArray array];
        [self addObserver:self
               forKeyPath:@"page.selectedFrames"
                  options:0
                  context:NULL];
        
        _loopeView = [[RFYPageLoopeView alloc] init];

        UILongPressGestureRecognizer *longPressGestureRecognizer =
                [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                              action:@selector(longPressed:)];
        longPressGestureRecognizer.delegate = self;
        [self addGestureRecognizer:longPressGestureRecognizer];
    }
    return self;
}

- (void)setPage:(RFYPage *)page
{
    _page = page;
    self.tileView.page = page;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self updateSelectionViews];
    [self updateSelectionKnobs];
    if (self.page.selectedCharacters.count == 0) {
        [self hideMenuControllerIfNeeded];
    }
}

- (void)updateSelectionViews
{
    [self.selectionViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.selectionViews removeAllObjects];

    CGRect rect = CGRectZero;
    NSMutableArray *lines = NSMutableArray.array;
    for (NSValue *v in self.page.selectedFrames) {
        CGRect r = v.CGRectValue;
        CGRect scaleFrame = CGRectApplyAffineTransform(r, self.displayTransform);
        if (CGRectEqualToRect(rect, CGRectZero)) {
            rect = scaleFrame;
            [lines addObject:[NSValue valueWithCGRect:rect]];            
        } else if (fabs(CGRectGetMinY(rect) - CGRectGetMinY(scaleFrame)) > CGRectGetHeight(scaleFrame) / 2.0) {
            rect = scaleFrame;
            [lines addObject:[NSValue valueWithCGRect:rect]];            
        } else {
            rect = CGRectUnion(rect, scaleFrame);
            [lines replaceObjectAtIndex:lines.count - 1
                             withObject:[NSValue valueWithCGRect:rect]];
        }
    }

    for (NSValue *line in lines) {
        CGRect r = line.CGRectValue;
        UIView *v = [[UIView alloc] initWithFrame:r];
        v.backgroundColor = [UIColor colorWithRed:10 / 255.0
                                            green:90 / 255.0
                                             blue:160 / 255.0
                                            alpha:0.2];
        [self addSubview:v];
        [self.selectionViews addObject:v];
    }
}

- (void)updateSelectionKnobs
{
    if (!self.selectionStartKnob) {
        self.selectionStartKnob = [[RFYPageSelectionKnob alloc] initWithFrame:CGRectZero];
        self.selectionStartKnob.start = YES;
        [self.selectionStartKnob addTarget:self
                                    action:@selector(knobChanged:)
                          forControlEvents:UIControlEventValueChanged];
        [self.selectionStartKnob addTarget:self
                                    action:@selector(knobEnded:)
                          forControlEvents:UIControlEventTouchCancel |
                                           UIControlEventTouchUpInside |
                                           UIControlEventTouchUpOutside];
        [self.selectionStartKnob addTarget:self
                                    action:@selector(knobBegan:)
                          forControlEvents:UIControlEventTouchDown];
    }
    if (!self.selectionEndKnob) {
        self.selectionEndKnob = [[RFYPageSelectionKnob alloc] initWithFrame:CGRectZero];
        self.selectionEndKnob.start = NO;        
        [self.selectionEndKnob addTarget:self
                                  action:@selector(knobChanged:)
                        forControlEvents:UIControlEventValueChanged];
        [self.selectionEndKnob addTarget:self
                                  action:@selector(knobEnded:)
                        forControlEvents:UIControlEventTouchCancel |
                                         UIControlEventTouchUpInside |
                                         UIControlEventTouchUpOutside];
        [self.selectionEndKnob addTarget:self
                                  action:@selector(knobBegan:)
                        forControlEvents:UIControlEventTouchDown];        
    }

    if (self.selectionViews.count > 0) {
        UIView *firstSelection = self.selectionViews.firstObject;
        UIView *lastSelection = self.selectionViews.lastObject;
        const CGFloat w = 9;
        self.selectionStartKnob.frame = ({
            CGRect f = [self convertRect:firstSelection.frame toView:self.superview];
            f.origin.x = floorf(f.origin.x - (w / 2.0) - 0.5);
            f.origin.y = floorf(f.origin.y - w);
            f.size.width = w;
            f.size.height = ceilf(f.size.height + w);
            f;
        });
        self.selectionEndKnob.frame = ({
            CGRect f = [self convertRect:lastSelection.frame toView:self.superview];
            f.origin.x = ceilf(CGRectGetMaxX(f) - (w / 2.0) + 0.5);
            f.size.width = w;
            f.size.height = ceilf(f.size.height + w);
            f;
        });
        [self.superview addSubview:self.selectionStartKnob];
        [self.superview addSubview:self.selectionEndKnob];        
    } else {
        [self.selectionStartKnob removeFromSuperview];
        [self.selectionEndKnob removeFromSuperview];
    }
}

- (CGAffineTransform)displayTransform
{
    CGAffineTransform invertTransform = CGAffineTransformInvert(self.transform);
    CGRect f = CGRectApplyAffineTransform(self.frame, invertTransform);    
    CGFloat scale = CGRectGetWidth(f) / CGRectGetWidth(self.page.rect);

    CGAffineTransform scaleT = CGAffineTransformMakeScale(scale, scale);
    CGAffineTransform translateT =
            CGAffineTransformMakeTranslation(0, 0);
                                             // (f.size.height - CGRectGetMaxY(self.page.rect)));
    return CGAffineTransformConcat(scaleT, translateT);
}

- (CGFloat)scale
{
    CGAffineTransform invertTransform = CGAffineTransformInvert(self.transform);
    CGRect f = CGRectApplyAffineTransform(self.frame, invertTransform);
    return CGRectGetWidth(f) / CGRectGetWidth(self.page.rect);
}

- (CGRect)selectionFrame
{
    if (!self.selectionViews) {
        return CGRectZero;
    } else {
        CGRect rect = [[self.selectionViews firstObject] frame];
        for (int i = 1; i < self.selectionViews.count; i++) {
            CGRect r = [self.selectionViews[i] frame];
            rect = CGRectUnion(rect, r); 
        }
        return rect;
    }
}

- (void)showLoopeAtPoint:(CGPoint)point
                  inView:(UIView *)containerView
{
    if (!self.loopeView.superview) {
        [containerView addSubview:self.loopeView];
    }
    point = [self convertPoint:point toView:containerView];
    self.loopeView.center = CGPointMake(roundf(point.x), roundf(point.y));
    UIGraphicsBeginImageContextWithOptions(self.loopeView.frame.size, NO, 4.0);  {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGPoint p = [self convertPoint:self.loopeView.frame.origin
                              fromView:containerView];
        CGAffineTransform transform = CGAffineTransformIdentity;
        transform = CGAffineTransformConcat(transform, self.transform);
        transform = CGAffineTransformTranslate(transform, -p.x, -p.y);        
        CGContextConcatCTM(context, transform);
        [self.layer renderInContext:context];
        self.loopeView.image = UIGraphicsGetImageFromCurrentImageContext();
    } UIGraphicsEndImageContext();

    self.loopeView.center =
            CGPointMake(self.loopeView.center.x,
                        self.loopeView.center.y - self.loopeView.frame.size.height / 2.0 - 20);

    [self hideMenuControllerIfNeeded];
}

- (void)hideLoope
{
    [self.loopeView removeFromSuperview];
}

- (void)redraw
{
    self.tileView.layer.contents = nil;
    self.tileView.rect = CGRectZero;
    [self.tileView setNeedsDisplay];
}

#pragma mark - Knob Changed

- (void)knobChanged:(RFYPageSelectionKnob *)knob
{
    CGFloat scale = self.scale;
    RFYRenderingCharacter *start = knob == self.selectionStartKnob ? ({
        CGPoint point = [self convertPoint:self.selectionStartKnob.point
                                  fromView:self.selectionStartKnob.superview];
        [self.page nearestCharacterAtPoint:CGPointMake(point.x / scale,
                                                       point.y / scale)];
    }) : nil;
    RFYRenderingCharacter *end = knob == self.selectionEndKnob ? ({
        CGPoint point = [self convertPoint:self.selectionEndKnob.point
                                  fromView:self.selectionEndKnob.superview];
        [self.page nearestCharacterAtPoint:CGPointMake(point.x / scale,
                                                       point.y / scale)];
    }) : nil;
    [self.page selectCharactersFrom:start
                                 to:end];

    [self showLoopeAtPoint:[self convertPoint:knob.point fromView:knob.superview]
                    inView:[self.delegate loopeContainerViewForContentView:self]];    
}

- (void)knobEnded:(RFYPageSelectionKnob *)knob
{
    [self showSelectionMenuFromRect:self.selectionFrame
                             inView:self];
    [self hideLoope];
}

- (void)knobBegan:(RFYPageSelectionKnob *)knob
{
    CGPoint point = [self convertPoint:knob.point
                              fromView:knob.superview];
    [self showLoopeAtPoint:point
                    inView:[self.delegate loopeContainerViewForContentView:self]];
}

#pragma mark -

- (void)zoomStarted
{
    [self.selectionStartKnob removeFromSuperview];
    [self.selectionEndKnob removeFromSuperview];
}

- (void)zoomFinished
{
    [self updateSelectionKnobs];
}

#pragma mark -

- (void)longPressed:(UILongPressGestureRecognizer *)recognizer
{
    CGPoint point = [recognizer locationInView:self];
    CGFloat scale = self.scale;
    RFYRenderingCharacter *c = [self.page characterAtPoint:CGPointMake(point.x / scale,
                                                                       point.y / scale)];
    if (c) {
        [self.page selectWordForCharacter:c];
    } else {
        [self.page unselectCharacters];
    }

    if (recognizer.state == UIGestureRecognizerStateEnded) {
        [self hideLoope];
        if (self.page.selectedCharacters.count > 0) {
            [self showSelectionMenuFromRect:self.selectionFrame
                                     inView:self];
        }
    } else {
        [self showLoopeAtPoint:point
                        inView:[self.delegate loopeContainerViewForContentView:self]];
    }
}

#pragma mark -

- (void)showSelectionMenuFromRect:(CGRect)rect
                           inView:(UIView *)view
{
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    NSMutableArray* menuItems = [NSMutableArray array];
    [menuItems addObject:
                   [[UIMenuItem alloc] initWithTitle:LocalizedString(@".copy")
                                              action:@selector(copySelectedString:)]];
    [menuItems addObject:
                   [[UIMenuItem alloc] initWithTitle:LocalizedString(@".define")
                                              action:@selector(lookupSelectedString:)]];    
    menuController.menuItems = menuItems;
    menuController.arrowDirection = UIMenuControllerArrowDefault;
    [menuController setTargetRect:rect
                           inView:view];
    [self becomeFirstResponder];
    [menuController setMenuVisible:YES animated:YES];

    __block __weak id observer =
        [NSNotificationCenter.defaultCenter
            addObserverForName:UIMenuControllerDidHideMenuNotification
                        object:menuController
                         queue:NSOperationQueue.mainQueue
                    usingBlock:^(NSNotification *notification) {
            [NSNotificationCenter.defaultCenter removeObserver:observer];
            if (self.loopeView.isHidden || self.loopeView.superview == nil) {
                [self.page unselectCharacters];
            }
        }];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(lookupSelectedString:) &&
        [self.delegate respondsToSelector:@selector(contentView:lookupMenuSelected:)]) {
        return YES;
    } else if (action == @selector(copySelectedString:) &&
        [self.delegate respondsToSelector:@selector(contentView:copyMenuSelected:)]) {
        return YES;
    }
    return NO;
}


- (void)lookupSelectedString:(id)sender
{
    [self.delegate contentView:self
            lookupMenuSelected:self.page.selectedString];
    [self.page unselectCharacters];
}

- (void)copySelectedString:(id)sender
{
    [self.delegate contentView:self
              copyMenuSelected:self.page.selectedString];
    [self.page unselectCharacters];
}

#pragma mark - UIGestureRecognizer Delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return ![touch.view isKindOfClass:UIControl.class];
}

#pragma mark -

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self hideMenuControllerIfNeeded];
}

- (void)hideMenuControllerIfNeeded
{
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    if (menuController.menuVisible) {
        [menuController setMenuVisible:NO animated:YES];
    }
}

@end
