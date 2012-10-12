//
//  LTKPopoverBackgroundView.h
//  ActionSheet Example
//
//  Created by Adam on 10/7/12.
//  Copyright (c) 2012 Logical Thought. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIPopoverBackgroundView.h>

@interface LTKPopoverBackgroundView : UIPopoverBackgroundView

@property (nonatomic, readwrite) CGFloat arrowOffset;
@property (nonatomic, readwrite) UIPopoverArrowDirection arrowDirection;

@end
