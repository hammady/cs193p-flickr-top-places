//
//  FlickrImageListViewController.h
//  FlickrTopPlaces
//
//  Created by Hossam Hammady on 2/22/12.
//  Copyright (c) 2012 Texas A&M University at Qatar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlickrImageListViewController : UITableViewController
-(void) reloadImagesForPlace:(NSDictionary*) place;
@end
