//
//  APLHrefString.m
//
//  Created by Tino Rachui on 24.04.2015
//  Copyright (c) 2015 apploft GmbH. All rights reserved.
//

#import "APLHrefString.h"

@implementation APLUrlRange
@end


@interface APLHrefString()
@property (nonatomic, strong, readwrite) NSMutableAttributedString *attributedString;
@property (nonatomic, strong, readwrite) NSArray *urlRanges;
@property (nonatomic, strong) NSRegularExpression *regEx;

-(NSString*)stringWithoutMarkup;
@end


@implementation APLHrefString

-(id)init {
    self = [super init];
    
    if (self != nil) {
        // Set the default link style
        self.linkStyle = @{
                           NSForegroundColorAttributeName : [UIColor blueColor],
                           NSUnderlineStyleAttributeName : [NSNumber  numberWithInt:NSUnderlineStyleSingle]
                           };
    }
    return self;
}

-(void)setStringWithHref:(NSString *)string {
    _stringWithHref = string;
    
    // force attributedString and touchableAreas to be recreted by setting them to nil
    self.attributedString = nil;
    self.urlRanges = nil;
}

-(NSString*)stringWithoutMarkup {
    NSMutableString *markupFreeString = [self.stringWithHref mutableCopy];
    __block NSUInteger correction = 0;
    
    [self.regEx enumerateMatchesInString:self.stringWithHref options:0 range:NSMakeRange(0, [self.stringWithHref length]) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        /* We are iterating the string from left to right. As we are deleting characters in the
         string we need to correct the location of the capture range accordingly. So we substract
         the current correction and after replacement of a substring add the length of the replaced
         substring to the correction value. Note that we are
         */
        
        NSRange captureGroup1 = [result rangeAtIndex:1];
        NSString *substringCaptureGroup1 = [self.stringWithHref substringWithRange:captureGroup1];
        
        captureGroup1.location -= correction;
        [markupFreeString deleteCharactersInRange:captureGroup1];
        
        correction += captureGroup1.length;
        
        NSRange captureGroup2 = [result rangeAtIndex:2];
        NSString *substringCaptureGroup2 = [self.stringWithHref substringWithRange:captureGroup2];
        
        NSRange captureGroup3 = [result rangeAtIndex:3];
        NSString *substringCaptureGroup3 = [self.stringWithHref substringWithRange:captureGroup3];
        
        captureGroup3.location -= correction;
        [markupFreeString deleteCharactersInRange:captureGroup3];
        
        correction += captureGroup3.length;
    }];
    
    return markupFreeString;
}

-(NSMutableAttributedString*)attributedString {
    if (_attributedString == nil) {
        NSString *markupFreeString = [self stringWithoutMarkup];
        
        if (markupFreeString != nil) {
            _attributedString = [[NSMutableAttributedString alloc] initWithString:markupFreeString];
        } else {
            _attributedString = [[NSMutableAttributedString alloc] init];
        }
        
        // Decorate the touchable substrings
        [self.urlRanges enumerateObjectsUsingBlock:^(APLUrlRange *urlRange, NSUInteger index, BOOL *stop) {
            NSRange range = [urlRange range];
            [_attributedString addAttributes:self.linkStyle range:range];
        }];
        
    }
    return _attributedString;
}

-(NSString*)extractLinkTargetFromHref:(NSString*)href {
    static NSString *kStartPattern = @"<a href=\"";
    static NSString *kEndPattern = @"\"";
    
    NSRange rangeStartPattern = [href rangeOfString:kStartPattern];
    
    NSRange rangeForEndPatternSearch = NSMakeRange(rangeStartPattern.location + rangeStartPattern.length, [href length] - rangeStartPattern.length);
    
    NSRange rangeEndPattern = [href rangeOfString:kEndPattern options:NSCaseInsensitiveSearch range:rangeForEndPatternSearch];
    NSRange urlRange = NSMakeRange(rangeStartPattern.location + rangeStartPattern.length, rangeEndPattern.location - rangeStartPattern.location - rangeStartPattern.length);
    NSString *url = [href substringWithRange:urlRange];
    
    return url;
}

-(NSArray*)urlRanges {
    if (_urlRanges == nil) {
        NSMutableArray *tempArray = [NSMutableArray array];
        
        __block NSUInteger correction = 0;
        
        [self.regEx enumerateMatchesInString:self.stringWithHref options:0 range:NSMakeRange(0, [self.stringWithHref length]) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
            APLUrlRange *touchableArea = [[APLUrlRange alloc] init];
            
            NSRange captureGroup1 = [result rangeAtIndex:1];
            NSString *substringCaptureGroup1 = [self.stringWithHref substringWithRange:captureGroup1];
            NSString *url = [self extractLinkTargetFromHref:substringCaptureGroup1];
            
            correction += captureGroup1.length;
            
            NSRange captureGroup2 = [result rangeAtIndex:2];
            
            captureGroup2.location -= correction;
            
            NSRange captureGroup3 = [result rangeAtIndex:3];
            
            correction += captureGroup3.length;
            
            touchableArea.range = captureGroup2;
            touchableArea.url = [NSURL URLWithString:url];
            [tempArray addObject:touchableArea];
        }];
        
        _urlRanges = tempArray;
    }
    
    return _urlRanges;
}

-(NSRegularExpression*)regEx {
    /* Matches strings like "I have read <href="http://trendu.com">Link Text</href> blah blah"
     The first capture group contains the '<href="...">
     the second capture group contains the 'Link Text'
     the third capture group
     A capture group is enclosed in '()' in the regex expression.
     */
    static NSString *kRegExPattern = @"(<a href=[^>]*>)([^<]*)(</a>)";
    
    if (_regEx == nil) {
        NSError *error = nil;
        _regEx = [NSRegularExpression regularExpressionWithPattern:kRegExPattern options:NSRegularExpressionCaseInsensitive error:&error];
        
        if (error != nil) {
            NSLog(@"Error parsing string %@", self.stringWithHref);
        }
    }
    return _regEx;
}

@end
