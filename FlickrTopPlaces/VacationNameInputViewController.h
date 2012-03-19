//
//  VacationNameInput.h
//  FlickrTopPlaces
//
//  Created by Hossam Hammady on 3/18/12.
//  Copyright (c) 2012 Texas A&M University at Qatar. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VacationNameInputViewController;

@protocol VacationNameInputViewControllerDelegate <NSObject>
-(void) vacationNameInput:(VacationNameInputViewController*) sender
             didEnterName:(NSString*) name;
@end

@interface VacationNameInputViewController : UIViewController
@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) id <VacationNameInputViewControllerDelegate> delegate;
@end
