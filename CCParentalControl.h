//
//  CCParentalControl.h
//  Myro
//
//  Created by Peter Mumford on 25/11/2013.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "BookData.h"
#import "CCMenuItemImageWithTouches.h"

@protocol CCParentalControlDelegate <NSObject>
	@required
	- (void)closedParentalControlWithResult:(BOOL)passed urlLocation:(NSString*)url;
@end

@interface CCParentalControl : CCLayer {
	id <CCParentalControlDelegate> delegate;
	
	CCLayerColor *coverLayer;
	CCSprite *dialog;
	
	CCLabelTTF *titleText;
	CCLabelTTF *descriptionText;
	CCSprite *resultText;
	CCMenu *menuItems;
	
	NSString *spriteSheet;
	NSString *returnURL;
	
	NSMutableArray *parentalArr;
	
	int randomlySelectedItem;
	int counter;
	int remainingAttempts;
	
	BOOL parentPassedTest;
}

@property (nonatomic, assign) id <CCParentalControlDelegate> delegate;
@property (nonatomic, retain) CCLayerColor *coverLayer;

@property (nonatomic, retain) CCSprite *dialog;
@property (nonatomic, retain) CCLabelTTF *titleText;
@property (nonatomic, retain) CCLabelTTF *descriptionText;
@property (nonatomic, retain) CCSprite *resultText;
@property (nonatomic, retain) CCMenu *menuItems;

@property (nonatomic, retain) NSMutableArray *parentalArr;

+(id)showParentalControl:(CCLayer *)layer sprite:(NSString*)spriteSheetStr urlLocation:(NSString*)urlStr;

@end
