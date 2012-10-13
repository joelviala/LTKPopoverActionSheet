//
//  LTKViewController.m
//  ActionSheet Example
//
//  Created by Adam on 9/30/12.
//  Copyright (c) 2012 Logical Thought. All rights reserved.
//

#import "LTKViewController.h"
#import "LTKPopoverActionSheet.h"
#import "LTKPopoverBackgroundView.h"

@interface NormalActionSheetDelegate : NSObject <UIActionSheetDelegate>
@end

@interface LTKViewController ()

@property (nonatomic, strong) LTKPopoverActionSheet *activePopoverActionSheet;
@property (nonatomic, strong) UIActionSheet *normalActionSheet;
@property (nonatomic, strong) NormalActionSheetDelegate *normalActionSheetDelegate;
@property (nonatomic) BOOL shouldButtonPopoverUseCustomStyle;

- (void) showDefaultActionSheetWithNoTitleFromBarButtonItem:(UIBarButtonItem *)sender;
- (void) showDefaultActionSheetWithTitleFromBarButtonItem:(UIBarButtonItem *)sender;
- (void) showUIKitActionSheetFromBarButtonItem:(UIBarButtonItem *)sender;
- (void) dismissActionSheets;

@end

@implementation LTKViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *defaultNoTitleItem = [[UIBarButtonItem alloc] initWithTitle:@"No Title"
                                                                          style:UIBarButtonItemStyleBordered
                                                                         target:self
                                                                         action:@selector(showDefaultActionSheetWithNoTitleFromBarButtonItem:)];
    UIBarButtonItem *defaultWithTitleItem = [[UIBarButtonItem alloc] initWithTitle:@"With Title"
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:self
                                                                            action:@selector(showDefaultActionSheetWithTitleFromBarButtonItem:)];
    UIBarButtonItem *defaultUIKitItem = [[UIBarButtonItem alloc] initWithTitle:@"UIKit Action Sheet"
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:self
                                                                            action:@selector(showUIKitActionSheetFromBarButtonItem:)];
    self.customNavigationItem.leftBarButtonItems = @[defaultNoTitleItem, defaultWithTitleItem];
    self.customNavigationItem.rightBarButtonItem = defaultUIKitItem;
    
    self.activePopoverActionSheet = nil;
    
    [[LTKPopoverActionSheet appearance] setPopoverBackgroundViewClassName:@"LTKPopoverBackgroundView"];
    [[LTKPopoverActionSheet appearance] setSheetWidth:250.0f];
    [[LTKPopoverActionSheet appearance] setTitleColor:[UIColor whiteColor]];
    [[LTKPopoverActionSheet appearance] setTitleFont:[UIFont fontWithName:@"Verdana-Bold" size:14.0f]];
    [[LTKPopoverActionSheet appearance] setButtonSize:CGSizeMake(244.0f, 46.0f)];
    [[LTKPopoverActionSheet appearance] setButtonFont:[UIFont fontWithName:@"Futura-Medium" size:19.0f]];
    [[LTKPopoverActionSheet appearance] setButtonTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [[LTKPopoverActionSheet appearance] setButtonTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [[LTKPopoverActionSheet appearance] setButtonBackgroundImage:[[UIImage imageNamed:@"normal-button"]
                                                                  resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 8.0f, 0.0f, 8.0f)]
                                                        forState:UIControlStateNormal];
    [[LTKPopoverActionSheet appearance] setButtonBackgroundImage:[[UIImage imageNamed:@"normal-button-pressed"]
                                                                  resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 8.0f, 0.0f, 8.0f)]
                                                        forState:UIControlStateHighlighted];
    [[LTKPopoverActionSheet appearance] setDestructiveButtonTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [[LTKPopoverActionSheet appearance] setDestructiveButtonTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [[LTKPopoverActionSheet appearance] setDestructiveButtonBackgroundImage:[[UIImage imageNamed:@"destructive-button"]
                                                                             resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 8.0f, 0.0f, 8.0f)]
                                                                   forState:UIControlStateNormal];
    [[LTKPopoverActionSheet appearance] setDestructiveButtonBackgroundImage:[[UIImage imageNamed:@"destructive-button-pressed"]
                                                                             resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 8.0f, 0.0f, 8.0f)]
                                                                   forState:UIControlStateHighlighted];
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - private methods showing LTKPopoverActionSheet examples

- (void) showDefaultActionSheetWithNoTitleFromBarButtonItem:(UIBarButtonItem *)sender
{
    [self dismissActionSheets];
    
    LTKPopoverActionSheet *popoverActionSheet = [[LTKPopoverActionSheet alloc] init];
    
    [popoverActionSheet addButtonWithTitle:@"First Thing" block:^()
     {
         UIAlertView* messageAlert = [[UIAlertView alloc] initWithTitle:nil message:@"First Thing" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
         [messageAlert show];
     }];
    
    [popoverActionSheet addButtonWithTitle:@"Second Thing" block:^()
     {
         UIAlertView* messageAlert = [[UIAlertView alloc] initWithTitle:nil message:@"Second Thing" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
         [messageAlert show];
     }];
    
    [popoverActionSheet addDestructiveButtonWithTitle:@"Destructive Thing" block:^()
     {
         UIAlertView* messageAlert = [[UIAlertView alloc] initWithTitle:nil message:@"Destructive Thing" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
         [messageAlert show];
     }];
    
    [popoverActionSheet showFromBarButtonItem:sender animated:YES];
    
    self.activePopoverActionSheet = popoverActionSheet;
}

- (void) showDefaultActionSheetWithTitleFromBarButtonItem:(UIBarButtonItem *)sender
{
    [self dismissActionSheets];
    
    LTKPopoverActionSheet *popoverActionSheet = [[LTKPopoverActionSheet alloc] initWithTitle:@"Action Sheet Title"
                                                                                    delegate:self
                                                                      destructiveButtonTitle:@"Destruct Button"
                                                                           otherButtonTitles:@"Item 1", @"Item 2", nil];
    
    [popoverActionSheet showFromBarButtonItem:sender animated:YES];
    
    self.activePopoverActionSheet = popoverActionSheet;
    
}

- (void) showUIKitActionSheetFromBarButtonItem:(UIBarButtonItem *)sender
{
    [self dismissActionSheets];
    
    if (nil == self.normalActionSheetDelegate)
    {
        self.normalActionSheetDelegate = [[NormalActionSheetDelegate alloc] init];
    }
    
    if (nil == self.normalActionSheet)
    {
        UIActionSheet *normalActionSheet = [[UIActionSheet alloc] initWithTitle:@"This is a normal UIActionSheet" delegate:self.normalActionSheetDelegate cancelButtonTitle:nil destructiveButtonTitle:@"Destructive Button" otherButtonTitles:@"Button 1", @"Button 2", @"Button 3", nil];
        
        self.normalActionSheet = normalActionSheet;
    }
    
    [self.normalActionSheet showFromBarButtonItem:sender animated:YES];
}

- (void) dismissActionSheets
{
    if (self.activePopoverActionSheet)
    {
        if ([self.activePopoverActionSheet isVisible])
        {
            [self.activePopoverActionSheet dismissPopoverAnimated:YES];
        }
        
        self.activePopoverActionSheet = nil;
    }
    
    if (self.normalActionSheet)
    {
        if ([self.normalActionSheet isVisible])
        {
            [self.normalActionSheet dismissWithClickedButtonIndex:-1 animated:YES];
        }
        
        self.normalActionSheet = nil;
    }
}

- (IBAction) buttonAction:(id)sender
{
    [self dismissActionSheets];
    
    __block NSString *styleName = (self.shouldButtonPopoverUseCustomStyle) ? @"Custom" : @"Default";
    __block LTKViewController *blockSelf = self;
    
    LTKPopoverActionSheet *popoverActionSheet = [[LTKPopoverActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"This uses the %@ style. Want to switch?", [styleName lowercaseString]]];
    
    if (!self.shouldButtonPopoverUseCustomStyle)
    {
        [popoverActionSheet useDefaultStyle];
    }
    
    [popoverActionSheet addDestructiveButtonWithTitle:@"Change Style" block:^()
     {
         NSString *newStyle = @"";
         
         if (blockSelf.shouldButtonPopoverUseCustomStyle)
         {
             blockSelf.shouldButtonPopoverUseCustomStyle = NO;
             newStyle = @"Default";
         }
         else
         {
             blockSelf.shouldButtonPopoverUseCustomStyle = YES;
             newStyle = @"Custom";
         }
         
         UIAlertView* messageAlert = [[UIAlertView alloc] initWithTitle:nil
                                                                message:[NSString stringWithFormat:@"Changing style from '%@' to '%@'", styleName, newStyle]
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
         [messageAlert show];
     }];
    
    [popoverActionSheet addButtonWithTitle:@"Don't Change" block:^()
     {
         UIAlertView* messageAlert = [[UIAlertView alloc] initWithTitle:nil
                                                                message:[NSString stringWithFormat:@"Leaving the style as '%@'", styleName]
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
         [messageAlert show];
     }];
    
    UIButton *button = (UIButton *)sender;
    [popoverActionSheet showFromRect:button.frame inView:self.view animated:YES];
    
    self.activePopoverActionSheet = popoverActionSheet;
}

#pragma mark - LTKPopoverActionSheetDelegate

- (void) actionSheet:(LTKPopoverActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *alertText = [NSString stringWithFormat:@"Pressed Button: '%@'", [actionSheet buttonTitleAtIndex:buttonIndex]];
    UIAlertView* messageAlert = [[UIAlertView alloc] initWithTitle:nil message:alertText delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [messageAlert show];
}

@end

@implementation NormalActionSheetDelegate

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex < 0)
    {
        return;
    }
    
    NSString *alertText = [NSString stringWithFormat:@"Normal Action Sheet: '%@'", [actionSheet buttonTitleAtIndex:buttonIndex]];
    UIAlertView* messageAlert = [[UIAlertView alloc] initWithTitle:nil message:alertText delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [messageAlert show];
}

@end
