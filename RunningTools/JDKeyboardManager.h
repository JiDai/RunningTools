//
//  JDKeyboardManager.h
//  RunningTools
//
//  Created by jd on 19/08/2015.
//  Copyright (c) 2015 jd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface JDKeyboardManager : NSObject
{
    UIView *view;
}
@property (nonatomic, retain) NSString *someProperty;

+ (id)sharedManager;
- (void)attachOnView:(UIView *)superView;
- (void)keyboardWillShow:(NSNotification *)aNotification;
- (void)keyboardWillHide:(NSNotification *)aNotification;
- (void)hideKeyboardFromView:(UIView *)superView;

@end
