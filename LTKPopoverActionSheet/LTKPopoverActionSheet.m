//
//  LTKPopoverActionSheet.m
//  LTKPopoverActionSheet
//
//  Created by Adam Schlag on 9/30/12.
//  Copyright (c) 2012 Logical Thought. All rights reserved.
//

#import "LTKPopoverActionSheet.h"
#import <UIKit/UIPopoverBackgroundView.h>
#import <QuartzCore/QuartzCore.h>

NSInteger const LTKIndexForNoButton          = -1;
CGFloat   const LTKActionSheetDefaultWidth   = 272.0f;
CGFloat   const LTKActionSheetDefaultHeight  = 480.0f;
CGFloat   const LTKDefaultButtonHeight       = 44.0f;
CGFloat   const LTKDefaultButtonPadding      = 8.0f;
CGFloat   const LTKTitleLabelTopPadding      = 7.0f;
CGFloat   const LTKTitleLabelFontSize        = 13.0f;
CGFloat   const LTKMaxLinesInTitle           = 10.0f;
CGFloat   const LTKTitleLabelBottomPadding   = 12.0f;
CGFloat   const LTKDefaultButtonBorderWidth  = 0.5f;
CGFloat   const LTKDefaultButtonBorderRadius = 6.0f;
CGFloat   const LTKDefaultButtonFontSize     = 19.0f;

// appearance keys for setting appearance properties
NSString const *kAppearanceAttributeSize = @"size";
NSString const *kAppearanceAttributeBorderColor = @"borderColor";
NSString const *kAppearanceAttributeBorderWidth = @"borderWidth";
NSString const *kAppearanceAttributeCornerRadius = @"cornerRadius";
NSString const *kAppearanceAttributeButtonFont = @"buttonFont";
NSString const *kAppearanceAttributeButtonTitle = @"buttonTitle";
NSString const *kAppearanceAttributeTitleColors = @"titleColors";
NSString const *kAppearanceAttributeBackgroundColors = @"backgroundColors";
NSString const *kAppearanceAttributeBackgroundImages = @"backgroundImages";

@interface LTKPopoverActionSheetPopoverDelegate : NSObject <UIPopoverControllerDelegate>

@property (nonatomic, weak) LTKPopoverActionSheet *popoverActionSheet;
@property (nonatomic) NSInteger activeButtonIndex;

@end

@interface LTKPopoverActionSheetContentController : UIViewController

- (void) addActionSheet:(LTKPopoverActionSheet *)actionSheet;

@end

@interface LTKPopoverActionSheet ()

@property (nonatomic, strong) NSMutableArray *buttonTitles;
@property (nonatomic, strong) NSMutableArray *blockArray;
@property (nonatomic, strong) UIPopoverController *popoverController;
@property (nonatomic, strong) LTKPopoverActionSheetPopoverDelegate *popoverDelegate;
@property (nonatomic, getter = isDismissing) BOOL dismissing;
@property (nonatomic) BOOL subviewsLaidOut;

- (void) buttonPressed:(id)sender;
- (void) buttonHighlighted:(id)sender;
- (void) buttonReleased:(id)sender;
- (CGSize) sizeForContent;
- (UIButton *) actionSheetButtonWithAttributes:(NSDictionary *)attributes;

@end

@implementation LTKPopoverActionSheet

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        _destructiveButtonIndex = LTKIndexForNoButton;
    }
    
    return self;
}

- (id) initWithTitle:(NSString *)title delegate:(id<LTKPopoverActionSheetDelegate>)delegate destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...
{
    self = [self initWithFrame:CGRectMake(0.0f, 0.0f, LTKActionSheetDefaultWidth, LTKActionSheetDefaultHeight)];
    
    if (self)
    {
        self.title = title;
        self.delegate = delegate;
        _destructiveButtonIndex = LTKIndexForNoButton;
        
        if (nil != destructiveButtonTitle)
        {
            _destructiveButtonIndex = [self addButtonWithTitle:destructiveButtonTitle];
        }
        
        va_list args;
        va_start(args, otherButtonTitles);
        for (NSString *arg = otherButtonTitles; arg != nil; arg = va_arg(args, NSString *))
        {
            [self addButtonWithTitle:arg];
        }
        va_end(args);
    }
    
    return self;
}

- (void) layoutSubviews
{
    // if there are no changes to the view then don't make any changes
    if (self.subviewsLaidOut)
    {
        return;
    }
    
    // remove any currently added subviews
    for (UIView *subview in self.subviews)
    {
        [subview removeFromSuperview];
    }
    
    // set up the view
    self.backgroundColor = [UIColor clearColor]; // TODO this should be customizable
    CGFloat viewHeight   = (LTKDefaultButtonHeight * self.buttonTitles.count) + (LTKDefaultButtonPadding * (self.buttonTitles.count - 1));
    self.frame           = CGRectMake(0.0f, 0.0f, LTKActionSheetDefaultWidth, viewHeight);
    
    CGFloat currentY = 0.0f;
    
    // if set, add the title label
    if (nil != self.title)
    {
        currentY = currentY + LTKTitleLabelTopPadding;
        
        CGSize maximumSize  = CGSizeMake(LTKActionSheetDefaultWidth, LTKTitleLabelFontSize * LTKMaxLinesInTitle);
        CGSize stringSize   = [self.title sizeWithFont:[UIFont systemFontOfSize:LTKTitleLabelFontSize] constrainedToSize:maximumSize lineBreakMode:UILineBreakModeWordWrap];
        
        // TODO this should be customizable
        UILabel *titleLabel        = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, currentY, LTKActionSheetDefaultWidth, stringSize.height)];
        titleLabel.font            = [UIFont systemFontOfSize:LTKTitleLabelFontSize];
        titleLabel.numberOfLines   = 0; // don't set a max number of lines
        titleLabel.text            = self.title;
        titleLabel.textAlignment   = UITextAlignmentCenter;
        titleLabel.textColor       = [UIColor whiteColor]; // TODO this should be customizable
        titleLabel.backgroundColor = [UIColor clearColor]; // TODO this should be customizable
        
        // add in height for the label
        CGRect viewFrame      = self.frame;
        viewFrame.size.height = LTKTitleLabelTopPadding + titleLabel.frame.size.height + LTKTitleLabelBottomPadding + viewFrame.size.height;
        self.frame            = viewFrame;
        
        [self addSubview:titleLabel];
        currentY = currentY + titleLabel.frame.size.height + LTKTitleLabelBottomPadding;
    }
    
    NSUInteger buttonIndex = 0;
    
    for (NSString *buttonTitle in self.buttonTitles)
    {
        NSDictionary *buttonAttributes = @{};
        
        if (buttonIndex == self.destructiveButtonIndex)
        {
            buttonAttributes = @{
                kAppearanceAttributeSize: [NSValue valueWithCGSize:CGSizeMake(LTKActionSheetDefaultWidth, LTKDefaultButtonHeight)],
                kAppearanceAttributeBorderColor: [UIColor blackColor],
                kAppearanceAttributeBorderWidth: @(LTKDefaultButtonBorderWidth),
                kAppearanceAttributeCornerRadius: @(LTKDefaultButtonBorderRadius),
                kAppearanceAttributeButtonFont: [UIFont boldSystemFontOfSize:LTKDefaultButtonFontSize],
                kAppearanceAttributeButtonTitle: buttonTitle,
                kAppearanceAttributeTitleColors: @{@(UIControlStateNormal): [UIColor whiteColor], @(UIControlStateHighlighted): [UIColor whiteColor]},
                kAppearanceAttributeBackgroundColors: @{@(UIControlStateNormal) : [UIColor redColor]}
            };
        }
        else
        {
            buttonAttributes = @{
                kAppearanceAttributeSize: [NSValue valueWithCGSize:CGSizeMake(LTKActionSheetDefaultWidth, LTKDefaultButtonHeight)],
                kAppearanceAttributeBorderColor: [UIColor blackColor],
                kAppearanceAttributeBorderWidth: @(LTKDefaultButtonBorderWidth),
                kAppearanceAttributeCornerRadius: @(LTKDefaultButtonBorderRadius),
                kAppearanceAttributeButtonFont: [UIFont boldSystemFontOfSize:LTKDefaultButtonFontSize],
                kAppearanceAttributeButtonTitle: buttonTitle,
                kAppearanceAttributeTitleColors: @{@(UIControlStateNormal): [UIColor blackColor], @(UIControlStateHighlighted): [UIColor whiteColor]},
                kAppearanceAttributeBackgroundColors: @{@(UIControlStateNormal) : [UIColor whiteColor]}
            };
        }
        
        UIButton *button = [self actionSheetButtonWithAttributes:buttonAttributes];
        
        CGRect buttonFrame = button.frame;
        buttonFrame.origin = CGPointMake(0.0f, currentY);
        button.frame       = buttonFrame;
        button.tag         = buttonIndex;
        buttonIndex        = buttonIndex + 1;
        
        [self addSubview:button];
        currentY = currentY + button.frame.size.height + LTKDefaultButtonPadding;
    }
    
    self.subviewsLaidOut = YES;
}

#pragma mark - UIActionSheet compatibility API

- (NSInteger) addButtonWithTitle:(NSString *)title
{
    NSInteger index = self.buttonTitles.count;
    [self.buttonTitles addObject:title];
    
    // invalidate the popover and view so it will redraw
    self.popoverController = nil;
    self.subviewsLaidOut = NO;
    
    return index;
}

- (NSString *) buttonTitleAtIndex:(NSInteger)buttonIndex
{
    if (self.buttonTitles.count > buttonIndex)
    {
        return (NSString *)[self.buttonTitles objectAtIndex:buttonIndex];
    }
    
    return nil;
}

- (void) dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated
{
    if ([self isDismissing])
    {
        return;
    }
    
    self.dismissing = YES;
    self.popoverDelegate.activeButtonIndex = buttonIndex;
    
    if (buttonIndex >= 0 && self.blockArray.count > buttonIndex)
    {
        id block = [self.blockArray objectAtIndex:buttonIndex];
        
        if (![block isEqual:[NSNull null]])
        {
            ((void (^)())block)();
        }
    }
    
    // if there is no delegate or if the button index doesn't correspond to a button then just return the popover
    if (nil == self.delegate || buttonIndex == LTKIndexForNoButton)
    {
        [self.popoverController dismissPopoverAnimated:animated];
    }
    else
    {
        if ([self.delegate respondsToSelector:@selector(actionSheet:clickedButtonAtIndex:)])
        {
            [self.delegate actionSheet:self clickedButtonAtIndex:buttonIndex];
        }
        
        if ([self.delegate respondsToSelector:@selector(actionSheet:willDismissWithButtonIndex:)])
        {
            [self.delegate actionSheet:self willDismissWithButtonIndex:buttonIndex];
        }
        
        [self.popoverController dismissPopoverAnimated:animated];
        
        if ([self.delegate respondsToSelector:@selector(actionSheet:didDismissWithButtonIndex:)])
        {
            [self.delegate actionSheet:self didDismissWithButtonIndex:buttonIndex];
        }
    }
    
    self.dismissing = NO;
}

- (void) showFromBarButtonItem:(UIBarButtonItem *)item animated:(BOOL)animated
{
    if ([self.popoverController isPopoverVisible])
    {
        return;
    }
    
    [self setNeedsDisplay];
    [self.popoverController setPopoverContentSize:[self sizeForContent]];
    
    if (nil != self.delegate && [self.delegate respondsToSelector:@selector(willPresentActionSheet:)])
    {
        [self.delegate willPresentActionSheet:self];
    }
    
    [self.popoverController presentPopoverFromBarButtonItem:item permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void) showFromRect:(CGRect)rect inView:(UIView *)view animated:(BOOL)animated
{
    if ([self.popoverController isPopoverVisible])
    {
        return;
    }
    
    [self setNeedsDisplay];
    [self.popoverController setPopoverContentSize:[self sizeForContent]];
    [self.popoverController presentPopoverFromRect:rect inView:view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

#pragma mark - custom convenience API

- (id) initWithTitle:(NSString *)title
{
    self = [self initWithFrame:CGRectMake(0.0f, 0.0f, LTKActionSheetDefaultWidth, LTKActionSheetDefaultHeight)];
    
    if (self)
    {
        self.title              = title;
        _destructiveButtonIndex = LTKIndexForNoButton;
    }
    
    return self;
}

- (id) init
{
    return [self initWithTitle:nil];
}

- (NSInteger) addButtonWithTitle:(NSString *)title block:(LTKPopoverActionSheetBlock)block
{
    NSInteger buttonIndex = [self addButtonWithTitle:title];
    
    if (buttonIndex >= 0 && nil != block)
    {
        [self.blockArray addObject:[block copy]];
    }
    else
    {
        [self.blockArray addObject:[NSNull null]];
    }
    
    return buttonIndex;
}

- (NSInteger) addDestructiveButtonWithTitle:(NSString *)title block:(LTKPopoverActionSheetBlock)block
{
    NSInteger buttonIndex = [self addButtonWithTitle:title];
    
    if (buttonIndex >= 0 && nil != block)
    {
        _destructiveButtonIndex = buttonIndex;
        [self.blockArray addObject:[block copy]];
    }
    else
    {
        [self.blockArray addObject:[NSNull null]];
    }
    
    return buttonIndex;
}

- (void) dismissPopoverAnimated:(BOOL)animated
{
    return [self dismissWithClickedButtonIndex:LTKIndexForNoButton animated:animated];
}

#pragma mark - appearance API

- (UIColor*) titleColorForState:(UIControlState)state
{
    NSLog(@"%i", state);
    
    return nil;
}

- (void) setTitleColor:(UIColor *)color forState:(UIControlState)state
{
    NSLog(@"%@", color);
    NSLog(@"%i", state);
}

- (UIColor*) buttonBackgroundColorForState:(UIControlState)state
{
    NSLog(@"%i", state);
    
    return nil;
}

- (void) setButtonBackgroundColor:(UIColor *)color forState:(UIControlState)state
{
    NSLog(@"%@", color);
    NSLog(@"%i", state);
}

- (UIImage*) buttonBackgroundImageForState:(UIControlState)state
{
    NSLog(@"%i", state);
    
    return nil;
}

- (void) setButtonBackgroundImage:(UIImage *)image forState:(UIControlState)state
{
    NSLog(@"%@", image);
    NSLog(@"%i", state);
}

#pragma mark - custom getters/setters

- (void) setTitle:(NSString *)title
{
    if (![_title isEqualToString:title])
    {
        _title = [title copy];
        
        // invalidate the popover and view so it will redraw
        self.popoverController = nil;
        self.subviewsLaidOut = NO;
    }
}

- (void) setDestructiveButtonIndex:(NSInteger)destructiveButtonIndex
{
    // if the input index is less than 0, just ignore and return
    // NOTE: internal methods looking to set the value should directly set
    // the _destructiveButtonIndex variable
    if (destructiveButtonIndex < 0)
    {
        return;
    }
    
    // if there is no destructive button then just return
    if (LTKIndexForNoButton == _destructiveButtonIndex)
    {
        return;
    }
    // if there is only one button then just return
    else if (1 == self.buttonTitles.count)
    {
        return;
    }
    else
    {
        NSString *destructiveButtonTitle = (NSString *)[self.buttonTitles objectAtIndex:self.destructiveButtonIndex];
        [self.buttonTitles removeObject:destructiveButtonTitle];
        [self.buttonTitles insertObject:destructiveButtonTitle atIndex:destructiveButtonIndex];
        _destructiveButtonIndex = destructiveButtonIndex;
        
        // invalidate the popover and view so it will redraw
        self.popoverController = nil;
        self.subviewsLaidOut = NO;
    }
}

- (NSInteger) firstOtherButtonIndex
{
    // The first button index will only ever be LTKIndexForNoButton, 0, or 1:
    //  • it will be -1 if there is no regular button
    //  • it will be 0 if there is at least one button and the destructive button index is not 0
    //  • it will be 1 if there is more than one button and the destructive button index is 0
    NSInteger buttonIndex = LTKIndexForNoButton; // -1
    
    if (0 != self.destructiveButtonIndex && self.buttonTitles.count > 0)
    {
        buttonIndex = 0;
    }
    else if (0 == self.destructiveButtonIndex && self.buttonTitles.count > 1)
    {
        buttonIndex = 1;
    }
    
    return buttonIndex;
}

- (NSInteger) numberOfButtons
{
    return self.buttonTitles.count;
}

- (BOOL) isVisible
{
    return [self.popoverController isPopoverVisible];
}

- (UIPopoverController *) popoverController
{
    if (nil == _popoverController)
    {
        LTKPopoverActionSheetContentController *contentController = [[LTKPopoverActionSheetContentController alloc] init];
        [contentController addActionSheet:self];
        
        _popoverController = [[UIPopoverController alloc] initWithContentViewController:contentController];
        _popoverController.delegate = self.popoverDelegate;
        _popoverController.popoverBackgroundViewClass = nil; // TODO this should be customizable
    }
    
    return _popoverController;
}

- (LTKPopoverActionSheetPopoverDelegate *) popoverDelegate
{
    if (nil == _popoverDelegate)
    {
        _popoverDelegate = [[LTKPopoverActionSheetPopoverDelegate alloc] init];
        _popoverDelegate.popoverActionSheet = self;
        _popoverDelegate.activeButtonIndex  = LTKIndexForNoButton;
    }
    
    return _popoverDelegate;
}

- (NSMutableArray *) buttonTitles
{
    if (nil == _buttonTitles)
    {
        _buttonTitles = [@[] mutableCopy];
    }
    
    return _buttonTitles;
}

- (NSMutableArray *) blockArray
{
    if (nil == _blockArray)
    {
        _blockArray = [@[] mutableCopy];
    }
    
    return _blockArray;
}

#pragma mark - private methods

- (void) buttonPressed:(id)sender
{
    if ([sender isKindOfClass:[UIButton class]])
    {
        UIButton  *button      = (UIButton *)sender;
        NSInteger  buttonIndex = button.tag;
        
        if (nil == button.currentBackgroundImage)
        {
            // set custom color
            if ([UIColor blueColor] == button.backgroundColor) // TODO this should check the custom setting
            {
                button.backgroundColor = [UIColor whiteColor]; // TODO this should be customizable
            }
            else
            {
                button.backgroundColor = [UIColor redColor]; // TODO this should be customizable
            }
        }
        
        [self dismissWithClickedButtonIndex:buttonIndex animated:YES];
    }
}

- (void) buttonHighlighted:(id)sender
{
    if ([sender isKindOfClass:[UIButton class]])
    {
        UIButton *button = (UIButton *)sender;
        
        if (nil == button.currentBackgroundImage)
        {
            // set custom color
            if ([UIColor whiteColor] == button.backgroundColor) // TODO this should check the custom setting
            {
                button.backgroundColor = [UIColor blueColor]; // TODO this should be customizable
            }
            else
            {
                button.backgroundColor = [UIColor colorWithRed:0.61f green:0.0f blue:0.0f alpha:1.0f]; // TODO this should be customizable
            }
        }
    }
}

- (void) buttonReleased:(id)sender
{
    if ([sender isKindOfClass:[UIButton class]])
    {
        UIButton  *button      = (UIButton *)sender;
        
        if (nil == button.currentBackgroundImage)
        {
            // set custom color
            if ([UIColor blueColor] == button.backgroundColor) // TODO this should check the custom setting
            {
                button.backgroundColor = [UIColor whiteColor]; // TODO this should be customizable
            }
            else
            {
                button.backgroundColor = [UIColor redColor]; // TODO this should be customizable
            }
        }
    }
}

- (CGSize) sizeForContent
{
    CGFloat viewHeight = (LTKDefaultButtonHeight * self.buttonTitles.count) + (LTKDefaultButtonPadding * (self.buttonTitles.count - 1));
    
    if (nil != self.title)
    {
        CGSize maximumSize  = CGSizeMake(LTKActionSheetDefaultWidth, LTKTitleLabelFontSize * LTKMaxLinesInTitle);
        CGSize stringSize   = [self.title sizeWithFont:[UIFont systemFontOfSize:LTKTitleLabelFontSize] constrainedToSize:maximumSize lineBreakMode:UILineBreakModeWordWrap];
        
        // add in height for the label
        viewHeight = LTKTitleLabelTopPadding + stringSize.height + LTKTitleLabelBottomPadding + viewHeight;
    }
    
    return CGSizeMake(LTKActionSheetDefaultWidth, viewHeight);
}

- (UIButton *) actionSheetButtonWithAttributes:(NSDictionary *)attributes
{
    CGSize  buttonSize = [(NSValue *)[attributes objectForKey:kAppearanceAttributeSize] CGSizeValue];
    UIColor *borderColor = (UIColor *)[attributes objectForKey:kAppearanceAttributeBorderColor];
    CGFloat borderWidth = [(NSNumber *)[attributes objectForKey:kAppearanceAttributeBorderWidth] floatValue];
    CGFloat cornerRadius = [(NSNumber *)[attributes objectForKey:kAppearanceAttributeCornerRadius] floatValue];
    UIFont *buttonFont = (UIFont *)[attributes objectForKey:kAppearanceAttributeButtonFont];
    NSString *buttonTitle = (NSString *)[attributes objectForKey:kAppearanceAttributeButtonTitle];
    NSDictionary *titleColors = (NSDictionary *)[attributes objectForKey:kAppearanceAttributeTitleColors];
    NSDictionary *backgroundColors = (NSDictionary *)[attributes objectForKey:kAppearanceAttributeBackgroundColors];
    NSDictionary *backgroundImages = (NSDictionary *)[attributes objectForKey:kAppearanceAttributeBackgroundImages];
    
    UIButton *actionSheetButton = [UIButton buttonWithType:UIButtonTypeCustom];
    actionSheetButton.frame = CGRectMake(0.0f, 0.0f, buttonSize.width, buttonSize.height);
    actionSheetButton.layer.borderColor = [borderColor CGColor];
    actionSheetButton.layer.borderWidth = borderWidth;
    actionSheetButton.layer.cornerRadius = cornerRadius;
    actionSheetButton.titleLabel.font = buttonFont;
    [actionSheetButton setTitle:buttonTitle forState:UIControlStateNormal];
    [actionSheetButton setTitleColor:(UIColor *)[titleColors objectForKey:@(UIControlStateNormal)] forState:UIControlStateNormal];
    [actionSheetButton setTitleColor:(UIColor *)[titleColors objectForKey:@(UIControlStateHighlighted)] forState:UIControlStateHighlighted];
    [actionSheetButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [actionSheetButton addTarget:self action:@selector(buttonHighlighted:) forControlEvents:UIControlEventTouchDown];
    [actionSheetButton addTarget:self action:@selector(buttonReleased:) forControlEvents:UIControlEventTouchDragExit];
    
    if ([backgroundImages objectForKey:@(UIControlStateNormal)] || [backgroundImages objectForKey:@(UIControlStateHighlighted)])
    {
        [actionSheetButton setBackgroundImage:(UIImage *)[backgroundImages objectForKey:@(UIControlStateNormal)] forState:UIControlStateNormal];
        [actionSheetButton setBackgroundImage:(UIImage *)[backgroundImages objectForKey:@(UIControlStateHighlighted)] forState:UIControlStateHighlighted];
    }
    else
    {
        actionSheetButton.backgroundColor = (UIColor *)[backgroundColors objectForKey:@(UIControlStateNormal)];
    }
    
    return actionSheetButton;
}

@end

@implementation LTKPopoverActionSheetPopoverDelegate

- (void) popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    if (nil != self.popoverActionSheet && nil != self.popoverActionSheet.delegate &&
        [self.popoverActionSheet.delegate respondsToSelector:@selector(actionSheet:didDismissWithButtonIndex:)])
    {
        [self.popoverActionSheet.delegate actionSheet:self.popoverActionSheet didDismissWithButtonIndex:self.activeButtonIndex];
        
        self.popoverActionSheet = nil;
        self.activeButtonIndex  = LTKIndexForNoButton;
    }
}

- (BOOL) popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{
    return YES;
}

@end

@implementation LTKPopoverActionSheetContentController

- (void) viewWillAppear:(BOOL)animated
{
    // This will remove the inner shadow from the popover
    if ([NSStringFromClass([self.view.superview class]) isEqualToString:@"UILayoutContainerView"])
    {
        self.view.superview.layer.cornerRadius = 0;
        
        for (UIView *subview in self.view.superview.subviews)
        {
            if ([NSStringFromClass([subview class]) isEqualToString:@"UIImageView"] )
            {
                [subview removeFromSuperview];
            }
        }
    }
}

- (void) addActionSheet:(LTKPopoverActionSheet *)actionSheet
{
    // remove any currently added subviews
    for (UIView *subview in self.view.subviews)
    {
        [subview removeFromSuperview];
    }
    
    CGRect viewFrame = self.view.frame;
    viewFrame.size   = actionSheet.frame.size;
    self.view.frame  = viewFrame;
    
    CGRect actionSheetFrame = actionSheet.frame;
    actionSheetFrame.origin = CGPointZero;
    actionSheet.frame       = actionSheetFrame;
    
    [self.view addSubview:actionSheet];
}

@end
