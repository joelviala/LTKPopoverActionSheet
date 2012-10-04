//
//  LTKViewController.m
//  ActionSheet Example
//
//  Created by Adam on 9/30/12.
//  Copyright (c) 2012 Logical Thought. All rights reserved.
//

#import "LTKViewController.h"
#import "LTKPopoverActionSheet.h"

@interface LTKViewController ()

@property (nonatomic, strong) LTKPopoverActionSheet *activePopoverActionSheet;

- (void) showDefaultActionSheetWithNoTitleFromBarButtonItem:(UIBarButtonItem *)sender;
- (void) showDefaultActionSheetWithTitleFromBarButtonItem:(UIBarButtonItem *)sender;

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
    
    self.customNavigationItem.leftBarButtonItems = @[defaultNoTitleItem, defaultWithTitleItem];
    
    self.activePopoverActionSheet = nil;
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - private methods showing LTKPopoverActionSheet examples

- (void) showDefaultActionSheetWithNoTitleFromBarButtonItem:(UIBarButtonItem *)sender
{
    if (self.activePopoverActionSheet)
    {
        if ([self.activePopoverActionSheet isVisible])
        {
            [self.activePopoverActionSheet dismissPopoverAnimated:YES];
        }
        
        self.activePopoverActionSheet = nil;
    }
    
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
    if (self.activePopoverActionSheet)
    {
        if ([self.activePopoverActionSheet isVisible])
        {
            [self.activePopoverActionSheet dismissPopoverAnimated:YES];
        }
        
        self.activePopoverActionSheet = nil;
    }
    
    LTKPopoverActionSheet *popoverActionSheet = [[LTKPopoverActionSheet alloc] initWithTitle:nil
                                                                                    delegate:self
                                                                      destructiveButtonTitle:nil
                                                                           otherButtonTitles:@"Item 1", @"Item 2", nil];
    
    [popoverActionSheet showFromBarButtonItem:sender animated:YES];
    
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
