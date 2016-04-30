//
//  SharingDelegate.m
//  platformTest
//
//  Created by Pu Guannan on 4/14/15.
//  Copyright (c) 2015 Pu Guannan. All rights reserved.
//

#import "PFTSharingDelegate.h"

@implementation PFTSharingDelegate

-(void) sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results
{
    FBSDKShareLinkContent *content = [sharer shareContent];
    NSLog(@"share complete %@", content.contentURL);
    NSLog(@"share ref %@", content.ref);
    NSLog(@"res %zd", results.count);
}

-(void) sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error
{
    NSLog(@"share error: %@", [error description]);
}

-(void) sharerDidCancel:(id<FBSDKSharing>)sharer
{
    NSLog(@"share cancel");
}

@end
