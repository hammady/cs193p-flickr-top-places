//
//  VacationsTableViewController.h
//  FlickrTopPlaces
//
//  Created by Hossam Hammady on 3/11/12.
//  Copyright (c) 2012 Texas A&M University at Qatar. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VacationsTableViewControllerModalDelegate
-(void) vacationsTVCSelectedVacationDocument:(UIManagedDocument*) document;
@end

@interface VacationsTableViewController : UITableViewController
@property (nonatomic, weak) id <VacationsTableViewControllerModalDelegate> delegate;
@end
