//
//  SecondViewController.m
//  platformTest
//
//  Created by Pu Guannan on 4/7/15.
//  Copyright (c) 2015 Pu Guannan. All rights reserved.
//

#import "AppEventsController.h"
#import "PickerViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface AppEventsController ()
@property (nonatomic, strong) IBOutlet UILabel *tutorialLabel;
@property (nonatomic, strong) IBOutlet UILabel *levelLabel;
@property (nonatomic, strong) IBOutlet UITextField *eventParamNameTextField;
@property (nonatomic, strong) IBOutlet UITextField *eventParamValueTextField;
@property (nonatomic, strong) IBOutlet UITextField *eventNameTextField;
@property (nonatomic, strong) IBOutlet UISlider *eventValueSlider;
@end

@implementation AppEventsController
{
    NSString *_lastSegueIdentifier;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)tutorialEvent:(id)sender
{
    NSDictionary *properties = @{@"Tutorial Step": _tutorialLabel.text};
    [FBSDKAppEvents logEvent:FBSDKAppEventNameCompletedTutorial parameters:properties];
}

- (IBAction)tutorialSliderChanged:(id)sender
{
    UISlider *slider = sender;
    _tutorialLabel.text = [NSString stringWithFormat:@"%d", (int)slider.value];
}

- (IBAction)levelSliderChanged:(id)sender
{
    UISlider *slider = sender;
    _levelLabel.text = [NSString stringWithFormat:@"%d", (int)slider.value];
}

- (IBAction)levelEvent:(id)sender
{
    NSDictionary *properties = @{FBSDKAppEventParameterNameLevel: _levelLabel.text};
    [FBSDKAppEvents logEvent:FBSDKAppEventNameAchievedLevel parameters:properties];
}

- (IBAction)customEvent:(id)sender
{
    NSDictionary *properties = @{_eventParamNameTextField.text: _eventParamValueTextField.text};
    [FBSDKAppEvents logEvent:_eventNameTextField.text valueToSum:_eventValueSlider.value parameters:properties];
}

- (IBAction)showAppEventsDialog:(UIStoryboardSegue *)segue
{
    NSString *identifier = segue.identifier;
    
    PickerViewController *vc = segue.sourceViewController;
    NSDictionary *selectedContent = [vc getSelectedContent];
    NSMutableDictionary *properties = [selectedContent mutableCopy];
    [properties removeObjectForKey:@"Text"];
    
    if ([_lastSegueIdentifier isEqualToString:@"showPurchase"])
    {
        double value = [[properties valueForKey:@"Value"] doubleValue];
        [properties removeObjectForKey:@"Value"];
        
        [FBSDKAppEvents logEvent:FBSDKAppEventNameInitiatedCheckout valueToSum:value parameters:properties];
        
        if ([identifier isEqualToString:@"exitFromCancel"])
        {
            // log purchase cancel
            [FBSDKAppEvents logEvent:@"fb_mobile_purchase_failed" valueToSum:value parameters:properties];
            return;
        }
        else
        {
            NSString *currency = [properties valueForKey:FBSDKAppEventParameterNameCurrency];
            [properties removeObjectForKey:FBSDKAppEventParameterNameCurrency];
            [FBSDKAppEvents logPurchase:value currency:currency parameters:properties];
        }
        
        return;
    }
    
    if ([_lastSegueIdentifier isEqualToString:@"showRegistration"]) {
        [FBSDKAppEvents logEvent:FBSDKAppEventNameCompletedRegistration parameters:properties];
    }
    else if ([_lastSegueIdentifier isEqualToString:@"showAchievement"])
    {
        [FBSDKAppEvents logEvent:FBSDKAppEventNameUnlockedAchievement parameters:properties];
    }
    else if ([_lastSegueIdentifier isEqualToString:@"showSpendCredits"])
    {
        double value = [[properties valueForKey:@"Value"] doubleValue];
        [properties removeObjectForKey:@"Value"];
        [FBSDKAppEvents logEvent:FBSDKAppEventNameSpentCredits valueToSum:value parameters:properties];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    PickerViewController *vc = segue.destinationViewController;
    _lastSegueIdentifier = segue.identifier;
    if ([_lastSegueIdentifier isEqualToString:@"showRegistration"]) {
        vc.content = @[@{FBSDKAppEventParameterNameRegistrationMethod: @"Facebook",
                         @"Text": @"Facebook"},
                       @{FBSDKAppEventParameterNameRegistrationMethod: @"Google Play",
                         @"Text": @"Google Play"},
                       @{FBSDKAppEventParameterNameRegistrationMethod: @"Google+",
                         @"Text": @"Google+"},
                       @{FBSDKAppEventParameterNameRegistrationMethod: @"Amazon",
                         @"Text": @"Amazon"},
                       @{FBSDKAppEventParameterNameRegistrationMethod: @"App Store",
                         @"Text": @"App Store"},
                       @{FBSDKAppEventParameterNameRegistrationMethod: @"Email",
                         @"Text": @"Email"},
                       @{FBSDKAppEventParameterNameRegistrationMethod: @"Twitter",
                         @"Text": @"Twitter"}];
    }
    else if ([_lastSegueIdentifier isEqualToString:@"showAchievement"]) {
        vc.content = @[@{FBSDKAppEventParameterNameContentID: @"1001",
                         FBSDKAppEventParameterNameDescription: @"Killed Boss Dragon",
                         @"Text": @"Killed Boss Dragon"},
                       @{FBSDKAppEventParameterNameContentID: @"1002",
                         FBSDKAppEventParameterNameDescription: @"Have five builders",
                         @"Text": @"Have five builders"},
                       @{FBSDKAppEventParameterNameContentID: @"1003",
                         FBSDKAppEventParameterNameDescription: @"Gather 1000000 gold",
                         @"Text": @"Gather 1000000 gold"},
                       @{FBSDKAppEventParameterNameContentID: @"1004",
                         FBSDKAppEventParameterNameDescription: @"Spent 10,000 gems in one day",
                         @"Text": @"Spent 10,000 gems in one day"},
                       @{FBSDKAppEventParameterNameContentID: @"1005",
                         FBSDKAppEventParameterNameDescription: @"Shared an app event",
                         @"Text": @"Shared an app event"},
                       ];
    }
    else if ([_lastSegueIdentifier isEqualToString:@"showPurchase"])
    {
        vc.content = @[@{FBSDKAppEventParameterNameContentID: @"10001",
                         FBSDKAppEventParameterNameDescription: @"100 gems",
                         FBSDKAppEventParameterNameCurrency: @"USD",
                         @"Value":@1.99,
                         @"Text": @"$1.99 for 100 gems"},
                       @{FBSDKAppEventParameterNameContentID: @"10002",
                         FBSDKAppEventParameterNameDescription: @"600 gems",
                         FBSDKAppEventParameterNameCurrency: @"USD",
                         @"Value":@9.99,
                         @"Text": @"$9.99 for 600 gems"},
                       @{FBSDKAppEventParameterNameContentID: @"10003",
                         FBSDKAppEventParameterNameDescription: @"1300 gems",
                         FBSDKAppEventParameterNameCurrency: @"USD",
                         @"Value":@19.99,
                         @"Text": @"$19.99 for 1300 gems"},
                       @{FBSDKAppEventParameterNameContentID: @"10004",
                         FBSDKAppEventParameterNameDescription: @"3500 gems",
                         FBSDKAppEventParameterNameCurrency: @"USD",
                         @"Value":@49.99,
                         @"Text": @"$49.99 for 3500 gems"},
                       @{FBSDKAppEventParameterNameContentID: @"10005",
                         FBSDKAppEventParameterNameDescription: @"7200 gems",
                         FBSDKAppEventParameterNameCurrency: @"USD",
                         @"Value":@99.99,
                         @"Text": @"$99.99 for 7200 gems"},
                       ];
    }
    else if ([_lastSegueIdentifier isEqualToString:@"showSpendCredits"])
    {
        vc.content = @[@{FBSDKAppEventParameterNameContentID: @"20001",
                         FBSDKAppEventParameterNameDescription: @"Green Armor",
                         FBSDKAppEventParameterNameContentType: @"Hard Currency",
                         @"Value":@150,
                         @"Text": @"150 gems for armor"},
                       @{FBSDKAppEventParameterNameContentID: @"20002",
                         FBSDKAppEventParameterNameDescription: @"Lightning Shoe",
                         FBSDKAppEventParameterNameContentType: @"Hard Currency",
                         @"Value":@350,
                         @"Text": @"350 gems for shoe"},
                       @{FBSDKAppEventParameterNameContentID: @"20003",
                         FBSDKAppEventParameterNameDescription: @"Magic Helm",
                         FBSDKAppEventParameterNameContentType: @"Hard Currency",
                         @"Value":@200,
                         @"Text": @"200 gems for armor"},
                       @{FBSDKAppEventParameterNameContentID: @"20004",
                         FBSDKAppEventParameterNameDescription: @"Crystal Sword",
                         FBSDKAppEventParameterNameContentType: @"Hard Currency",
                         @"Value":@900,
                         @"Text": @"900 gems for sword"},
                       @{FBSDKAppEventParameterNameContentID: @"20005",
                         FBSDKAppEventParameterNameDescription: @"Gold Shield",
                         FBSDKAppEventParameterNameContentType: @"Hard Currency",
                         @"Value":@450,
                         @"Text": @"450 gems for shield"},
                       ];
    }
}

@end
