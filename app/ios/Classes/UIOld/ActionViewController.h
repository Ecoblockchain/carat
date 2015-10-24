//
//  ActionViewController.h
//  Carat
//
//  Created by Adam Oliner on 2/7/12.
//  Copyright (c) 2012 UC Berkeley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"


@interface ActionViewController : UIViewController <MBProgressHUDDelegate> {
    
    NSMutableArray *actionList;
    MBProgressHUD *HUD;
    
    IBOutlet UITableView *actionTable;
}

@property (retain, nonatomic) NSMutableArray *actionList;

@property (retain, nonatomic) IBOutlet UITableView *actionTable;

//- (void)shareHandler;
- (void)updateView;
- (void)loadDataWithHUD;
- (void)loadDataWithHUD:(id)obj;
- (BOOL)isFresh;

@end
