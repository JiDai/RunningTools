//
//  HRZoneView.m
//  RunningTools
//
//  Created by jd on 13/08/2015.
//  Copyright (c) 2015 jd. All rights reserved.
//

#import "HRZoneView.h"

@implementation HRZoneView


- (id)init
{
    self = [super init];
    if(!self){
        return nil;
    }

    NSBundle *mainBundle = [NSBundle mainBundle];
    NSArray *views = [mainBundle loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
    self.frame = ((UIView *)views[0]).frame;
    [self addSubview:views[0]];
    
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(!self){
        return nil;
    }
    
    loadView()
    
    
    return self;
}
@end
