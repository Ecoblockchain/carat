//
//  HideAppsViewController.h
//  Carat
//
//  Created by Jarno Petteri Laitinen on 12/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Globals.h"
#import "BaseViewController.h"

@interface HideAppsViewController : BaseViewController <UIPickerViewDelegate, UIPickerViewDataSource>
@property (strong, nonatomic) NSArray *hideChoises;
@property (retain, nonatomic) IBOutlet UIPickerView *pickerView;
- (IBAction)selectClicked:(id)sender;

@end
