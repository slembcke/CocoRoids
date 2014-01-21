//
//  Joystick.h
//  Cocoroids
//
//  Created by Scott Lembcke on 1/20/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCNode.h"

@interface Joystick : CCNode

@property(nonatomic, readonly) CGPoint value;
@property(nonatomic, assign) float deadZone;

@end
