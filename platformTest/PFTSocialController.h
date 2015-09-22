//
//  FirstViewController.h
//  platformTest
//
//  Created by Pu Guannan on 4/7/15.
//  Copyright (c) 2015 Pu Guannan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import "GameRequestDelegate.h"
#import "SharingDelegate.h"
#import "AppInviteDialogDelegate.h"
#import "UiSwipeViewController.h"

@interface PFTSocialController : UiSwipeViewController <FBSDKLoginButtonDelegate>
@property (nonatomic, strong) IBOutlet FBSDKLoginButton *loginButton;
@property (nonatomic, strong) IBOutlet UIButton *customLoginButton;
@property (nonatomic, strong) IBOutlet UIButton *getPublishActionsButton;
@property (nonatomic, strong) IBOutlet FBSDKProfilePictureView *profilePictureView;
@property (nonatomic, strong) IBOutlet UILabel *profileName;
@property (nonatomic, strong) FBSDKLoginManager *loginManager;
@property (nonatomic, strong) GameRequestDelegate<FBSDKGameRequestDialogDelegate> *gameRequestDelegate;
@property (nonatomic, strong) SharingDelegate<FBSDKSharingDelegate> *sharingDelegate;
@property (nonatomic, strong) AppInviteDialogDelegate<FBSDKAppInviteDialogDelegate> *appInviteDialogDelegate;

@end

