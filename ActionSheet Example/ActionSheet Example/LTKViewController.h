//
//  LTKViewController.h
//  ActionSheet Example
//
//  Created by Adam on 9/30/12.
//  Copyright (c) 2012 Logical Thought. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LTKPopoverActionSheetDelegate.h"

@interface LTKViewController : UIViewController <LTKPopoverActionSheetDelegate>

@property (nonatomic, strong) IBOutlet UINavigationItem *customNavigationItem;

- (IBAction) buttonAction:(id)sender;

@end
