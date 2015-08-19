//
//  SecondViewController.m
//  RunningTools
//
//  Created by jd on 09/08/2015.
//  Copyright (c) 2015 jd. All rights reserved.
//

#import "SecondViewController.h"
#import "HRZoneView.h"
#import "JDKeyboardManager.h"

@interface SecondViewController ()
{
    int curentMethod;
    NSMutableArray *userZones;
    UITextField *activeField;
}

@property (weak, nonatomic) IBOutlet UISegmentedControl *methodSegmentedControl;
@property (weak, nonatomic) IBOutlet UITextField *heartRateMaxTextField;
@property (weak, nonatomic) IBOutlet UITextField *heartRateMinTextField;
@property (weak, nonatomic) IBOutlet UILabel *heartRateMinLabel;
@property (weak, nonatomic) IBOutlet UIView *heartRateZonesView;
@property (weak, nonatomic) IBOutlet UITextView *introTextView;

@end

int const simpleCalcMethod = 0;
int const advancedCalcMethod = 1;

@implementation SecondViewController


#
#pragma mark Lifecycle
#


- (void)viewDidLoad {
    [super viewDidLoad];
    
    curentMethod = simpleCalcMethod;
    [self.methodSegmentedControl setSelectedSegmentIndex:curentMethod];
    
    userZones = [NSMutableArray arrayWithArray:@[@55, @65, @75, @85, @95]];
  
    // Keyboard event
    [[JDKeyboardManager sharedManager] attachOnView:self.view];
    
    [self initializeRateFields];
    [self showForm];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#
#pragma mark Delegates
#


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // If we're trying to add decimal
    // @TODO better detection
    if ([string isEqualToString:@","] || [string isEqualToString:@"."]) {
        return NO;
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    activeField = nil;
    [self updateValues];
}


#
#pragma mark Actions
#


- (IBAction)methodChanged:(id)sender {
    curentMethod = ((UISegmentedControl *)sender).selectedSegmentIndex;
    [self showForm];
    [self updateValues];
}


#
#pragma mark Display
#


- (void)showForm {
    switch (curentMethod) {
        case simpleCalcMethod:
            self.introTextView.text = @"La méthode simple se base uniquement sur la fréquence cardiaque maximale pour déterminer la fréquence d'entrainement.";
            [self.introTextView setNeedsDisplay];
            self.heartRateMinLabel.alpha = 0;
            self.heartRateMinTextField.alpha = 0;
            break;
            
        case advancedCalcMethod:
            curentMethod = advancedCalcMethod;
            self.introTextView.text = @"La méthode avancée se base à la fois sur la fréquence cardiaque maximale et la minimale. Cette méthode est donc plus précise.";
            [self.introTextView setNeedsDisplay];
            self.heartRateMinLabel.alpha = 1;
            self.heartRateMinTextField.alpha = 1;
            break;
        default:
            break;
    }
}

- (void)initializeRateFields {
    int y = 0;
    for (NSNumber *userZone in userZones) {
        HRZoneView *v = [[HRZoneView alloc] init];
        [self.heartRateZonesView addSubview:v];
        
        float percent = [userZone floatValue]/100;
        
        v.percentTextField.text = [NSNumberFormatter localizedStringFromNumber:[NSNumber numberWithFloat:percent] numberStyle:NSNumberFormatterPercentStyle];
        v.heartRateLabel.attributedText = [self formatBPMField:@"0bpm"];
        v.frame = CGRectMake(0, y, v.frame.size.width, v.frame.size.height);
        y = y + v.frame.size.height;
        NSLog(@"%@", NSStringFromCGRect(v.frame));
    }
}

- (void)updateValues {
    if(curentMethod == simpleCalcMethod) {
        int i = 0;
        for (NSNumber *userZone in userZones) {
            HRZoneView *v = (HRZoneView *)[self.heartRateZonesView subviews][i];
            float r = [self.heartRateMaxTextField.text floatValue] * [userZone floatValue] / 100;
            
            NSString *text = [NSString stringWithFormat:@"%dbpm", (int)round(r)];
            v.heartRateLabel.attributedText = [self formatBPMField:text];
            i++;
        }
    }
    else {
        int i = 0;
        for (NSNumber *userZone in userZones) {
            HRZoneView *v = (HRZoneView *)[self.heartRateZonesView subviews][i];
            int fcDiff = [self.heartRateMaxTextField.text floatValue] - [self.heartRateMinTextField.text floatValue];
            float r = fcDiff * [userZone floatValue] / 100;

            NSString *text = [NSString stringWithFormat:@"%dbpm",
                              (int)round(r + [self.heartRateMinTextField.text floatValue])];
            v.heartRateLabel.attributedText = [self formatBPMField:text];
            i++;
        }
    }
}

- (NSMutableAttributedString *)formatBPMField:(NSString *)text {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Thin" size:14.0] range:NSMakeRange(text.length-3, 3)];
    return attributedString;
}


@end
