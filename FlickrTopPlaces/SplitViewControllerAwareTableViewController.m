//
//  SplitViewControllerAwareViewController.m
//  FlickrTopPlaces
//
//  Created by Hossam Hammady on 3/5/12.
//  Copyright (c) 2012 Texas A&M University at Qatar. All rights reserved.
//

#import "SplitViewControllerAwareTableViewController.h"

@implementation SplitViewControllerAwareTableViewController

#pragma mark split view utilities

-(FlickrMapViewController*) mapViewControllerForSplitViewController:(UISplitViewController*) splitVC
{
    // if iPad then will return the FlickrMapViewController (detail vc),
        
    UIViewController *vc = [splitVC.viewControllers lastObject];
    
    if (![vc isKindOfClass:[UINavigationController class]]) return nil;
    
    UINavigationController *detailNC = (UINavigationController *) vc;
    
    for (vc in [detailNC viewControllers]) {
        if ([vc isKindOfClass:[FlickrMapViewController class]])
            return (FlickrMapViewController*) vc;
    }
    
    return nil;
}

-(UIViewController*) topVisibleViewController:(UISplitViewController *)splitVC
{
    UIViewController *vc = [splitVC.viewControllers lastObject];
    
    if (![vc isKindOfClass:[UINavigationController class]]) return nil;
    
    UINavigationController *detailNC = (UINavigationController *) vc;
    
    return [detailNC visibleViewController];    
}

@end
