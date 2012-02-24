//
//  ImageListTableViewController.h
//  FlickrTopPlaces
//
//  Created by Hossam Hammady on 2/24/12.
//  Copyright (c) 2012 Texas A&M University at Qatar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageListTableViewController : UITableViewController
@property (nonatomic, strong) NSArray* imageList;
@property (nonatomic) BOOL reversedList;
@end
