//
//  CoreDataImageListTableViewController.h
//  FlickrTopPlaces
//
//  Created by Hossam Hammady on 3/12/12.
//  Copyright (c) 2012 Texas A&M University at Qatar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageListTableViewController.h"
#import <CoreData/CoreData.h>

@interface CoreDataImageListTableViewController : ImageListTableViewController
@property (nonatomic, strong) NSString* title;
-(void) setRequest:(NSFetchRequest *)request inManagedObjectContext:(NSManagedObjectContext*) context;
@end
