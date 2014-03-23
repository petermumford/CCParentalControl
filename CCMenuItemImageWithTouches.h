//
//  CCMenuItemImageWithTouches.h
//  Myro
//
//  Created by Peter Mumford on 25/11/2013.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"

@interface CCMenuItemImageWithTouches : CCMenuItemImage {
  
	BOOL didTimeOut;
	
}

@property (nonatomic, assign) BOOL didTimeOut;

-(void)showAnswer:(id)sender;

@end
