//
//  GameScene.m
//  Cocoroids
//
//  Created by Scott Lembcke on 1/19/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "OALSimpleAudio.h"

#import "GameScene.h"

#import "Ship.h"
#import "Bullet.h"
#import "Asteroid.h"
#import "Joystick.h"

@implementation GameScene
{
	CCPhysicsNode *_physics;
	
	Ship *_ship;
	
	NSMutableArray *_asteroids;
	NSMutableArray *_bullets;
	
	Joystick *_joystick;
	
	NSUInteger _asteroidCount;
}

-(void)addAsteroid:(BOOL)big at:(CGPoint)position
{
	CCNode *rock = [CCBReader load:(big ? @"BigAsteroid" : @"LittleAsteroid")];
	rock.position = position;
	
	[_asteroids addObject:rock];
	[_physics addChild:rock];
}

-(void)destroyAsteroid:(Asteroid *)asteroid
{
	[asteroid removeFromParent];
	[_asteroids removeObject:asteroid];
	
	if(_asteroids.count == 0){
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"New Wave Incoming!" fontName:@"Helvetica" fontSize:30];
		label.color = [CCColor blackColor];
		label.positionType = CCPositionTypeNormalized;
		label.position = ccp(0.5, 0.5);
		[self addChild:label];
		
		// Reset the game after a delay
		[self scheduleBlock:^(CCTimer *timer){
			[[CCDirector sharedDirector] replaceScene:[CCBReader loadAsScene:@"GameScene"]];
		} delay:2.0];
	}
	
	// Make some noise. Add a little chromatically tuned pitch bending to make it more musical.
	int half_steps = (arc4random()%(2*4 + 1) - 4);
	float pitch = pow(2.0f, half_steps/12.0f);
	[[OALSimpleAudio sharedInstance] playEffect:@"Explosion.wav" volume:1.0 pitch:pitch pan:0.0 loop:NO];
}

-(void)onEnter
{
	CGSize size = self.contentSizeInPoints;
	CGPoint center = ccp(size.width/2, size.height/2);
	
	// Add a ship in the middle of the screen.
	_ship = (Ship *)[CCBReader load:@"Ship"];
	_ship.position = center;
	[_physics addChild:_ship];
	
	// Reset the bullets and asteroids.
	_asteroids = [NSMutableArray array];
	_bullets = [NSMutableArray array];
	
	// Add some random asteroids.
	for(int i=0; i<_asteroidCount; i++){
		CGPoint pos = ccpAdd(center, ccpMult(CCRANDOM_ON_UNIT_CIRCLE(), 150));
		[self addAsteroid:YES at:pos];
	}
	
	// Use the gamescene as the collision delegate.
	// See the ccPhysicsCollision* methods below.
	_physics.collisionDelegate = self;
	
	// Enable to show debug outlines for Physics shapes.
//	_physics.debugDraw = YES;
	
	// Enable touch events.
	// The entire scene is used as a shoot button.
	self.userInteractionEnabled = YES;
	
	[super onEnter];
}

static CGPoint
WrapAround(CGPoint pos, CGSize size)
{
	if(pos.x < 0.0) pos.x += size.width;
	if(pos.y < 0.0) pos.y += size.height;
	if(pos.x > size.width ) pos.x -= size.width;
	if(pos.y > size.height) pos.y -= size.height;
	
	return pos;
}

-(void)fixedUpdate:(CCTime)delta
{
	// This is the size of the playfield
	CGSize size = [CCDirector sharedDirector].designSize;
	
	// Wrap the positions of all the objects
	_ship.position = WrapAround(_ship.position, size);
	for(Asteroid *rock in _asteroids) rock.position = WrapAround(rock.position, size);
	for(Bullet *bullet in _bullets) bullet.position = WrapAround(bullet.position, size);
	
	// Fly the ship using the joystick controls.
	[_ship fixedUpdate:delta withInput:_joystick.value];
}

-(void)destroyBullet:(Bullet *)bullet
{
	[bullet removeFromParent];
	[_bullets removeObject:bullet];
	
	// Draw a little flash at it's last position
	CCSprite *sprite = [CCSprite spriteWithImageNamed:@"ShipParts/laserGreenShot.png"];
	sprite.position = bullet.position;
	[self addChild:sprite];
	
	[sprite runAction:[CCActionSequence actions:
		[CCActionFadeOut actionWithDuration:0.1],
		[CCActionRemove action],
		nil
	]];
	
	// Make some noise. Add a little chromatically tuned pitch bending to make it more musical.
	int half_steps = (arc4random()%(2*4 + 1) - 4);
	float pitch = pow(2.0f, half_steps/12.0f);
	[[OALSimpleAudio sharedInstance] playEffect:@"Fizzle.wav" volume:1.0 pitch:pitch pan:0.0 loop:NO];
}

-(void)fireBullet
{
	// This is sort of a fancy math way to figure out where to fire the bullet from.
	// You could figure this out with more code, but I wanted to have fun with some maths.
	// This gets the transform of one of the "gunports" that I marked in the CCB file with a special node.
	CGAffineTransform transform = _ship.gunPortTransform;
	
	// An affine transform looks like this when written as a matrix:
	// | a, c, tx |
	// | b, d, ty |
	// The first column, (a, b), is the direction the new x-axis will point in.
	// The second column, (c, d), is the direction the new y-axis will point in.
	// The last column, (tx, ty), is the location of the origin of the new transform.
	
	// The position of the gunport is just the matrix's origin point (tx, ty).
	CGPoint position = ccp(transform.tx, transform.ty);
	
	// The original sprite pointed downwards on the y-axis.
	// So the transform's y-axis, (c, d), will point in the opposite direction of the gunport.
	// We just need to flip it around.
	CGPoint direction = ccp(-transform.c, -transform.d);
	
	// So by "fancy math" I really just meant knowing what the numbers in a CGAffineTransform are. ;)
	// When I make my own art, I like to align things on the positive x-axis to make the code "prettier".
	
	// Now we can create the bullet with the position and direction.
	Bullet *bullet = (Bullet *)[CCBReader load:@"Bullet"];
	bullet.position = position;
	bullet.rotation = -CC_RADIANS_TO_DEGREES(ccpToAngle(direction));
	
	// Make the bullet move in the direction it's pointed.
	bullet.physicsBody.velocity = ccpMult(direction, bullet.speed);
	
	[_physics addChild:bullet];
	[_bullets addObject:bullet];
	
	// Give the bullet a finite lifetime.
	[bullet scheduleBlock:^(CCTimer *timer){
		[self destroyBullet:bullet];
	} delay:bullet.duration];
	
	// Make some noise. Add a little chromatically tuned pitch bending to make it more musical.
	int half_steps = (arc4random()%(2*4 + 1) - 4);
	float pitch = pow(2.0f, half_steps/12.0f);
	[[OALSimpleAudio sharedInstance] playEffect:@"Laser.wav" volume:1.0 pitch:pitch pan:0.0 loop:NO];
}

//MARK CCResponder methods

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	[self fireBullet];
}

//MARK CCPhysicsCollisionDelegate methods

// "Begin" methods are only called once when objects begin to collide.
// Note how the last two parameters "ship" and "asteroid" are the same string as the collisionType values set in those classes.
-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair ship:(CCNode *)ship asteroid:(CCNode *)asteroid
{
	[[CCDirector sharedDirector] replaceScene:[CCBReader loadAsScene:@"MainScene"]];
	
	// Don't process the collision between the ship and the asteroid.
	// It doesn't really matter since we are destroying both objects anyway.
	return NO;
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair bullet:(Bullet *)bullet asteroid:(Asteroid *)asteroid
{
	// If the asteroid was marked as being big, make a few little ones in it's place.
	if(asteroid.big){
		CGPoint pos = asteroid.position;
		
		for(int i=0; i<3; i++){
			[self addAsteroid:NO at:pos];
		}
	}
	
	[self destroyBullet:bullet];
	[self destroyAsteroid:asteroid];
	
	return NO;
}

@end
