//
//  ActionViewController.m
//  Carat
//
//  Created by Adam Oliner on 2/7/12.
//  Copyright (c) 2012 UC Berkeley. All rights reserved.
//

#import "ActionViewController.h"
#import "Utilities.h"
#import "ActionItemCell.h"
#import "UIImageDoNotCache.h"
#import "InstructionViewController.h"
#import "Flurry.h"
#import "ActionObject.h"
#import "CoreDataManager.h"
#import "SVPullToRefresh.h"
#import "Socialize/Socialize.h"
#import "CaratConstants.h"
#import "UIDeviceHardware.h"

@implementation ActionViewController

@synthesize actionList, actionTable;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Actions";
        self.tabBarItem.image = [UIImage imageNamed:@"53-house"];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    DLog(@"Memory warning.");
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

#pragma mark - Data management

- (void)loadDataWithHUD:(id)obj {
    [self loadDataWithHUD];
}

- (void)loadDataWithHUD
{
    if ([[CoreDataManager instance] getReportUpdateStatus] != nil) {
        // update in progress, only update footer
        [self.actionTable reloadData];
        [self.view setNeedsDisplay];
    } else {
        // *probably* no update in progress, reload table data while locking out view
        [self.actionTable.pullToRefreshView stopAnimating];
        HUD = [[MBProgressHUD alloc] initWithView:self.tabBarController.view];
        [self.tabBarController.view addSubview:HUD];
        
        HUD.dimBackground = YES;
        
        // Register for HUD callbacks so we can remove it from the window at the right time
        HUD.delegate = self;
        HUD.labelText = @"Updating Action List";
        
        [HUD showWhileExecuting:@selector(loadData)
                       onTarget:self
                     withObject:nil
                       animated:YES];
    }
}

- (void)viewWillLayoutSubviews{

	[super viewWillLayoutSubviews];
}

- (void)loadData
{    
    [self updateView];
}

- (BOOL) isFresh
{
    return [[CoreDataManager instance] secondsSinceLastUpdate] < 600; // 600 == 10 minutes
}

#pragma mark - MBProgressHUDDelegate method

- (void)hudWasHidden:(MBProgressHUD *)hud
{
    // Remove HUD from screen when the HUD was hidded
    [HUD removeFromSuperview];
    [HUD release];
	HUD = nil;
}


#pragma mark - table methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [actionList count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"To improve battery life...";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ActionItemCell";
    
    ActionItemCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ActionItemCell" owner:nil options:nil];
        for (id currentObject in topLevelObjects) {
            if ([currentObject isKindOfClass:[ActionItemCell class]]) {
                cell = (ActionItemCell *)currentObject;
                break;
            }
        }
    }
    
    // Set up the cell...
    ActionObject *act = [self.actionList objectAtIndex:indexPath.row];
    cell.actionString.text = act.actionText;
	if (act.actionBenefit == -1) {
		cell.actionValue.text = @"better Carat results!";
		cell.actionType = ActionTypeCollectData;
	} else if (act.actionBenefit == -2) { // already filtered out benefits < 60 seconds
        cell.actionValue.text = @"+100 karma!";
        cell.actionType = ActionTypeSpreadTheWord;
    } else if (act.actionBenefit == -3) {
        cell.actionValue.text = @"See top Hogs and devices";
        cell.actionType = ActionTypeGlobalStats;
        //cell.actionHeader.text = @"";
    }
	else {
        cell.actionValue.text = [NSString stringWithFormat:@"%@ ± %@", [Utilities doubleAsTimeNSString:act.actionBenefit], [Utilities doubleAsTimeNSString:act.actionError]];
        cell.actionType = act.actionType;
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    NSString *tmpStatus = [[CoreDataManager instance] getReportUpdateStatus];
    if (tmpStatus == nil) {
        return [Utilities formatNSTimeIntervalAsUpdatedNSString:[[NSDate date] timeIntervalSinceDate:[[CoreDataManager instance] getLastReportUpdateTimestamp]]];
    } else {
        return tmpStatus;
    }
}

// loads the selected detail view
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ActionItemCell *selectedCell = (ActionItemCell *)[tableView cellForRowAtIndexPath:indexPath];
    [selectedCell setSelected:NO animated:YES];
    
    /*if (selectedCell.actionType == ActionTypeSpreadTheWord) {
        [self shareHandler];
    } else*/
        InstructionViewController *ivController = [[InstructionViewController alloc] initWithNibName:@"InstructionView" actionType:selectedCell.actionType];
        [self.navigationController pushViewController:ivController animated:YES];
        [ivController release];
        [Flurry logEvent:@"selectedInstructionView"];
    //}
}

- (void) updateNetworkStatus:(NSNotification *) notice
{
    DLog(@"%s", __PRETTY_FUNCTION__);
	NSDictionary *dict = [notice userInfo];
	BOOL isInternetActive = [dict[kIsInternetActive] boolValue];

	if (isInternetActive || [[CommunicationManager instance] isInternetReachable]) {
		DLog(@"Checking if update needed with new reachability status...");
		if (![self isFresh] && // need to update
			[[CoreDataManager instance] getReportUpdateStatus] == nil) // not already updating
		{
			DLog(@"Update possible; initiating.");
			[[CoreDataManager instance] updateLocalReportsFromServer];
		}
	}
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.actionTable addPullToRefreshWithActionHandler:^{
        if ([[CommunicationManager instance] isInternetReachable] == YES && // online
            [[CoreDataManager instance] getReportUpdateStatus] == nil) // not already updating
        {
            [[CoreDataManager instance] updateLocalReportsFromServer];
            [self updateView];
        }
    }];
    
    [self updateView];
}

- (void)viewDidUnload
{
    [HUD release];
    [actionList release];
    [self setActionList:nil];
    [actionTable release];
    [self setActionTable:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
	[self.navigationController setNavigationBarHidden:YES animated:YES];
	CGRect tableViewFrame = self.actionTable.frame;
	self.actionTable.frame = CGRectMake(0, 0, tableViewFrame.size.width, tableViewFrame.size.height);

	[super viewWillAppear:animated];

    if ([[CoreDataManager instance] getReportUpdateStatus] == nil) {
        [self.actionTable.pullToRefreshView stopAnimating];
    } else {
        [self.actionTable.pullToRefreshView startAnimating];
    }
    
    // UPDATE REPORT DATA
    if ([[CommunicationManager instance] isInternetReachable] == YES && // online
        ![self isFresh] && // need to update
        [[CoreDataManager instance] getReportUpdateStatus] == nil) // not already updating
    {
        [[CoreDataManager instance] updateLocalReportsFromServer];
    } else if ([[CommunicationManager instance] isInternetReachable] == NO) {
        DLog(@"Starting without reachability; setting notification.");
    }

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNetworkStatus:) name:kUpdateNetworkStatusNotification object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sampleCountUpdated:) name:kSamplesSentCountUpdateNotification object:nil];
	
	[self updateNetworkStatus:nil];
}

-(void)sampleCountUpdated:(NSNotification*)notification{
	[[CoreDataManager instance] getSampleSent];
	[self.actionTable reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([[CoreDataManager instance] getReportUpdateStatus] == nil) {
        // For this screen, let's put sending samples/registrations here so that we don't conflict
        // with the report syncing (need to limit memory/CPU/thread usage so that we don't get killed).
        [[CoreDataManager instance] checkConnectivityAndSendStoredDataToServer];
    }
    
    [self loadDataWithHUD];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadDataWithHUD:) 
                                                 name:@"CCDMReportUpdateStatusNotification"
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                            name:@"CCDMReportUpdateStatusNotification" object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
    return YES;
}

- (void)updateView {
    NSMutableArray *myList = [[[NSMutableArray alloc] init] autorelease];
    
    ActionObject *tmpAction;
    
    DLog(@"Loading Hogs");
    // get Hogs, filter negative actionBenefits, fill mutable array
    NSArray *tmp = [[CoreDataManager instance] getHogs:YES withoutHidden:YES].hbList;
    if (tmp != nil) {
        for (HogsBugs *hb in tmp) {
            if ([hb appName] != nil &&
                [hb expectedValue] > 0 &&
                [hb expectedValueWithout] > 0 &&
                [hb error] > 0 &&
                [hb errorWithout] > 0) {
                
                NSInteger benefit = (int) (100/[hb expectedValueWithout] - 100/[hb expectedValue]);
                NSInteger benefit_max = (int) (100/([hb expectedValueWithout]-[hb errorWithout]) - 100/([hb expectedValue]+[hb error]));
                NSInteger error = (int) (benefit_max-benefit);
                DLog(@"Benefit is %d ± %d for hog '%@'", benefit, error, [hb appName]);
                if (benefit > 60) { // TODO need positive gap, also check for below
                    tmpAction = [[ActionObject alloc] init];
                    [tmpAction setActionText:[@"Kill " stringByAppendingString:[hb appName]]];
                    [tmpAction setActionType:ActionTypeKillApp];
                    [tmpAction setActionBenefit:benefit];
                    [tmpAction setActionError:error];
                    [myList addObject:tmpAction];
                    [tmpAction release];
                }
            }
        }
    }
    
    DLog(@"Loading Bugs");
    // get Bugs, add to array
    tmp = [[CoreDataManager instance] getBugs:YES withoutHidden:YES].hbList;
    if (tmp != nil) {
        for (HogsBugs *hb in tmp) {
            if ([hb appName] != nil &&
                [hb expectedValue] > 0 &&
                [hb expectedValueWithout] > 0 &&
                [hb error] > 0 &&
                [hb errorWithout] > 0) {
                
                NSInteger benefit = (int) (100/[hb expectedValueWithout] - 100/[hb expectedValue]);
                NSInteger benefit_max = (int) (100/([hb expectedValueWithout]-[hb errorWithout]) - 100/([hb expectedValue]+[hb error]));
                NSInteger error = (int) (benefit_max-benefit);
                DLog(@"Benefit is %d ± %d for bug '%@'", benefit, error, [hb appName]);
                if (benefit > 60) {
                    tmpAction = [[ActionObject alloc] init];
                    [tmpAction setActionText:[@"Restart " stringByAppendingString:[hb appName]]];
                    [tmpAction setActionType:ActionTypeRestartApp];
                    [tmpAction setActionBenefit:benefit];
                    [tmpAction setActionError:error];
                    [myList addObject:tmpAction];
                    [tmpAction release];
                }
            }
        }
    }
    
    DLog(@"Loading OS");
    // get OS
    DetailScreenReport *dscWith = [[[CoreDataManager instance] getOSInfo:YES] retain];
    DetailScreenReport *dscWithout = [[[CoreDataManager instance] getOSInfo:NO] retain];
    
    BOOL canUpgradeOS = [Utilities canUpgradeOS];
    
    if (dscWith != nil && dscWithout != nil) {
        if (dscWith.expectedValue > 0 &&
            dscWithout.expectedValue > 0 &&
            dscWith.error > 0 &&
            dscWithout.error > 0 &&
            canUpgradeOS) {
            NSInteger benefit = (int) (100/dscWithout.expectedValue - 100/dscWith.expectedValue);
            NSInteger benefit_max = (int) (100/(dscWithout.expectedValue - dscWithout.error) - 100/(dscWith.expectedValue + dscWith.error));
            NSInteger error = (int) (benefit_max-benefit);
            DLog(@"OS benefit is %d ± %d", benefit, error);
            if (benefit > 60) {
                tmpAction = [[ActionObject alloc] init];
                [tmpAction setActionText:@"Upgrade the Operating System"];
                [tmpAction setActionType:ActionTypeUpgradeOS];
                [tmpAction setActionBenefit:benefit];
                [tmpAction setActionError:error];
                [myList addObject:tmpAction];
                [tmpAction release];
            }
        }
    }
    
    [dscWith release];
    [dscWithout release];

    DLog(@"Loading Actions");
    
    // data collection action
    if ([myList count] == 0) {
        tmpAction = [[ActionObject alloc] init];
        [tmpAction setActionText:@"Help Carat Collect Data"];
        [tmpAction setActionType:ActionTypeCollectData];
        [tmpAction setActionBenefit:-1];
        [tmpAction setActionError:-1];
        [myList addObject:tmpAction];
        [tmpAction release];
    }
        
    // sharing Action
    /*tmpAction = [[ActionObject alloc] init];
    [tmpAction setActionText:@"Help Spread the Word"];
    [tmpAction setActionType:ActionTypeSpreadTheWord];
    [tmpAction setActionBenefit:-2];
    [tmpAction setActionError:-2];
    [myList addObject:tmpAction];
    [tmpAction release];
*/
    //the "key" is the *name* of the @property as a string.  So you can also sort by @"label" if you'd like
    [myList sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"actionBenefit" ascending:NO]]];
    
    [self setActionList:myList];
    [self.actionTable reloadData];
    [self.view setNeedsDisplay];
}

- (void)dealloc {
    [HUD release];
    [actionList release];
    [actionTable release];
   // [internetReachable release];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}
@end






