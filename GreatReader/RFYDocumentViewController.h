//
//  RFYDocumentViewController.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2013/12/17.
//  Copyright (c) 2013 MIYAMOTO Shohei. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RFYDocumentPageSlider.h"

@class RFYDocument;
@class RFYRecentDocumentList;
@class RFYPageViewController;

@interface RFYDocumentViewController : UIViewController <PDFDocumentPageSliderDelegate>
@property (nonatomic, strong) RFYDocument *document;
@property (nonatomic, readonly) RFYPageViewController *currentPageViewController;

- (IBAction)exitCrop:(UIStoryboardSegue *)segue;
- (IBAction)exitBrightness:(UIStoryboardSegue *)segue;
- (IBAction)exitOutline:(UIStoryboardSegue *)segue;
- (IBAction)exitBookmark:(UIStoryboardSegue *)segue;
- (IBAction)exitHistory:(UIStoryboardSegue *)segue;
- (IBAction)exitSearch:(UIStoryboardSegue *)segue;

- (IBAction)toggleRibbon:(id)sender;

- (void)goAtIndex:(NSUInteger)index animated:(BOOL)animated;
- (void)openDocument:(RFYDocument *)document;
    
@end
