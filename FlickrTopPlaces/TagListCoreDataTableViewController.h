//
//  TagListCoreDataTableViewController.h
//  FlickrTopPlaces
//
//  Created by Hossam Hammady on 3/11/12.
//  Copyright (c) 2012 Texas A&M University at Qatar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"

@interface TagListCoreDataTableViewController : CoreDataTableViewController
@property (nonatomic, strong) UIManagedDocument *document;
@end
