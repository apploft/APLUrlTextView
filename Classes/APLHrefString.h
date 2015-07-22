//
//  APLHrefString.h
//
//  Created by Tino Rachui on 24.04.2015
//  Copyright (c) 2015 apploft GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
    A tuple of range and url
 */
@interface APLUrlRange : NSObject
@property (nonatomic) NSRange range;
@property (nonatomic) NSURL *url;
@end

/*
    A class accepting strings with embedded 'href' links. 
    E.g. "A text containing a <a href=\"http:\\\\www.apploft.de\">Apploft</a>"
    The class parses the string and produces an attributted string with the markup
    being stripped. Furthermore the class provides an array of url range objects.
    They can for instance be used in order to initialize an APLURLTextView instance.
 */
@interface APLHrefString : NSObject
// a string containing zero or more 'href'-Links
@property (nonatomic, strong) NSString *stringWithHref;

// the attributed string produced by parsing 'stringWithHref'. 'stringWithHref' should have been
// set in advance of accessing this property
@property (nonatomic, strong, readonly) NSMutableAttributedString *attributedString;
// the arry of url range objects produced by parsing 'stringWithHref'
@property (nonatomic, strong, readonly) NSArray *urlRanges;
// attributes to be applied to links found be parsing 'stringWithHref'
@property (nonatomic, strong) NSDictionary *linkStyle;
@end
