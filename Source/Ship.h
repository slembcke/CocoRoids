//
//  Ship.h
//  Cocoroids
//
//  Created by Scott Lembcke on 1/19/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCNode.h"

@interface Ship : CCNode

@property(nonatomic, readonly) CGAffineTransform gunPortTransform;

-(void)fixedUpdate:(CCTime)delta withInput:(CGPoint)joystickValue;

-(BOOL)takeDamage;

@end
