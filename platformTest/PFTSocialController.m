//
//  FirstViewController.m
//  platformTest
//
//  Created by Pu Guannan on 4/7/15.
//  Copyright (c) 2015 Pu Guannan. All rights reserved.
//

#import "PFTSocialController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <FBSDKShareKit/FBSDKGameRequestContent.h>
#include "PFTTableViewPickerController.h"
#include "PFTImageViewController.h"

@interface PFTSocialController ()
@property (nonatomic) bool playerLoggedIn;
@property (nonatomic, strong) UIImage *selectedPhoto;
@end

@implementation PFTSocialController
{
    NSString *_lastSegueIdentifier;
    NSArray *_selectedFriends;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"FirstViewController viewDidLoad");
    
    [self createLikeButton];
    
    _loginManager = [[FBSDKLoginManager alloc] init];
    _gameRequestDelegate = [[PFTGameRequestDelegate alloc] init];
    _sharingDelegate = [[PFTSharingDelegate alloc] init];
    _appInviteDialogDelegate = [[PFTAppInviteDialogDelegate alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(observeProfileChange:) name:FBSDKProfileDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(observeTokenChange:) name:FBSDKAccessTokenDidChangeNotification object:nil];
    
    self.loginButton.readPermissions = @[@"public_profile", @"email", @"user_friends"];
    // Do any additional setup after loading the view, typically from a nib.
    // If there's already a cached token, read the profile information.
    if ([FBSDKAccessToken currentAccessToken]) {
        [self observeProfileChange:nil];
        NSLog(@"Found existing token %@", [FBSDKAccessToken currentAccessToken].tokenString);
    }
    
    _profilePictureView.profileID = @"me";
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createLikeButton
{
    CGRect rect = self.view.bounds;
    FBSDKLikeControl *button = [[FBSDKLikeControl alloc] init];
    button.objectID = @"https://www.facebook.com/DotArenaFunplus";
    button.likeControlAuxiliaryPosition = FBSDKLikeControlAuxiliaryPositionBottom;
    button.likeControlStyle = FBSDKLikeControlStyleBoxCount;
    button.center = CGPointMake(rect.size.width / 2.0, rect.size.height - 100);
    [self.view addSubview:button];
}

- (void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error {
    if (error) {
        NSLog(@"Unexpected login error: %@", error);
    } else {
        NSLog(@"Logged in");
    }
}

- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton {

}

#pragma mark - Observations

- (void)observeProfileChange:(NSNotification *)notfication {
    if ([FBSDKProfile currentProfile]) {
        [self.customLoginButton setTitle:@"Logout" forState:UIControlStateNormal];
    }
    [self updateProfile];
}

- (void)observeTokenChange:(NSNotification *)notfication {
    if (![FBSDKAccessToken currentAccessToken]) {
        [self.customLoginButton setTitle:@"Login" forState:UIControlStateNormal];
    } else {
        [self observeProfileChange:nil];
    }
    [self updateProfile];
}

- (void) updateProfile
{
    if ([FBSDKProfile currentProfile]) {
        _profileName.text = [FBSDKProfile currentProfile].name;
    }
    else {
        _profileName.text = @"";
    }
}

- (IBAction)customLogin:(id)sender
{
    if (![FBSDKAccessToken currentAccessToken])
    {
        [self.loginManager logInWithReadPermissions:@[@"public_profile", @"user_friends", @"email"] fromViewController:self handler:^(FBSDKLoginManagerLoginResult *result, NSError *error){
        
        }];
    }
    else
    {
        [self.loginManager logOut];
    }
}

- (IBAction)getPublishAction:(id)sender
{
    NSLog(@"getPublishAction");
    if ([FBSDKAccessToken currentAccessToken])
    {
        [self.loginManager logInWithPublishPermissions:@[@"publish_actions"] fromViewController:self handler:^(FBSDKLoginManagerLoginResult *result, NSError *error){
            
        }];
    }
    else {
        NSLog(@"User has not logged in");
    }
}

- (IBAction)gameRequest:(id)sender
{
    NSLog(@"gameRequest");
    FBSDKGameRequestContent *content = [[FBSDKGameRequestContent alloc]init];
    content.message = @"Great FB";
    content.filters = FBSDKGameRequestFilterAppNonUsers;
    content.title = @"Invite Friends";
    
    /*
    FBSDKGameRequestDialog *gameDialog = [[FBSDKGameRequestDialog alloc]init];
    gameDialog.content = content;
    gameDialog.frictionlessRequestsEnabled = YES;
    
    gameDialog.delegate = self.gameRequestDelegate;
    if ([gameDialog canShow]) {
        [gameDialog show];
    }
     */
    
    [FBSDKGameRequestDialog showWithContent:content delegate:self.gameRequestDelegate];
}

// @todo, set a specifier here to callback can identify the sender story id
-(IBAction)shareStory:(id)sender
{
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    content.imageURL = [NSURL URLWithString:@"https://platformtest.herokuapp.com/1200630.jpg"];
    content.contentTitle = @"Test";
    content.contentURL =[NSURL URLWithString: @"https://platformtest.herokuapp.com/1200630.html"];
    //content.contentURL = [NSURL URLWithString:@"https://youtu.be/C8zEMHmYLyU"];
    
    content.ref = @"Sharelink";
    
    [FBSDKShareDialog showFromViewController:self withContent:content delegate:self.sharingDelegate];
}

-(IBAction)appInvite:(id)sender
{
    NSURL* url = [NSURL URLWithString:@"https://platformtest.herokuapp.com/applinks.html"];
    FBSDKAppInviteContent *inviteContent = [[FBSDKAppInviteContent alloc] init];
    inviteContent.appInvitePreviewImageURL = [NSURL URLWithString:@"https://platformtest.herokuapp.com/1200630.jpg"];
    inviteContent.appLinkURL = url;
    [FBSDKAppInviteDialog showFromViewController:self withContent:inviteContent delegate:self.appInviteDialogDelegate];
}

-(IBAction)shareStoryAPI:(id)sender
{
    if ([[FBSDKAccessToken currentAccessToken] hasGranted:@"publish_actions"]) {
    
        FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
        content.imageURL = [NSURL URLWithString:@"https://platformtest.herokuapp.com/1200630.jpg"];
        content.contentTitle = @"Test";
        content.contentURL =[NSURL URLWithString: @"https://platformtest.herokuapp.com/1200630.html"];
        content.ref = @"Sharelink";
    
        [FBSDKShareAPI shareWithContent:content delegate:self.sharingDelegate];
    }
}

- (IBAction)sendMessage:(id)sender
{
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    content.imageURL = [NSURL URLWithString:@"https://platformtest.herokuapp.com/1200630.jpg"];
    content.contentTitle = @"Test";
    content.contentURL =[NSURL URLWithString: @"https://platformtest.herokuapp.com/applinks.html"];
    
    [FBSDKMessageDialog showWithContent:content delegate:_sharingDelegate];
}

- (IBAction)likeOG:(id)sender
{
    if ([[FBSDKAccessToken currentAccessToken] hasGranted:@"publish_actions"]) {
        [[[FBSDKGraphRequest alloc]
          initWithGraphPath:@"me/og.likes"
          parameters: @{ @"object" : @"https://platformtest.herokuapp.com/1200630.html"}
          HTTPMethod:@"POST"]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 NSLog(@"Post id:%@", result[@"id"]);
             }
         }];
    }
}

- (IBAction)shareOG:(id)sender
{
    NSDictionary *properties = @{
                                 @"og:type": @"books:book",
                                 @"og:title": @"A Game of Cakes",
                                 @"og:description": @"In the frozen wastes to the north of Winterfell, sinister and supernatural forces are mustering.",
                                 @"og:url": @"https://platformtest.herokuapp.com/cake1200.html",
                                 @"og:image": @"https://platformtest.herokuapp.com/1200630.jpg",
                                 };
    FBSDKShareOpenGraphObject *object = [FBSDKShareOpenGraphObject objectWithProperties:properties];

    FBSDKShareOpenGraphAction *action = [[FBSDKShareOpenGraphAction alloc] init];
    action.actionType = @"platfom:eat";
    [action setObject:object forKey:@"books:book"];
     
    // Create the content
    FBSDKShareOpenGraphContent *content = [[FBSDKShareOpenGraphContent alloc] init];
    content.action = action;
    content.previewPropertyName = @"books:book";
    content.ref = @"iosogd";
    
    [FBSDKShareDialog showFromViewController:self
                                 withContent:content
                                    delegate:_sharingDelegate];
}

- (IBAction)shareOGAPI:(id)sender
{
    if ([[FBSDKAccessToken currentAccessToken] hasGranted:@"publish_actions"]) {
        NSLog(@"shareOGAPi");
        [[[FBSDKGraphRequest alloc]
          initWithGraphPath:@"me/platfom:eat"
          parameters: @{ @"cake" : @"https://platformtest.herokuapp.com/cake1200.html", @"ref":@"IOSogAPI", @"fb:explicitly_shared": @"true"}
          HTTPMethod:@"POST"]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 NSLog(@"Post id:%@", result[@"id"]);
             }
             else {
                 NSLog(@"error :%@", [error description]);
             }
         }];
    }
}

- (IBAction)showMain:(UIStoryboardSegue *)segue sender:(id) sender
{
    NSString *identifier = segue.identifier;
    
    if ([identifier isEqualToString:@"exitFromCancel"])
    {
        _selectedFriends = nil;
        return;
    }
    
    NSLog(@"showMain ==%@",identifier);
    
    if ([identifier isEqualToString:@"sharePhoto"]) {
        PFTImageViewController *vc = segue.sourceViewController;
        NSArray *images = vc.images;
        if ([images count] == 0) {
            return;
        }
        NSMutableArray* photos = [[NSMutableArray alloc]init];
        for (UIImage *object in images) {
            FBSDKSharePhoto *photo = [[FBSDKSharePhoto alloc] init];
            photo.image = object;
            photo.userGenerated = YES;
            [photos addObject:photo];
        }

        FBSDKSharePhotoContent *content = [[FBSDKSharePhotoContent alloc] init];
        content.photos = photos;
        [FBSDKShareDialog showFromViewController:self.view.window.rootViewController withContent:content delegate:_sharingDelegate];
        return;
    }
       
    PFTTableViewPickerController *vc = segue.sourceViewController;
    _selectedFriends = [vc.selection valueForKeyPath:@"id"];
    if (_selectedFriends.count == 0) {
        _selectedFriends = nil;
        return;
    }
    
    if ([_lastSegueIdentifier isEqualToString:@"showInvitableFriendsPicker"]) {
        NSLog(@"Invite Invitable friends");
        FBSDKGameRequestContent *content = [[FBSDKGameRequestContent alloc]init];
        content.message = @"invitable friends";
        content.title = @"Invitable invite";
        content.recipients = _selectedFriends;
        
        [FBSDKGameRequestDialog showWithContent:content delegate:self.gameRequestDelegate];
    }
    else if ([_lastSegueIdentifier isEqualToString:@"showInGameFriends"]) {
        NSLog(@"In game friends requests");
        FBSDKGameRequestContent *content = [[FBSDKGameRequestContent alloc]init];
        content.message = @"In game friends";
        content.title = @"In game friend request";
        content.recipients = _selectedFriends;
        
        [FBSDKGameRequestDialog showWithContent:content delegate:self.gameRequestDelegate];
    }
    
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // NOTE: for simplicity, we are not paging the results of the request.
    _lastSegueIdentifier = segue.identifier;
    if ([_lastSegueIdentifier isEqualToString:@"showInvitableFriendsPicker"]) {
        PFTTableViewPickerController *vc = segue.destinationViewController;
        vc.requiredPermission = @"user_friends";
        vc.request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me/invitable_friends?limit=100"
                                                       parameters:@{ @"fields" : @"id,name,picture.width(100).height(100)"
                                                                     }];
        vc.allowsMultipleSelection = YES;
    }
    else if ([_lastSegueIdentifier isEqualToString:@"showInGameFriends"]) {
        PFTTableViewPickerController *vc = segue.destinationViewController;
        vc.requiredPermission = @"user_friends";
        vc.request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me/friends?limit=100"
                                                       parameters:@{ @"fields" : @"id,name,picture.width(100).height(100)"
                                                                     }];
        vc.allowsMultipleSelection = YES;
    }
    
    NSLog(@"your seque identifier is ==%@",_lastSegueIdentifier);
}

@end
