//
//  UIButton+BackgroundColor.m
//  Carat
//
//  Created by Jarno Petteri Laitinen on 23/10/15.
//  Copyright © 2015 University of Helsinki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIButton+BackgroundColor.h"

@implementation UIButton(BackgroundColor)

- (void)setBackgroundColor:(UIColor *)color forState:(UIControlState)state
{
    [self setBackgroundImage:[self imageWithColor:color] forState:state];
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end