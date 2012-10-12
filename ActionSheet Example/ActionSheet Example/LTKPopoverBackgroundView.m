//
//  LTKPopoverBackgroundView.m
//  ActionSheet Example
//
//  Created by Adam on 10/7/12.
//  Copyright (c) 2012 Logical Thought. All rights reserved.
//

#import "LTKPopoverBackgroundView.h"
#import <QuartzCore/QuartzCore.h>

static CGFloat const kCapInset     = 12.0f;
static CGFloat const kContentInset = 10.0f;
static CGFloat const kArrowBase    = 60.0f;
static CGFloat const kArrowHeight  = 30.0f;

@interface LTKPopoverBackgroundView ()

@property (nonatomic, strong) UIImageView *arrowView;
@property (nonatomic, strong) UIImageView *borderImageView;

@end

@implementation LTKPopoverBackgroundView

// these must be explicty declared so they override the default
@synthesize arrowOffset = _arrowOffset;
@synthesize arrowDirection = _arrowDirection;

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        _borderImageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"popover-background"]
                                                               resizableImageWithCapInsets:UIEdgeInsetsMake(kCapInset, kCapInset, kCapInset, kCapInset)]];
        _arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"popover-arrow"]];
        
        // we aren't supposed to set a shadow on the background view, but UIKit does not provide one
        self.borderImageView.clipsToBounds       = NO;
        self.borderImageView.layer.shadowRadius  = 10.0f;
        self.borderImageView.layer.shadowOffset  = CGSizeMake(0.0f, 8.0f);
        self.borderImageView.layer.shadowOpacity = 0.533f;
        self.borderImageView.layer.shadowColor   = [[UIColor darkGrayColor] CGColor];
        
        [self addSubview:_borderImageView];
        [self addSubview:_arrowView];
    }
    
    return self;
}

- (CGFloat) arrowOffset
{
    return _arrowOffset;
}

- (void) setArrowOffset:(CGFloat)arrowOffset
{
    _arrowOffset = arrowOffset;
}

- (UIPopoverArrowDirection) arrowDirection
{
    return _arrowDirection;
}

- (void) setArrowDirection:(UIPopoverArrowDirection)arrowDirection
{
    _arrowDirection = arrowDirection;
}

+ (UIEdgeInsets) contentViewInsets
{
    return UIEdgeInsetsMake(kContentInset, kContentInset, kContentInset, kContentInset);
}

+ (CGFloat) arrowHeight
{
    return kArrowHeight;
}

+ (CGFloat) arrowBase
{
    return kArrowBase;
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat height = self.frame.size.height;
    CGFloat width = self.frame.size.width;
    CGFloat left = 0.0;
    CGFloat top = 0.0;
    CGFloat coordinate = 0.0;
    CGAffineTransform rotation = CGAffineTransformIdentity;
    
    switch (self.arrowDirection)
    {
        case UIPopoverArrowDirectionUp:
            top += kArrowHeight;
            height -= kArrowHeight;
            coordinate = MAX(kCapInset, ((self.frame.size.width / 2) + self.arrowOffset) - (kArrowBase / 2));
            self.arrowView.frame = CGRectMake(coordinate, 0, kArrowBase, kArrowHeight);
            break;
        case UIPopoverArrowDirectionDown:
            height -= kArrowHeight;
            coordinate = MAX(kCapInset, ((self.frame.size.width / 2) + self.arrowOffset) - (kArrowBase / 2));
            self.arrowView.frame = CGRectMake(coordinate, height, kArrowBase, kArrowHeight);
            rotation = CGAffineTransformMakeRotation(M_PI);
            break;
        case UIPopoverArrowDirectionLeft:
            left += kArrowBase;
            width -= kArrowBase;
            coordinate = MAX(kCapInset, ((self.frame.size.height / 2) + self.arrowOffset) - (kArrowHeight / 2));
            self.arrowView.frame = CGRectMake(0, coordinate, kArrowBase, kArrowHeight);
            rotation = CGAffineTransformMakeRotation(-M_PI_2);
            break;
        case UIPopoverArrowDirectionRight:
            width -= kArrowBase;
            coordinate = MAX(kCapInset, ((self.frame.size.height / 2) + self.arrowOffset)- (kArrowHeight / 2));
            self.arrowView.frame = CGRectMake(width, coordinate, kArrowBase, kArrowHeight);
            rotation = CGAffineTransformMakeRotation(M_PI_2);
            break;
        default:
            break;
    }
    
    self.borderImageView.frame = CGRectMake(left, top, width, height);
    [self.arrowView setTransform:rotation];
    
}

@end
