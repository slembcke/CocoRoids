//
//  Bullet.m
//  Cocoroids
//
//  Created by Scott Lembcke on 1/20/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Bullet.h"

@implementation Bullet

-(void)onEnter
{
	CCPhysicsBody *body = self.physicsBody;
	
	// This is used to pick which collision delegate method to call, see GameScene.m for more info.
	body.collisionType = @"bullet";
	
	// This sets up simple collision rules.
	// First you list the categories (strings) that the object belongs to.
	body.collisionCategories = @[@"bullet"];
	// Then you list which categories its allowed to collide with.
	body.collisionMask = @[@"asteroid"];
	
	[super onEnter];
}

@end
