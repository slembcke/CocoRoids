//
//  Ship.m
//  Cocoroids
//
//  Created by Scott Lembcke on 1/19/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "OALSimpleAudio.h"

#import "Ship.h"

// To access some of Chipmunk's handy vector functions like cpvlerpconst().
#import "ObjectiveChipmunk/ObjectiveChipmunk.h"

// TODO
#import "CCPhysics+ObjectiveChipmunk.h"

@implementation Ship
{
	CCNode *_mainThruster;
	id<ALSoundSource> _engineNoise;
	
	CCNode *_shield;
	
	CCNode *_gunPort1, *_gunPort2;
	NSUInteger _currentGunPort;
	
	float _speed;
	float _accelTime;
}

-(void)onEnter
{
	CCPhysicsBody *body = self.physicsBody;
	
	// This is used to pick which collision delegate method to call, see GameScene.m for more info.
	body.collisionType = @"ship";
	
	// This sets up simple collision rules.
	// First you list the categories (strings) that the object belongs to.
	body.collisionCategories = @[@"ship"];
	// Then you list which categories its allowed to collide with.
	body.collisionMask = @[@"asteroid"];
	
	// Make the thruster pulse
	float scaleX = _mainThruster.scaleX;
	float scaleY = _mainThruster.scaleY;
	[_mainThruster runAction:[CCActionRepeatForever actionWithAction:[CCActionSequence actions:
		[CCActionScaleTo actionWithDuration:0.1 scaleX:scaleX scaleY:0.5*scaleY],
		[CCActionScaleTo actionWithDuration:0.05 scaleX:scaleX scaleY:scaleY],
		nil
	]]];
	
	// Make the shield spin
	[_shield runAction:[CCActionRepeatForever actionWithAction:[CCActionRotateBy actionWithDuration:1.0 angle:360.0]]];
	
	[super onEnter];
}

-(void)onExit
{
	[_engineNoise stop];
	
	[super onExit];
}

// This method is called from [GameScene fixedUpdate:], not from Cocos2D.
-(void)fixedUpdate:(CCTime)delta withInput:(CGPoint)joystickValue
{
	CCPhysicsBody *body = self.physicsBody;
	CGPoint targetVelocity = ccpMult(joystickValue, _speed);
	CGPoint velocity = cpvlerpconst(body.velocity, targetVelocity, _speed/_accelTime*delta);
	
//	CCLOG(@"velocity: %@", NSStringFromCGPoint(velocity));
	
	body.velocity = velocity;
	if(cpvlengthsq(velocity)){
		self.rotation = -CC_RADIANS_TO_DEGREES(atan2f(velocity.y, velocity.x));
		
		_mainThruster.visible = YES;
		
		if(!_engineNoise){
			_engineNoise = [[OALSimpleAudio sharedInstance] playEffect:@"Engine.wav" loop:YES];
		}
		
		_engineNoise.volume = ccpLength(joystickValue);
	} else {
		_mainThruster.visible = NO;
		[_engineNoise stop]; _engineNoise = nil;
	}
}

-(CGAffineTransform)gunPortTransform
{
	// Constantly switch between gunports.
	_currentGunPort++;
	
	CCNode *gunports[] = {_gunPort1, _gunPort2};
	return [gunports[_currentGunPort%2] nodeToWorldTransform];
}

-(BOOL)takeDamage
{
	if(_shield){
		[[OALSimpleAudio sharedInstance] playEffect:@"Shield.wav"];
		
		float duration = 0.25;
		[_shield runAction:[CCActionSequence actions:
			[CCActionSpawn actions:
				[CCActionScaleTo actionWithDuration:duration scale:4.0],
				[CCActionFadeOut actionWithDuration:duration],
				nil
			],
			[CCActionRemove action],
			nil
		]];
		
		_shield = nil;
		return NO;
	} else {
		[[OALSimpleAudio sharedInstance] playEffect:@"Crash.wav"];
		
		return YES;
	}
}

@end
