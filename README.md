APLUrlTextView
=========
A simple UITextView extensions allowing to add URLs and getting informed when the user selects one of these URLs. You can use the 'linkTextAttributtes' of UITextView in order to define the styling of the links being embeded.

## Installation
Install via cocoapods by adding this to your Podfile:

	pod 'APLUrlTextView', '0.0.2'

## Usage
Import header file:

	#import "APLUrlTextView.h"
	#import "APLHrefString.h"
	
Use APLUrlTextView like this:
	
	...
	self.textView.delegate = self;
	...
	NSURL *targetURL = [NSURL URLWithString:"..."];
	NSRange linkRange = NSMakeRange(...);
	[self.textView addLinkToURL:targetURL withRange:linkRange];
	...
	
	// Implement the delegate method extending the UITextViewDelegate method
	// in order to be informed about URLs being touched by the user
	-(void)textView:(APLUrlTextView *)label didSelectLinkWithURL:(NSURL *)url {
	  ...
    }
    
	Use APLHrefString to parse strings containing 'hrefs' like this "A string with 
	<href="http://www.apploft.de">a link</href>" and get a corresponding attributed string plus rnages and urls to be used for the APLUrlTextView.
    		