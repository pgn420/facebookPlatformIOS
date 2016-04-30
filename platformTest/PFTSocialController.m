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
#import <AccountKit/AccountKit.h>

@interface PFTSocialController () <AKFViewControllerDelegate, AKFAccountPreferencesDelegate>
@property (nonatomic) bool playerLoggedIn;
@property (nonatomic, strong) UIImage *selectedPhoto;
@end

@implementation PFTSocialController
{
    NSString *_lastSegueIdentifier;
    NSArray *_selectedFriends;
    
    //account kit
    AKFAccountKit *_accountKit;
    UIViewController<AKFViewController> *_pendingLoginViewController;
    NSString *_authorizationCode;
    
    //account kit preference
    AKFAccountPreferences *_accountKitPrefs;
    NSMutableDictionary<NSString *, NSString *> *_preferences;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"FirstViewController viewDidLoad");
    
    [self createLikeButton];
    [self createShareButton];
    
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
    
    // initialize Account Kit
    if (_accountKit == nil) {
        // may also specify AKFResponseTypeAccessToken
        _accountKit = [[AKFAccountKit alloc] initWithResponseType:AKFResponseTypeAccessToken];
    }
    
    // view controller for resuming login
    _pendingLoginViewController = [_accountKit viewControllerForLoginResume];
    
    //_accountKitPrefs = [_accountKit accountPreferences];
    //_accountKitPrefs.delegate = self;
    
    if ([_accountKit currentAccessToken]) {
        NSLog(@"Found existing account kit token %@", [_accountKit currentAccessToken].tokenString);
        NSLog(@"account kit USER ID %@", [_accountKit currentAccessToken].accountID);
        [self.smsLoginButton setTitle:@"SMS Logout" forState:UIControlStateNormal];
        
        _accountKitPrefs = [_accountKit accountPreferences];
        _accountKitPrefs.delegate = self;
        [_accountKitPrefs loadPreferences];
        //NSString *value = [_accountKitPrefs loadPreferenceForKey:@"pgn"];
    }
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
    button.objectID = @"https://www.facebook.com/duapps";
    button.likeControlAuxiliaryPosition = FBSDKLikeControlAuxiliaryPositionBottom;
    button.likeControlStyle = FBSDKLikeControlStyleBoxCount;
    button.center = CGPointMake(rect.size.width / 2.0, rect.size.height - 100);
    [self.view addSubview:button];
}

- (void)createShareButton
{
    CGRect rect = self.view.bounds;
    FBSDKShareButton *button = [[FBSDKShareButton alloc] init];
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    content.contentTitle = @"Fbrell";
    content.contentURL = [NSURL URLWithString:@"https://www.fbrell.com"];
    button.shareContent = content;
    button.center = CGPointMake(rect.size.width / 2.0, rect.size.height - 150);
    
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

#pragma mark - AKFAccountPreferencesDelegate

- (void)accountPreferences:(AKFAccountPreferences *)accountPreferences
        didLoadPreferences:(nullable NSDictionary<NSString *, NSString *> *)preferences
                     error:(nullable NSError *)error
{
    if (error) {
        // ... respond to the error appropriately ...
        return;
    }
    
    NSLog(@"AK Prefs Load ALL success!");
    _preferences = [preferences mutableCopy];
    for (NSString *key in _preferences) {
        NSString *value = _preferences[key];
        NSLog(@"%@ : %@", key, value);
    }
}

- (void)accountPreferences:(AKFAccountPreferences *)accountPreferences
   didLoadPreferenceForKey:(NSString *)key
                     value:(nullable NSString *)value
                     error:(nullable NSError *)error
{
    if (error) {
        // ... respond to the error appropriately ...
        return;
    }
    NSLog(@"AK Prefs Load success! %@ : %@", key, value);
    _preferences[key] = value;
}

- (void)accountPreferences:(AKFAccountPreferences *)accountPreferences
    didSetPreferenceForKey:(NSString *)key
                     value:(NSString *)value
                     error:(nullable NSError *)error
{
    if (error) {
        // ... respond to the error appropriately ...
        return;
    }
    NSLog(@"AK Prefs Set success! %@ : %@", key, value);
    _preferences[key] = value;
}

- (void)accountPreferences:(AKFAccountPreferences *)accountPreferences
 didDeletePreferenceForKey:(NSString *)key
                     error:(nullable NSError *)error

{
    if (error) {
        // ... respond to the error appropriately ...
        return;
    }
    NSLog(@"AK Prefs Delete success! %@ ", key);
    [_preferences removeObjectForKey:key];
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

- (IBAction)smsLogin:(id)sender
{
    if (![_accountKit currentAccessToken])
    {
        //NSString *preFillPhoneNumber = @"!";
        NSString *inputState = [[NSUUID UUID] UUIDString];
        UIViewController<AKFViewController> *viewController = [_accountKit viewControllerForPhoneLoginWithPhoneNumber:nil state:inputState];
        viewController.enableSendToFacebook = YES; // defaults to NO
        [self _prepareLoginViewController:viewController]; // see below
        [self presentViewController:viewController animated:YES completion:NULL];
    }
    else
    {
        [_accountKit logOut];
        [self.smsLoginButton setTitle:@"SMS Login" forState:UIControlStateNormal];
    }
}

- (void)_prepareLoginViewController:(UIViewController<AKFViewController> *)loginViewController
{
    loginViewController.delegate = self;
    // Optionally, you may use the Advanced UI Manager or set a theme to customize the UI.
    //loginViewController.advancedUIManager = _advancedUIManager;
    //loginViewController.theme = [Themes bicycleTheme];
}

- (void) viewController:(UIViewController<AKFViewController> *)viewController
didCompleteLoginWithAccessToken:(id<AKFAccessToken>)accessToken
                  state:(NSString *)state
{
    NSLog(@"AK token: %@", [accessToken tokenString]);
    NSLog(@"AK UserID: %@", [accessToken accountID]);
    
    [self.smsLoginButton setTitle:@"SMS Logout" forState:UIControlStateNormal];
    
    _accountKitPrefs = [_accountKit accountPreferences];
    _accountKitPrefs.delegate = self;
    
    [_accountKitPrefs setPreferenceForKey:@"pgn" value:@"LOL"];
}

- (void)viewController:(UIViewController<AKFViewController> *)viewController didFailWithError:(NSError *)error
{
    // ... implement appropriate error handling ...
    NSLog(@"%@ did fail with error: %@", viewController, error);
}

- (void)viewControllerDidCancel:(UIViewController<AKFViewController> *)viewController
{
    // ... handle user cancellation of the login process ...
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

    
    /*
    FBSDKGameRequestDialog *gameDialog = [[FBSDKGameRequestDialog alloc]init];
    gameDialog.content = content;
    gameDialog.frictionlessRequestsEnabled = YES;
    
    gameDialog.delegate = self.gameRequestDelegate;
    if ([gameDialog canShow]) {
        [gameDialog show];
    }
     */
    
    FBSDKGameRequestContent *content = [[FBSDKGameRequestContent alloc]init];
    content.message = @"Great FB";
    content.filters = FBSDKGameRequestFilterAppNonUsers;
    content.title = @"Invite Friends";
    
    [FBSDKGameRequestDialog showWithContent:content delegate:self.gameRequestDelegate];
}

// @todo, set a specifier here to callback can identify the sender story id
-(IBAction)shareStory:(id)sender
{
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    content.contentTitle = @"Fbrell";
    content.contentURL = [NSURL URLWithString:@"https://www.fbrell.com"];
    content.ref = @"Sharelink";
    
    FBSDKShareDialog *dialog = [[FBSDKShareDialog alloc] init];
    dialog.mode = FBSDKShareDialogModeAutomatic;
    dialog.shareContent = content;
    dialog.fromViewController = self;
    [dialog show];
    //[FBSDKShareDialog showFromViewController:self  withContent:content delegate:self.sharingDelegate];
    
    /*
    NSString *textToShare = @"your text";
    UIImage *imageToShare = [UIImage imageNamed:@"yourImage.png"];
    NSArray *itemsToShare = @[textToShare];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
    activityVC.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll]; //or whichever you don't need
    [self presentViewController:activityVC animated:YES completion:nil];
     */
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
