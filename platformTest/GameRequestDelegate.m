//
//  GameRequestController.m
//  platformTest
//
//  Created by Pu Guannan on 4/9/15.
//  Copyright (c) 2015 Pu Guannan. All rights reserved.
//

#import "GameRequestDelegate.h"


@implementation GameRequestDelegate

-(void) gameRequestDialog:(FBSDKGameRequestDialog *)gameRequestDialog didCompleteWithResults:(NSDictionary *)results
{
    NSLog(@"didCompleteWithResults");
}

-(void) gameRequestDialog:(FBSDKGameRequestDialog *)gameRequestDialog didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError");
}

-(void) gameRequestDialogDidCancel:(FBSDKGameRequestDialog *)gameRequestDialog
{
    NSLog(@"gameRequestDialogDidCancel");
}

@end
