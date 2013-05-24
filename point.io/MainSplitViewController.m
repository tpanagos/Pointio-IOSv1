//
//  MainSplitViewController.m
//  point.io
//
//  Created by Constantin Lungu on 5/23/13.
//  Copyright (c) 2013 FusionWorks. All rights reserved.
//

#import "MainSplitViewController.h"

@implementation MainSplitViewController

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    if ( [(NSString*)[UIDevice currentDevice].model isEqualToString:@"iPad"] ) {
//        return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
//        return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
    } else {
        if(toInterfaceOrientation == UIInterfaceOrientationPortrait){
            return YES;
        } else {
            return NO;
        }
    }
}

- (void) viewDidLoad{
        
}

@end
