//
//  ImageViewController.h
//  FlickrTopPlaces
//
//  Created by Hossam Hammady on 2/22/12.
//  Copyright (c) 2012 Texas A&M University at Qatar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VacationsTableViewController.h"

@interface FlickrImageViewController : UIViewController <VacationsTableViewControllerModalDelegate>
-(void) reloadImageWithInfo:(NSDictionary*) info;
@property (nonatomic, strong) NSManagedObjectContext* documentContext;
@end
