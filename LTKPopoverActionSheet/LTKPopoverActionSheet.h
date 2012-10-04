//
//  LTKPopoverActionSheet.h
//  LTKPopoverActionSheet
//
//  Created by Adam on 9/30/12.
//  Copyright (c) 2012 Logical Thought LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LTKPopoverActionSheetDelegate.h"

// Define a custom type for the Blocks API
typedef void (^LTKPopoverActionSheetBlock)(void);

@interface LTKPopoverActionSheet : UIView

// UI Customization Properties
// * These should be set before displaying the action sheet *

@property (nonatomic) CGFloat sheetWidth UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *backgroundColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIImage *backgroundImage UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) Class popoverBackgroundViewClass UI_APPEARANCE_SELECTOR;

@property (nonatomic) CGFloat titleTopPadding UI_APPEARANCE_SELECTOR;
@property (nonatomic) CGFloat titleBottomPadding UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIFont *titleFont UI_APPEARANCE_SELECTOR;
@property (nonatomic) UITextAlignment titleTextAlignment UI_APPEARANCE_SELECTOR;

@property (nonatomic) CGSize buttonSize UI_APPEARANCE_SELECTOR;
@property (nonatomic) CGFloat buttonBorderWidth UI_APPEARANCE_SELECTOR;
@property (nonatomic) CGFloat buttonBorderRadius UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIFont *buttonFont UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *actionButtonBorderColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *destructiveButtonBorderColor UI_APPEARANCE_SELECTOR;
- (UIColor*) titleColorForState:(UIControlState)state UI_APPEARANCE_SELECTOR;
- (void) setTitleColor:(UIColor *)color forState:(UIControlState)state UI_APPEARANCE_SELECTOR;
- (UIColor*) buttonBackgroundColorForState:(UIControlState)state UI_APPEARANCE_SELECTOR;
- (void) setButtonBackgroundColor:(UIColor *)color forState:(UIControlState)state UI_APPEARANCE_SELECTOR;
- (UIImage*) buttonBackgroundImageForState:(UIControlState)state UI_APPEARANCE_SELECTOR;
- (void) setButtonBackgroundImage:(UIImage *)image forState:(UIControlState)state UI_APPEARANCE_SELECTOR;


// In addition to the standard UIActionSheet API provided below there are a set of convenience
// methods defined to allow for simpler initialization, blocks-based button handling, and
// simple dismissal. This API is not compatible with UIActionSheet, so use at your discretion.
//
// Note that when using blocks for adding action sheet buttons that, if a delegate is set, the
// delegate methods will still get called by LTKPopoverActionSheet.

- (id) initWithTitle:(NSString *)title;
- (id) init;
- (NSInteger) addButtonWithTitle:(NSString *)title block:(LTKPopoverActionSheetBlock)block;
- (NSInteger) addDestructiveButtonWithTitle:(NSString *)title block:(LTKPopoverActionSheetBlock)block;
- (void) dismissPopoverAnimated:(BOOL)animated;

// UIActionSheet compatibility methods (without methods that are not relevant to iPad apps) 

// Creating Action Sheets
- (id) initWithTitle:(NSString *)title delegate:(id<LTKPopoverActionSheetDelegate>)delegate destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

// Setting Properties
@property (nonatomic, weak) id<LTKPopoverActionSheetDelegate> delegate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, readonly, getter=isVisible) BOOL visible;

// Configuring Buttons
// Note: cancel button is not used or needed for a popover action sheet, so there is no API for a cancel button
- (NSInteger) addButtonWithTitle:(NSString *)title;
@property (nonatomic, readonly) NSInteger numberOfButtons;
- (NSString*) buttonTitleAtIndex:(NSInteger)buttonIndex;
@property (nonatomic) NSInteger destructiveButtonIndex;
@property (nonatomic, readonly) NSInteger firstOtherButtonIndex;

// Presenting the Action Sheet
/*
 * The following methods from UIActionSheet are not implemented as they are not applicable on iPad:
 *
 * – showFromTabBar:
 * – showFromToolbar:
 * – showInView:
 *
 * According to documentation these methods display the action sheet in the center of the screeen 
 * because they should not be used on iPad. For that reason they are not added to this class. You 
 * should use the methods below instead.
 */
- (void) showFromBarButtonItem:(UIBarButtonItem *)item animated:(BOOL)animated;
- (void) showFromRect:(CGRect)rect inView:(UIView *)view animated:(BOOL)animated;

// Dismissing the Action Sheet
- (void) dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated;

@end
