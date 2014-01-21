//
//  Asteroid.m
//  Cocoroids
//
//  Created by Scott Lembcke on 1/19/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Asteroid.h"
#import "GameScene.h"


@implementation Asteroid {
	float _speed;
}

-(void)onEnter
{
	CCPhysicsBody *body = self.physicsBody;
	
	// Give the asteroid a random velocity and tumble
	body.velocity = ccpMult(CCRANDOM_ON_UNIT_CIRCLE(), _speed);
	body.angularVelocity  = 3.0*CCRANDOM_MINUS1_1();
	
	// This is used to pick which collision delegate method to call, see GameScene.m for more info.
	body.collisionType = @"asteroid";
	
	// This sets up simple collision rules.
	// First you list the categories (strings) that the object belongs to.
	body.collisionCategories = @[@"asteroid"];
	// Then you list which categories its allowed to collide with.
	body.collisionMask = @[@"ship", @"bullet"];
	
	[super onEnter];
}

@end
