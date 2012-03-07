//
//  SplitViewControllerAwareViewController.h
//  FlickrTopPlaces
//
//  Created by Hossam Hammady on 3/5/12.
//  Copyright (c) 2012 Texas A&M University at Qatar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlickrMapViewController.h"

@interface SplitViewControllerAwareTableViewController : UITableViewController

-(FlickrMapViewController*) mapViewControllerForSplitViewController:(UISplitViewController*) splitVC;

-(UIViewController*) topVisibleViewController:(UISplitViewController*) splitVC;

@end
