//
//  JDKeyboardManager.m
//  RunningTools
//
//  Created by jd on 19/08/2015.
//  Copyright (c) 2015 jd. All rights reserved.
//

#import "JDKeyboardManager.h"

@implementation JDKeyboardManager

#pragma mark Singleton Methods

+ (JDKeyboardManager *)sharedManager {
    static JDKeyboardManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}


#
#pragma mark Events
#

- (void)attachOnView:(UIView *)superView {
    view = superView;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [view addGestureRecognizer:tap];
}

- (void)keyboardWillShow:(NSNotification *)aNotification {
    UIScrollView *scrollView = (UIScrollView *)view;
    
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGRect aRect = view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, [self activeField].frame.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, [self activeField].frame.origin.y-kbSize.height);
        [scrollView setContentOffset:scrollPoint animated:YES];
    }
}

- (void)keyboardWillHide:(NSNotification *)aNotification {
    UIScrollView *scrollView = (UIScrollView *)view;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
}


- (void)hideKeyboard {
    if (view == nil) {
        return;
    }
    for (UIView *v in [view subviews]) {
        if ([v isKindOfClass:[UITextField class]]) {
            [(UITextField *)v resignFirstResponder];
        }
    }
}
- (UITextField *)activeField {
    for (UIView *v in [view subviews]) {
        if ([v isKindOfClass:[UITextField class]] && [v isFirstResponder]) {
            return (UITextField *)v;
        }
    }
    return nil;
}

@end
