//
//  ProcessListViewController.m
//  Carat
//
//  Created by Adam Oliner on 2/16/12.
//  Copyright (c) 2012 UC Berkeley. All rights reserved.
//

#import "ProcessListViewController.h"
#import "ProcessItemCell.h"
#import "UIDeviceHardware.h"
#import "UIImageDoNotCache.h"
#import "Utilities.h"

@implementation ProcessListViewController

@synthesize lastUpdate;
@synthesize processList;
@synthesize procTable;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    DLog(@"Memory warning.");
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

#pragma mark - table methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.processList != nil) {
        return [self.processList count];
    } else return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Process List";
}

- (void) viewDidLayoutSubviews {
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
        if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
            self.edgesForExtendedLayout = UIRectEdgeNone;   // iOS 7 specific
        CGRect viewBounds = self.view.bounds;
        CGFloat topBarOffset = self.topLayoutGuide.length;
        viewBounds.origin.y = topBarOffset * -1;
        self.view.bounds = viewBounds;
        self.navigationController.navigationBar.translucent = NO;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat sectionHeaderHeight = 20;
    if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"ProcessItemCell";
    
    ProcessItemCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ProcessItemCell" owner:nil options:nil];
        for (id currentObject in topLevelObjects) {
            if ([currentObject isKindOfClass:[ProcessItemCell class]]) {
                cell = (ProcessItemCell *)currentObject;
                break;
            }
        }
    }
    
    NSDictionary *selectedProc = [self.processList objectAtIndex:indexPath.row];

    // Set up the cell...
    NSString *appName = [selectedProc objectForKey:@"ProcessName"];
    cell.appName.text = appName;
    
    UIImage *img = [UIImage newImageNotCached:[appName stringByAppendingString:@".png"]];
    if (img == nil) {
        img = [UIImage newImageNotCached:@"icon57.png"];
    }
    cell.appIcon.image = img;
    [img release];
    
    cell.procID.text = [selectedProc objectForKey:@"ProcessID"];    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    NSTimeInterval howLong = [[NSDate date] timeIntervalSinceDate:self.lastUpdate];
    return [Utilities formatNSTimeIntervalAsUpdatedNSString:howLong];
}

// loads the selected detail view
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self updateView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)updateView
{
    self.processList = [[UIDevice currentDevice] runningProcesses];
    self.lastUpdate = [NSDate date];
    // TODO filter (based on "Filter Daemons" button)
    [self.procTable reloadData];
    [self.view setNeedsDisplay];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

@end
