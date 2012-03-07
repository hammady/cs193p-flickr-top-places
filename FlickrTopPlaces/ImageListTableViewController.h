//
//  ImageListTableViewController.h
//  FlickrTopPlaces
//
//  Created by Hossam Hammady on 2/24/12.
//  Copyright (c) 2012 Texas A&M University at Qatar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SplitViewControllerAwareTableViewController.h"

@class ImageListTableViewController;

/*@protocol ImageListTableViewControllerDelegate <NSObject>
@optional
-(void) imageListTVCNewPhotosAvailable:(NSArray*) photos 
                    withMapAnnotations:(NSArray*) annotations
                                sender:(ImageListTableViewController*) sender;
@end
*/

@interface ImageListTableViewController : SplitViewControllerAwareTableViewController
@property (nonatomic, strong) NSArray* imageList;
@property (nonatomic) BOOL reversedList;
@property (nonatomic, readonly) NSArray* mapAnnotations;
//@property (nonatomic, weak) id <ImageListTableViewControllerDelegate> delegate;
@end
