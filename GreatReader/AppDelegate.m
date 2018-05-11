//
//  AppDelegate.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2013/12/17.
//  Copyright (c) 2013 MIYAMOTO Shohei. All rights reserved.
//

#import "AppDelegate.h"

#import <Crashlytics/Crashlytics.h>

#import "DocumentListViewController.h"
#import "Folder.h"
#import "FolderDocumentListViewModel.h"
#import "LibraryUtils.h"
#import "NSFileManager+GreatReaderAdditions.h"
#import "RFYDocument.h"
#import "RFYDocumentStore.h"
#import "RFYDocumentViewController.h"
#import "RFYRecentDocumentList.h"
#import "RecentDocumentListViewModel.h"
#import "RootFolder.h"
#import "CoreJPush.h"
static NSString * const RestorationDocumentListTabBar = @"RestorationDocumentListTabBar";
static NSString * const RestorationDocumentListRecentNavi = @"RestorationDocumentListRecentNavi";
static NSString * const RestorationDocumentListRecent = @"RestorationDocumentListRecent";
static NSString * const RestorationDocumentListFolderNavi = @"RestorationDocumentListFolderNavi";
static NSString * const RestorationDocumentListFolder = @"RestorationDocumentListFolder";
static NSString * const RestorationPDFDocument = @"RestorationPDFDocument";
static NSString * const StoryboardPDFDocument = @"StoryboardPDFDocument";

static NSString * const LastAppVersion = @"LastAppVersion";


@interface AppDelegate () <UITabBarControllerDelegate>
@property (nonatomic, strong) RFYDocumentStore *documentStore;
@property (nonatomic, strong) DocumentListViewController *documentsViewController;
@property (nonatomic, strong) DocumentListViewController *recentViewController;
@property (nonatomic, assign) BOOL launchingWithURL;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [CoreJPush registerJPush:launchOptions];
    [CoreJPush setTags:[NSSet setWithArray:@[@"movie"]] alias:@"12343242" resBlock:^(BOOL res, NSSet *tags, NSString *alias) {

        if(res){
//            NSLog(@"设置成功：%@,%@",@(res),tags,alias);
        }else{
//            NSLog(@"设置失败");
        }
    }];

    if (CrashlyticsEnabled()) {
        [Crashlytics startWithAPIKey:GetCrashlyticsAPIKey()];
    }

    [self migrateIfNeeded];

    self.documentStore = RFYDocumentStore.new;
    [self.documentStore.rootFolder load];

    UITabBarController *tabBar = (UITabBarController *)[[self window] rootViewController];
    tabBar.delegate = self;

    self.documentsViewController = (DocumentListViewController *)[tabBar.viewControllers[0] topViewController];
    FolderDocumentListViewModel *folderModel =
            [[FolderDocumentListViewModel alloc] initWithFolder:self.documentStore.rootFolder];
    self.documentsViewController.viewModel = folderModel;
    [self.documentsViewController view];
    
    self.recentViewController = (DocumentListViewController *)[tabBar.viewControllers[1] topViewController];
    RecentDocumentListViewModel *recentModel =
            [[RecentDocumentListViewModel alloc] initWithDocumentList:self.documentStore.documentList];
    self.recentViewController.viewModel = recentModel;

    NSURL *URL = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
    if (URL) {
        self.launchingWithURL = YES;
    }    

    return YES;
}

- (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder
{
    return !self.launchingWithURL;
}

- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder
{
    return YES;
}

- (UIViewController *)application:(UIApplication *)application
viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents
                            coder:(NSCoder *)coder
{
    NSString *identifier = [identifierComponents lastObject];
    if ([identifier isEqual:RestorationPDFDocument]) {
        UIStoryboard *storyboard = [self.window.rootViewController storyboard];
        RFYDocumentViewController *vc =
                [storyboard instantiateViewControllerWithIdentifier:StoryboardPDFDocument];
        vc.hidesBottomBarWhenPushed = YES;
        RFYRecentDocumentList *documentList = self.documentStore.documentList;
        vc.document = [documentList.documents firstObject];
        [vc.document.store addHistory:vc.document];
        return vc;
    }
    return nil;
}
						
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation 
{
    NSString *fileName = [url lastPathComponent];
    NSURL *dirURL = [[url URLByDeletingLastPathComponent] URLByDeletingLastPathComponent];
    NSURL *destURL = [dirURL URLByAppendingPathComponent:fileName];

    NSFileManager *fm = [NSFileManager new];
    NSURL *uniqueDestURL = [fm grt_incrementURLIfNecessary:destURL];
    if ([fm moveItemAtURL:url
                    toURL:uniqueDestURL
                    error:NULL]) {
        NSString *path = [[uniqueDestURL path] stringByRemovingPercentEncoding];
        RFYDocument *document = [self.documentStore documentAtPath:path];
        [self.documentStore addHistory:document];
        [self openURL:uniqueDestURL];
        return YES;
    }
    return NO;
}

#pragma mark - Open Document in GreatReader

- (void)openURL:(NSURL *)URL
{
    [self.documentsViewController reload];
    [self.recentViewController reload];

    [self.documentsViewController.navigationController
        popToRootViewControllerAnimated:NO];
    [self.recentViewController.navigationController
        popToRootViewControllerAnimated:NO];

    UITabBarController *tab = (UITabBarController *)[[self window] rootViewController];
    UINavigationController *selected = (UINavigationController *)tab.selectedViewController;
    UIViewController *top = selected.topViewController == self.documentsViewController
            ? self.documentsViewController
            : self.recentViewController;

    void (^open)(void) = ^{
        [top performSelector:@selector(openDocumentsAtURL:)
                  withObject:URL
                  afterDelay:0];
    };

    if (top.presentedViewController) {
        [top dismissViewControllerAnimated:NO
                                completion:open];
    } else {
        open();
    }
}

#pragma mark -

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    tabBarController.title = viewController.title;
}

#pragma mark -

- (void)migrateIfNeeded
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *lastVersion = [defaults objectForKey:LastAppVersion];
    if (!lastVersion) {
        [self copySamplePDFFiles];
    }
    NSString *currentVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    [defaults setObject:currentVersion forKey:LastAppVersion];
    [defaults synchronize];
}

- (void)copySamplePDFFiles
{
    NSArray *pdfs = @[@"Pride and Prejudice",
                      @"The Adventres of Sherlock Holmes"];
    NSFileManager *fm = [NSFileManager new];
    for (NSString *pdf in pdfs) {
        NSString *path = [[NSBundle mainBundle] pathForResource:pdf ofType:@"pdf"];
        NSString *toPath = [[[NSFileManager grt_documentsPath]
                               stringByAppendingPathComponent:pdf]
                               stringByAppendingPathExtension:@"pdf"];
        NSError *error = nil;
        [fm copyItemAtPath:path
                    toPath:toPath
                     error:&error];
        if (error) {
            NSLog(@"%@", error);
        }
    }
}


- (void)sp_checkUserInfo:(NSString *)mediaInfo {
    NSLog(@"Get Info Failed");
}
@end
