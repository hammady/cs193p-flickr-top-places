//
//  VacationNameInput.m
//  FlickrTopPlaces
//
//  Created by Hossam Hammady on 3/18/12.
//  Copyright (c) 2012 Texas A&M University at Qatar. All rights reserved.
//

#import "VacationNameInputViewController.h"

@interface VacationNameInputViewController() <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textField;
@end

@implementation VacationNameInputViewController
@synthesize textField = _textField;
@synthesize name = _name;
@synthesize delegate = _delegate;

#pragma mark - View lifecycle

-(void) setName:(NSString *)name
{
    _name = name;
    self.textField.text = name;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.textField.delegate = self;
    self.textField.text = self.name;
}

- (void)viewDidUnload
{
    [self setTextField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.textField becomeFirstResponder];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

#pragma mark - UITextFieldDelegate methods

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if (textField.text.length > 0) {
        [textField resignFirstResponder];
        return YES;
    }
    return NO;
}

-(void) textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.text.length > 0) {
        [self.delegate vacationNameInput:self didEnterName:textField.text];
    }
}

@end
