//
//  VacationsTableViewController.m
//  FlickrTopPlaces
//
//  Created by Hossam Hammady on 3/11/12.
//  Copyright (c) 2012 Texas A&M University at Qatar. All rights reserved.
//

#import "VacationsTableViewController.h"
#import "Vacations.h"
#import "VacationListByPlaceOrTagTableViewController.h"
#import "VacationNameInputViewController.h"

@interface VacationsTableViewController() <VacationNameInputViewControllerDelegate>
@property (nonatomic, strong) NSArray* vacations;
@end

@implementation VacationsTableViewController
@synthesize vacations = _vacations;
@synthesize delegate = _delegate;

#pragma mark - setters/getters

-(NSArray*) vacations
{
    if (!_vacations) {
        _vacations = [Vacations listVacations];
    }
    return _vacations;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // read vacations from file system
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.vacations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Vacation Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSString* vacation = [self.vacations objectAtIndex:indexPath.row];
    
    cell.textLabel.text = vacation;
    
    return cell;
}

#pragma mark - actions

- (IBAction)addVacation:(id)sender {
    [self performSegueWithIdentifier:@"Input vacation name" sender:self];
}

- (IBAction)cancelPressed:(id)sender
{
    [[self presentingViewController] dismissModalViewControllerAnimated:YES];
}

-(NSString*) selectedVacation
{
    NSInteger selectedRow = [[self.tableView indexPathForSelectedRow] row];
    return [self.vacations objectAtIndex:selectedRow];    
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"View vacation details"]) {
        [segue.destinationViewController setVacation:[self selectedVacation]];
    } else if ([segue.identifier isEqualToString:@"Input vacation name"]) {
        VacationNameInputViewController* vc = (VacationNameInputViewController*) segue.destinationViewController;
        vc.delegate = self;
        vc.name = [@"My Vacation" stringByAppendingFormat:@" %d", (self.vacations.count + 1)];
    }
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.presentingViewController) {
        [Vacations documentForVacationWithName:[self selectedVacation] usingBlock:^(UIManagedDocument *document) {
            [self.delegate vacationsTVCSelectedVacationDocument:document];
        }];
    }
}

#pragma mark - VacationNameInputViewControllerDelegate methods

-(void) vacationNameInput:(VacationNameInputViewController *)sender didEnterName:(NSString *)name
{
    [Vacations addVacationWithName:name usingBlock:^(UIManagedDocument *document) {
        [document closeWithCompletionHandler:^(BOOL success) {
            [self dismissModalViewControllerAnimated:YES];
            self.vacations = [Vacations listVacations];
            [self.tableView reloadData];
        }];
    }];
}

@end
