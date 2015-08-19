//
//  FirstViewController.m
//  RunningTools
//
//  Created by jd on 09/08/2015.
//  Copyright (c) 2015 jd. All rights reserved.
//

#import "FirstViewController.h"
#import "JDKeyboardManager.h"

@interface FirstViewController ()

@property (weak, nonatomic) IBOutlet UITextField *inputFormTextField;
@property (weak, nonatomic) IBOutlet UILabel *inputFormUnitsLabel;
@property (weak, nonatomic) IBOutlet UILabel *outputFormUnitsLabel;
@property (weak, nonatomic) IBOutlet UILabel *outputFormValueLabel;

@property (weak, nonatomic) IBOutlet UILabel *timeFor10kmLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeForSemiMarathonLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeForMarathonLabel;
@property (weak, nonatomic) IBOutlet UITextField *customDistanceTextField;
@property (weak, nonatomic) IBOutlet UILabel *timeForCustomDistanceLabel;
@end



@implementation FirstViewController

NSString *curentInputUnits;

NSString *const minPerKilometerUnit = @"min/km";
NSString *const kilometersPerHourUnit = @"km/h";

NSNumberFormatter *ns;


#
#pragma mark Lifecycle
#

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self switchUnits:nil];
    
    ns = [[NSNumberFormatter alloc] init];
    ns.generatesDecimalNumbers = YES;
    
    // Set Scroll view content size to handle scrolling
    ((UIScrollView *)self.view).contentSize = self.view.frame.size;

    // Keyboard event
    [[JDKeyboardManager sharedManager] attachOnView:self.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#
#pragma mark Actions
#

// Happens when user toggle the units
- (IBAction)switchUnits:(id)sender {
    if([curentInputUnits isEqualToString:kilometersPerHourUnit]) {
        curentInputUnits = minPerKilometerUnit;
        self.inputFormTextField.placeholder = @"mm:ss";
        self.inputFormTextField.keyboardType = UIKeyboardTypeNumberPad;
        self.inputFormUnitsLabel.text = minPerKilometerUnit;
        self.outputFormUnitsLabel.text = kilometersPerHourUnit;
        self.inputFormTextField.text = @"";
        self.outputFormValueLabel.text = @"0";
    }
    else {
        curentInputUnits = kilometersPerHourUnit;
        self.inputFormTextField.placeholder = @"";
        self.inputFormTextField.keyboardType = UIKeyboardTypeDecimalPad;
        self.inputFormUnitsLabel.text = kilometersPerHourUnit;
        self.outputFormUnitsLabel.text = minPerKilometerUnit;
        self.inputFormTextField.text = @"";
        self.outputFormValueLabel.text = @"00:00";
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *actualText = textField.text;
    NSString *newText;
    if ([curentInputUnits isEqualToString:minPerKilometerUnit] && textField == self.inputFormTextField) {

        int inputInt = [string intValue];
                
        // If we're trying to remove colon
        if ([string isEqualToString:@""] && (range.location == 2 || range.location == 3)) {
            textField.text = [textField.text substringToIndex:range.location-1];
            return NO;
        }
        
        // If we're trying to add more than the max amount of characters, don't allow it
        if (actualText.length == 5 && range.location > 4) {
            return NO;
        }
        
        // If we're trying to add seconds greater than 59
        if (range.location == 3 && inputInt > 5) {
            return NO;
        }
        
        // First lets add the whole string we're going for
        newText = [actualText stringByReplacingCharactersInRange:range withString:string];

        // Now remove colon (since we'll add these automatically in a minute)
        newText = [newText stringByReplacingOccurrencesOfString:@":" withString:@""];
        
        // We need to use an NSMutableString to do insertString calls in a moment
        NSMutableString *mutableText = [newText mutableCopy];
        if (newText.length >= 2) {
            [mutableText insertString:@":" atIndex:2];
        }
        
        // Finally, set the textfield to our newly modified string!
        textField.text = mutableText;
    }
    else {
        newText = [actualText stringByReplacingCharactersInRange:range withString:string];
        textField.text = newText;
    }
    [self updateValues];
    return NO;
}


- (void)updateValues {
    if(curentInputUnits == minPerKilometerUnit) {
        // add colon if needed
        if(self.inputFormTextField.text.length == 5) {
            NSArray *parts = [self.inputFormTextField.text componentsSeparatedByString:@":"];
            float minutes = [parts[0] floatValue];
            float seconds = [parts[1] floatValue];
            float decimalMinutes = minutes + seconds/60;
            float kmh = 60 / decimalMinutes;
            self.outputFormValueLabel.text = [NSString stringWithFormat:@"%.2f", kmh];
            [self updateTimesForDistance:kmh];
        }
        else {
            self.outputFormValueLabel.text = @"0";
            [self updateTimesForDistance:0];
        }
    }
    // From km per hour
    else {
        if(![self.inputFormTextField.text isEqualToString:@""] && ![self.inputFormTextField.text isEqualToString:@"0"] ) {
            float kmh = [[ns numberFromString:self.inputFormTextField.text] floatValue];
            self.outputFormValueLabel.text = [self convertKmPerHoursToTimeMinPerKmString:kmh];
            [self updateTimesForDistance:kmh];
        }
        else {
            self.outputFormValueLabel.text = @"00:00";
            [self updateTimesForDistance:0];
        }
    }
}


#
#pragma mark Display helpers
#

- (void)updateTimesForDistance:(float)kmh {
    if (kmh == 0) {
        self.timeFor10kmLabel.text = [self timeFormatted:0];
        self.timeForSemiMarathonLabel.text = [self timeFormatted:0];
        self.timeForMarathonLabel.text = [self timeFormatted:0];
        self.timeForCustomDistanceLabel.text = [self timeFormatted:0];
        return;
    }
    self.timeFor10kmLabel.text = [self timeFormatted:10 / kmh];
    self.timeForSemiMarathonLabel.text = [self timeFormatted:21.097 / kmh];
    self.timeForMarathonLabel.text = [self timeFormatted:42.195 / kmh];
    float km = [[ns numberFromString:self.customDistanceTextField.text] floatValue];
    self.timeForCustomDistanceLabel.text = [self timeFormatted:km / kmh];
}

- (NSString *)convertKmPerHoursToTimeMinPerKmString:(float)kmh {
    if (kmh == 0) {
        return @"00:00";
    }
    float time = 60 / kmh;
    int minutes = floor(time);
    int secondes = round((time - minutes) * 60);
    return [NSString stringWithFormat:@"%02d:%02d", minutes, secondes];
}

- (NSString *)timeFormatted:(float)decimalHours
{
    if (decimalHours == 0) {
        return @"00:00:00";
    }
    int totalSeconds = round(decimalHours*3600);
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    
    return [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
}

@end
