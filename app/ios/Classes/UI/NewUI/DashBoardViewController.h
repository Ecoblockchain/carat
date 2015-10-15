//
//  DashBoardViewController.h
//  Carat
//
//  Created by Jarno Petteri Laitinen on 29/09/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import "BaseViewController.h"
#import "ScoreView.h"
#import "DashboardNavigationButton.h"

#import "TutorialViewController.h"
#import "BugsViewController.h"
#import "HogsViewController.h"
#import "StatisticsViewController.h"
#import "ActionsViewController.h"
#import "MyScoreViewController.h"
#import "MoreViewController.h"
#import <Socialize/Socialize.h>
#import "CoreDataManager.h"


@interface DashBoardViewController : BaseViewController
@property (retain, nonatomic) IBOutlet ScoreView *scoreView;
@property (retain, nonatomic) IBOutlet UILabel *updateLabel;
@property (retain, nonatomic) IBOutlet UIButton *shareBtn;
@property (retain, nonatomic) IBOutlet UIView *shareBar;
@property (retain, nonatomic) IBOutlet LocalizedLabel *batteryLastLabel;
@property (retain, nonatomic) IBOutlet DashboardNavigationButton *bugsBtn;
@property (retain, nonatomic) IBOutlet DashboardNavigationButton *hogsBtn;
@property (retain, nonatomic) IBOutlet DashboardNavigationButton *statisticsBtn;
@property (retain, nonatomic) IBOutlet DashboardNavigationButton *actionsBtn;


- (IBAction)showFacebook:(id)sender;
- (IBAction)showTwitter:(id)sender;
- (IBAction)showShareBar:(id)sender;
- (IBAction)showEmail:(id)sender;
- (IBAction)closeShareBar:(id)sender;
- (IBAction)shareButtonTapped:(id)sender;
- (IBAction)showScoreInfo:(id)sender;
- (IBAction)showMyDevice:(id)sender;
- (IBAction)showBugs:(id)sender;
- (IBAction)showHogs:(id)sender;
- (IBAction)showStatistics:(id)sender;
- (IBAction)showActions:(id)sender;


@end
