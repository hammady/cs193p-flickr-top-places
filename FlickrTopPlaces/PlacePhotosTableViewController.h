//
//  FlickrImageListViewController.h
//  FlickrTopPlaces
//
//  Created by Hossam Hammady on 2/22/12.
//  Copyright (c) 2012 Texas A&M University at Qatar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageListTableViewController.h"

@interface PlacePhotosTableViewController : ImageListTableViewController
@property (nonatomic, strong) NSDictionary* place;
@end
