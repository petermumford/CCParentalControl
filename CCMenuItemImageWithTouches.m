//
//  CCMenuItemImageWithTouches.m
//  Myro
//
//  Created by Peter Mumford on 25/11/2013.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "CCMenuItemImageWithTouches.h"

@implementation CCMenuItemImageWithTouches

@synthesize didTimeOut;

-(void) selected
{
	[super selected];
	
	float timeout = 2.0;
	[self schedule:@selector(showAnswer:) interval:timeout];
}


-(void) unselected
{
	[super unselected];
	
	didTimeOut = NO;
	[self unschedule:@selector(showAnswer:)];
}

-(void)showAnswer:(id)sender
{
	didTimeOut = YES;
	[self activate];
}

@end
