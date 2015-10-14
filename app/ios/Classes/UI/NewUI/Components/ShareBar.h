//
//  ShareBar.h
//  Carat
//
//  Created by Jarno Petteri Laitinen on 01/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppColors.h"
#import "AppLayout.h"

@class ShareBar;
@interface ShareBar : UIView {
}
@property (nonatomic, assign) id  delegate;

-(void)setDelegate:(id)delegate;
-(void)closeTapped;
-(void)emailTapped;
-(void)twitterTapped;
-(void)facebookTapped;
@end

@protocol ShareBarDelegate
- (void)faceBookPressed;
- (void)twitterPressed;
- (void)emailPressed;
- (void)closePressed;
@end
