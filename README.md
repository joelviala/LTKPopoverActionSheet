# LTKPopoverActionSheet

LTKPopoverActionSheet is a fully customizable UIActionSheet replacement for iPad apps. Have you ever wanted to customize popovers in your apps but held back because you couldn't get UIActionSheet to match? Use LTKPopoverActionSheet instead and customize your iPad action sheets to your apps UI. LTKPopoverActionSheet supports iOS 5, uses ARC, and leverages modern Objective-C syntax like object literals and property auto synthesis.

You can read more about LTKPopoverActionSheet [here](http://logicalthought.co/2012/10/15/customize-ipad-action-sheets-ltkpopoveractionsheet).

## Getting Started

To use LTKPopoverActionSheet just download LTKPopoverActionSheet.h, LTKPopoverActionSheet.m, and LTKPopoverActionSheetDelegate.h and add them to your project. If you would like to use the default action sheet style, which looks like the default UIKit action sheet, you should also get the button images in the Resources directory. These images aren't mandatory and LTKPopoverActionSheet will use a sensible color as default if the images aren't available.

## Using LTKPopoverActionSheet

LTKPopoverActionSheet is a replacement for UIActionSheet, so you can use it the same way. The primary difference is that there are no cancel button options. In addition to the standard UIActionSheet compatibility API there is a block-based API for handling button actions. The delegate protocol LTKPopoverActionSheetDelegate is the replacement for UIActionSheetDelegate if you prefer a delegate implementation.

LTKPopoverActionSheet makes use of UIAppearance to customize its appearance. The background, buttons, and title are all fully customizable. LTKPopoverActionSheet has also been tested with VoiceOver and behaves just like UIActionSheet.

## Example App

The best way to see LTKPopoverActionSheet in use is to look at the sample app "ActionSheet Example". This example customizes the default look of LTKPopoverActionSheet, but also shows the default style and how it compares to a standard UIActionSheet.

## Bugs and feature requests

Please report bugs and feature requests using the [github issue tracker](http://github.com/adamschlag/LTKPopoverActionSheet/issues). If you have other questions on how to use LTKPopoverActionSheet you can contact me on [App.net](https://alpha.app.net/adamschlag) or [Twitter](http://twitter.com/adamschlag) (I'm @adamschlag on both).

