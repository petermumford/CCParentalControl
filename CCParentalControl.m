//
//  CCParentalControl.m
//  Myro
//
//  Created by Peter Mumford on 25/11/2013.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "CCParentalControl.h"
#import "Sounds.h"
#import "NSMutableArray+shuffling.h"


#define kDialogTag 1234
#define kDialogMenuTag 4321
#define kWaitingTime 3
#define kNumberOfItems 4

#define menuPadding 25
#define titleTextY 140
#define menuItemsY 10
#define descriptionTextY 100
// class that implements a black colored layer that will cover the whole screen
// and eats all touches except within the dialog box child
@interface ParentalCoverLayer : CCLayerColor {
}
@end
@implementation ParentalCoverLayer
- (id)init {
	self = [super init];
	if (self) {
		[self initWithColor:ccc4(0,0,0,0)
									width:[CCDirector sharedDirector].winSize.width
								 height:[CCDirector sharedDirector].winSize.height];
		self.touchEnabled = YES;
	}
	return self;
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
	CGPoint touchLocation = [self convertTouchToNodeSpace: touch];
	CCNode *dialogBox = [self getChildByTag: kDialogTag];
	CCMenu *menu = (CCMenu*)[self getChildByTag:kDialogMenuTag];
	CGRect menuRect = CGRectMake(menu.position.x, menu.position.y, menu.contentSize.width, menu.contentSize.height);
	
	if (CGRectContainsPoint(menuRect, touchLocation))
		return NO;
	
	return (!CGRectContainsPoint(dialogBox.boundingBox, touchLocation));
}

-(void)registerWithTouchDispatcher
{
	CCTouchDispatcher *dispatcher = [[CCDirector sharedDirector] touchDispatcher];
	
	[dispatcher addTargetedDelegate: self
												 priority: INT_MIN+1
									swallowsTouches: YES];
}

-(void)dealloc
{
	[super dealloc];
}

@end




@implementation CCParentalControl

@synthesize delegate;
@synthesize coverLayer, dialog;
@synthesize titleText, descriptionText, resultText, menuItems;
@synthesize parentalArr;

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
//	release objects here before super
	[coverLayer release];
	[dialog release];
	
	[super dealloc];
}

-(void)loadUIGraphcs
{
//	NSString *UIPlist= @"Media/BookResources/UI/ui.plist";
	CCSpriteFrameCache* frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
	[frameCache addSpriteFramesWithFile:GetFullPath(spriteSheet)];
}
-(void)removeUIGraphcs
{
	CCSpriteFrameCache* frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
	[frameCache removeSpriteFramesFromFile:GetFullPath(spriteSheet)];
}





-(id)initShowParentalControlOnLayer:(CCLayer *)layer sprite:(NSString*)spriteSheetStr urlLocation:(NSString*)urlStr
{
	if((self=[super init]))
	{
		parentPassedTest=NO;
		remainingAttempts=3;
		counter=0;
		
		spriteSheet = spriteSheetStr;
		returnURL = urlStr;
		[self loadUIGraphcs];
		
		NSDictionary *parentalDict = [[[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ParentalControl" ofType:@"plist"]] autorelease];
		self.parentalArr = [[[NSMutableArray alloc] initWithArray:[parentalDict objectForKey:@"items"]] autorelease];
		[self.parentalArr shuffleArray];
		
		self.coverLayer = [[ParentalCoverLayer new] autorelease]; // create the cover layer that "hides" the application in the background
		[layer addChild:coverLayer z:INT_MAX-1]; // put to the very top to block application touches
		[self.coverLayer runAction:[CCFadeTo actionWithDuration:OBJECTSFADEDURATION opacity:200]]; // smooth fade-in to dim with semi-transparency

		CCMenuItemImage *closeBtn = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"parental-close.png"] selectedSprite:nil block:^(id sender) {
			if (![[BookData sharedData] returnIsSubMenuShowing])
			{
				[self closeParentalControl];
			}
		}];
		closeBtn.anchorPoint = ccp(0,0);

		CCMenu *menu = [CCMenu menuWithItems:closeBtn, nil];
		[menu setTag:kDialogMenuTag];
		[menu setContentSize:CGSizeMake(closeBtn.contentSize.width, closeBtn.contentSize.height)];
		menu.position = ccp(([CCDirector sharedDirector].winSize.width-closeBtn.contentSize.width)-[[BookData sharedData] halfIphone5],[CCDirector sharedDirector].winSize.height-closeBtn.contentSize.height);
		[self.coverLayer addChild:menu];
		
		self.dialog = [CCSprite spriteWithSpriteFrameName:@"parental-background.png"];
		self.dialog.tag = kDialogTag;
		self.dialog.position = ccp(self.coverLayer.contentSize.width/2, self.coverLayer.contentSize.height/2);
		self.dialog.scale = 0;
		
		[self setupScreen];
		
		[self.coverLayer addChild:self.dialog];
		[dialog runAction:[CCEaseBackOut actionWithAction:[CCScaleTo actionWithDuration:OBJECTSFADEDURATION scale:1.0]]];
	}
	return self;
}

-(void)setupScreen
{
	randomlySelectedItem = arc4random() % 4;
	
	NSString *title = [NSString string];
	if (remainingAttempts == 3)
		title = @"Are you a grown up?";
	else
		title = [NSString stringWithFormat:@"You have %@ goes remaining...", [self convertNumberToWords:remainingAttempts], nil];
	
	self.titleText = [CCLabelTTF labelWithString:title fontName:@"Verdana" fontSize:FONTSIZEIPAD];
	[self.titleText setColor:ccBLACK];
	[self.titleText setPosition:ccp(self.dialog.contentSize.width/2, (self.dialog.contentSize.height-titleTextY) )];
	[self.dialog addChild:self.titleText];
	
	NSMutableArray *selectedItemsArr = [[[NSMutableArray alloc] init] autorelease];
	for (int i=0; i<4; i++)
	{
		NSDictionary *dict = [[[NSDictionary alloc] initWithDictionary:[self.parentalArr objectAtIndex:i]] autorelease];
		NSString *image = [NSString stringWithFormat:@"%@", [dict objectForKey:@"filename"], nil];
		
		CCMenuItemImageWithTouches *menuItem = [CCMenuItemImageWithTouches itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:image] selectedSprite:nil target:self selector:@selector(selectedMenuItem:)];
		[menuItem setTag:i];
		
		[selectedItemsArr addObject:menuItem];
	}
	self.menuItems = [CCMenu menuWithArray:selectedItemsArr];
	[self.menuItems alignItemsHorizontallyWithPadding:menuPadding];
	self.menuItems.position = ccp( self.dialog.contentSize.width/2, ( self.dialog.contentSize.height/2 + menuItemsY ) );
	[self.menuItems glowItems];
	[self.menuItems setTouchEnabled:YES];
	[self.dialog addChild:self.menuItems];
	
	NSDictionary *selectedDict = [[[NSDictionary alloc] initWithDictionary:[self.parentalArr objectAtIndex:randomlySelectedItem]] autorelease];
	NSString *selectedName = [NSString stringWithFormat:@"%@", [selectedDict objectForKey:@"name"], nil];
	self.descriptionText = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Touch %@ \nfor 2 seconds...", selectedName, nil] fontName:@"Verdana" fontSize:FONTSIZEIPAD dimensions:CGSizeMake(0, 0) hAlignment:UITextAlignmentCenter];
	[self.descriptionText setColor:ccBLACK];
	[self.descriptionText setPosition:ccp( self.dialog.contentSize.width/2, (self.dialog.contentSize.height/2-descriptionTextY) )];
	[self.dialog addChild:self.descriptionText];
}

-(void)selectedMenuItem:(id)sender
{
	CCMenuItemImageWithTouches *selMenuItem = (CCMenuItemImageWithTouches*)sender;
	
	if (selMenuItem.didTimeOut)
	{
		[self.titleText runAction:[CCFadeOut actionWithDuration:OBJECTSFADEDURATION]];
		[self.descriptionText runAction:[CCFadeOut actionWithDuration:OBJECTSFADEDURATION]];
		
		[self.menuItems removeGlowItems];
		[self.menuItems setEnabled:NO];
		
		CCMenuItemImageWithTouches *item;
		CCARRAY_FOREACH(self.menuItems.children, item)
		{
			if (item.tag != selMenuItem.tag)
			{
				[item runAction:[CCSequence actions:
												 [CCDelayTime actionWithDuration:0.2 * (arc4random()%[self.menuItems.children count])],
												 [CCEaseBackIn actionWithAction:[CCScaleTo actionWithDuration:OBJECTSFADEDURATION scale:0]],
												 [CCCallBlock actionWithBlock:^{
														[self.menuItems removeChild:item cleanup:YES];
													}],
												 [CCCallFunc actionWithTarget:self selector:@selector(reAlignMenuItems:)],
												 nil]];
			}
		}
	}
}

-(void)reAlignMenuItems:(id)sender
{
	if (counter == 2)
	{
		[self.menuItems alignItemsHorizontallyWithPadding:menuPadding];
		[self showResults];
	}
	counter++;
}

-(void)showResults
{
	CCMenuItemImageWithTouches *selectedItem = [self.menuItems.children objectAtIndex:0];
	
	if (selectedItem.tag == randomlySelectedItem)
	{
		parentPassedTest = YES;
		self.resultText = [CCSprite spriteWithSpriteFrameName:@"parental-well-done.png"];
		[self.resultText setPosition:ccp( self.dialog.contentSize.width/2, (self.dialog.contentSize.height-titleTextY) )];
		[self.resultText setOpacity:0];
		[self.dialog addChild:self.resultText];
		
		[self.resultText runAction:[CCFadeIn actionWithDuration:OBJECTSFADEDURATION]];
		
		[self performSelector:@selector(closeParentalControl) withObject:nil afterDelay:kWaitingTime];
	}
	else
	{
		remainingAttempts--;
		
		if (remainingAttempts > 0)
			self.resultText = [CCSprite spriteWithSpriteFrameName:@"parental-try-again.png"];
		else
			self.resultText = [CCSprite spriteWithSpriteFrameName:@"parental-bad-luck.png"];
		
		[self.resultText setPosition:ccp( self.dialog.contentSize.width/2, (self.dialog.contentSize.height-titleTextY) )];
		[self.resultText setOpacity:0];
		[self.dialog addChild:self.resultText];
		
		[self.resultText runAction:[CCFadeIn actionWithDuration:OBJECTSFADEDURATION]];
		
		[self performSelector:@selector(tryAgain:) withObject:nil afterDelay:kWaitingTime];
	}
}

-(void)tryAgain:(id)sender
{
	if (remainingAttempts > 0)
	{
		counter=0;
		[self.dialog removeChild:self.titleText cleanup:YES];
		[self.dialog removeChild:self.descriptionText cleanup:YES];
		[self.dialog removeChild:self.menuItems cleanup:YES];
		[self.dialog removeChild:self.resultText cleanup:YES];
		[self setupScreen];
	}
	else
		[self closeParentalControl];
}

-(NSString*)convertNumberToWords:(int)number
{
	NSString *returnStr = [NSString string];
	if (number == 2)
		returnStr = @"two";
	else if (number == 1)
		returnStr = @"one";
	return returnStr;
}

-(void)closeParentalControl
{
	[[Sounds sharedSounds] playTap];
	
	// A Little Hack - strange but it works!
	[UIApplication sharedApplication].idleTimerDisabled = YES;
	[UIApplication sharedApplication].idleTimerDisabled = NO;
	
	// in parallel, fadeout and remove self.coverLayer, self.dialog and then execute block
	[self.dialog runAction:[CCSequence actions:
										 [CCEaseBackIn actionWithAction:[CCScaleTo actionWithDuration:OBJECTSFADEDURATION scale:0.0]],
										 [CCCallBlock actionWithBlock:^{
												[self.dialog removeFromParentAndCleanup:YES];
											}],
										 nil]];
	// (note: you can't use CCFadeOut since we don't start at opacity 1!)
	[self.coverLayer runAction:[CCSequence actions:
								 [CCFadeTo actionWithDuration:OBJECTSFADEDURATION opacity:0],
								 [CCCallBlock actionWithBlock:^{
										[self.coverLayer removeFromParentAndCleanup:YES];
										[self removeUIGraphcs];
										[[CCDirector sharedDirector] purgeCachedData];
										[delegate closedParentalControlWithResult:parentPassedTest urlLocation:returnURL];
									}],
								 nil]];
}




+(id)showParentalControl:(CCLayer *)layer sprite:(NSString*)spriteSheetStr urlLocation:(NSString*)urlStr
{
	return [[[self alloc]initShowParentalControlOnLayer:(CCLayer *)layer sprite:(NSString*)spriteSheetStr urlLocation:(NSString*)urlStr]autorelease];
}

@end
