//
//  HRZoneView.h
//  RunningTools
//
//  Created by jd on 13/08/2015.
//  Copyright (c) 2015 jd. All rights reserved.
//

#import <UIKit/UIKit.h>


#define loadView() \
NSBundle *mainBundle = [NSBundle mainBundle]; \
NSArray *views = [mainBundle loadNibNamed:NSStringFromClass([self class]) owner:self options:nil]; \
[self addSubview:views[0]];


@interface HRZoneView : UIView

@property (weak, nonatomic) IBOutlet UITextField *percentTextField;
@property (weak, nonatomic) IBOutlet UILabel *heartRateLabel;

@end
