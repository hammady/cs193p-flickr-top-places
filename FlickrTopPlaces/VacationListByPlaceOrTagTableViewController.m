//
//  VacationListByPlaceOrTagTableViewController.m
//  FlickrTopPlaces
//
//  Created by Hossam Hammady on 3/11/12.
//  Copyright (c) 2012 Texas A&M University at Qatar. All rights reserved.
//

#import "VacationListByPlaceOrTagTableViewController.h"
#import "Vacations.h"

@interface VacationListByPlaceOrTagTableViewController()
@property (nonatomic, strong) UIManagedDocument* document;
@end

@implementation VacationListByPlaceOrTagTableViewController

@synthesize vacation = _vacation;
@synthesize document = _document;

#pragma mark - setters/getters

-(void) setVacation:(NSString *)vacation
{
    self.navigationItem.title = vacation;
    [Vacations documentForVacationWithName:vacation usingBlock:^(UIManagedDocument *document) {
        self.document = document;
    }];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Itinerary or tags";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.row == 0)
        cell.textLabel.text = @"Itinerary";
    else
        cell.textLabel.text = @"Tag Search";
    
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // static table views can't auto segue from the storyboard!
    if (indexPath.row == 0)
        [self performSegueWithIdentifier:@"view itinerary" sender:self];
    else
        [self performSegueWithIdentifier:@"view tags" sender:self];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id vc = segue.destinationViewController;
    if ([vc respondsToSelector:@selector(setDocument:)]) {
        [vc setDocument:self.document];
    }
}

@end
