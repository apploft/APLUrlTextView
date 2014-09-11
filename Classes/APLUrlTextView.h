//  Created by Tino Rachui on 10.09.14.
//  Copyright (c) 2014 apploft GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@class APLUrlTextView;

/*
 * Extension of the UITextViewDelegate to enable link handling.
 */
@protocol APLUrlTextViewDelegate <NSObject, UITextViewDelegate>
@optional
/*
 * @param textView the instance invoking this method
 * @param url the URL which has been touched by the user
 */
-(void)textView:(APLUrlTextView*)textView didSelectLinkWithURL:(NSURL*)url;
@end

/*
 * A simple UITextView extensions allowing to add URLs and getting informed when the user selects one of these
 * URLs. You can use the 'linkTextAttributtes' of UITextView in order to define the styling of the links being 
 * embeded. 
 * Please note that a APLUrlTextView instance is supposed to be used in none-editable mode. Make sure though 
 * that user-interaction is enabled for link handling to work.
 */
@interface APLUrlTextView : UITextView
/*
 * @param url the URL to add to the text
 * @param the text range the URL is spanning. Make sure that the provided range is valid in relation to the text the text view is holding.
 */
-(void)addLinkToURL:(NSURL*)url withRange:(NSRange)range;

/*
 * Remove all URL which have previously been added to the text view using 'addLinkToURL:withRange'.
 * After calling this method you have to restore the original text attributes without the links being 
 * highlighted yourself.
 */
-(void)removeAllURLLinks;
@end
