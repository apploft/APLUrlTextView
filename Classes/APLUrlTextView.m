//  Created by Tino Rachui on 10.09.14.
//  Copyright (c) 2014 apploft GmbH. All rights reserved.
//

#import "APLUrlTextView.h"

static NSString *const kTextRect = @"APLTextRect";
static NSString *const kRange = @"APLRange";
static NSString *const kLinkURL = @"APLLinkURL";


@interface APLUrlTextView ()
@property (nonatomic, strong) NSMutableArray *touchSensitiveAreas;
@property (nonatomic, strong) NSMutableArray *urlsAndRanges;
@property (nonatomic, strong) NSDictionary *linkDescriptionOnTouchBegan;
@end


@implementation APLUrlTextView

-(NSMutableArray*)urlsAndRanges {
    if (_urlsAndRanges == nil) {
        _urlsAndRanges = [NSMutableArray new];
    }
    return _urlsAndRanges;
}

-(NSMutableArray*)touchSensitiveAreas {
    if (_touchSensitiveAreas == nil) {
        _touchSensitiveAreas = [NSMutableArray new];
    }
    return _touchSensitiveAreas;
}

-(NSDictionary*)defaultLinkTextAttributes {
    return @{ NSForegroundColorAttributeName: [UIColor blueColor] };
}

-(void)addLinkToURL:(NSURL*)url withRange:(NSRange)range {
    [self.urlsAndRanges addObject:@{ kRange : [NSValue valueWithRange:range], kLinkURL : url }];
    
    NSMutableAttributedString *mutableAttributedString = [self.attributedText mutableCopy];
    
    if ([mutableAttributedString length] > 0) {
        NSDictionary *linkAttributes = self.linkTextAttributes ?: [self defaultLinkTextAttributes];
        [mutableAttributedString addAttributes:linkAttributes range:range];
    }
    self.attributedText = mutableAttributedString;
}

-(void)removeAllURLLinks {
    [self.urlsAndRanges removeAllObjects];
    [self.touchSensitiveAreas removeAllObjects];
}

-(void)updateTouchSensitiveAreas {
    [self.touchSensitiveAreas removeAllObjects];
    
    [self.urlsAndRanges enumerateObjectsUsingBlock:^(NSDictionary *urlDescription, NSUInteger idx, BOOL *stop) {
        NSRange range = [urlDescription[kRange] rangeValue];
        CGRect touchSensitiveRect = [self touchableAreaForStringRange:range];
        NSValue *value = [NSValue valueWithCGRect:touchSensitiveRect];
    
        NSDictionary *linkDescription = @{ kTextRect : value, kLinkURL : urlDescription[kLinkURL] };
    
        [self.touchSensitiveAreas addObject:linkDescription];
    }];
}

-(CGRect)touchableAreaForStringRange:(NSRange)range {
    UITextPosition *start = [self positionFromPosition:self.beginningOfDocument offset:range.location];
    UITextPosition *end = [self positionFromPosition:start offset:range.length];
    UITextRange *textRange = [self textRangeFromPosition:start toPosition:end];
    CGRect rc = CGRectIntegral([self firstRectForRange:textRange]);
        
    return [self convertRect:rc toView:self.textInputView];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    id<APLUrlTextViewDelegate> textViewDelegate = (id<APLUrlTextViewDelegate>)self.delegate;
    
    if (![textViewDelegate respondsToSelector:@selector(textView:didSelectLinkWithURL:)]) {
        return;
    }
    
    [self updateTouchSensitiveAreas];
    
    self.linkDescriptionOnTouchBegan = nil;
    
    UITouch *firstTouchInView = [touches anyObject];
    CGPoint touchPoint = [firstTouchInView locationInView:self.textInputView];
    
#ifdef DEBUG
    NSLog(@"%s: touch point %@", __PRETTY_FUNCTION__, NSStringFromCGPoint(touchPoint));
#endif
    
    [self.touchSensitiveAreas enumerateObjectsUsingBlock:^(NSDictionary *linkDescription, NSUInteger index, BOOL *stop) {
        CGRect touchSensitiveArea = [linkDescription[kTextRect] CGRectValue];
        
        if (CGRectContainsPoint(touchSensitiveArea, touchPoint)) {
            self.linkDescriptionOnTouchBegan = linkDescription;
            *stop = YES;
        }
    }];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    id<APLUrlTextViewDelegate> textViewDelegate = (id<APLUrlTextViewDelegate>)self.delegate;
    
    if (![textViewDelegate respondsToSelector:@selector(textView:didSelectLinkWithURL:)]) {
        return;
    }
    
    UITouch *firstTouchInView = [touches anyObject];
    CGPoint touchPoint = [firstTouchInView locationInView:self.textInputView];

#ifdef DEBUG
    NSLog(@"%s: touch point %@", __PRETTY_FUNCTION__, NSStringFromCGPoint(touchPoint));
#endif
    
    [self.touchSensitiveAreas enumerateObjectsUsingBlock:^(NSDictionary *linkDescription, NSUInteger index, BOOL *stop) {
        CGRect touchSensitiveArea = [linkDescription[kTextRect] CGRectValue];
        CGRect touchSensitiveAreaOnTouchBegan = [self.linkDescriptionOnTouchBegan[kTextRect] CGRectValue];
      
        BOOL touchPointIsInTouchSensitiveArea = CGRectContainsPoint(touchSensitiveArea, touchPoint);
        BOOL touchPointIsInAreaWhereTouchBegan = CGRectEqualToRect(touchSensitiveArea, touchSensitiveAreaOnTouchBegan);
        
        if (touchPointIsInTouchSensitiveArea && touchPointIsInAreaWhereTouchBegan) {
            [textViewDelegate textView:self didSelectLinkWithURL:linkDescription[kLinkURL]];
            *stop = YES;
        }
    }];
}

- (BOOL)canBecomeFirstResponder {
    return NO;
}

@end
