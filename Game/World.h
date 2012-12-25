//
//  ViewController.h
//  Game
//
//  Created by Landon on 11/26/12.
//  Copyright (c) 2012 Landon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "GLView.h"

@class WorldObject;
@class World;

@protocol WorldUpdateObserver <NSObject>

- (void)worldIsUpdating:(World *)world timeSinceLastUpdate:(NSTimeInterval)seconds;

@end

@interface World : UIViewController <GLViewDelegate>

@property (nonatomic, readonly) NSOrderedSet *objects;
@property (nonatomic) BOOL paused;
@property (nonatomic, readonly) NSTimeInterval timeSinceLastUpdate;
@property (nonatomic, readonly) NSTimeInterval runTimeSinceLastUpdate;
@property (nonatomic, readonly) NSTimeInterval timeSinceLastResume;
@property (nonatomic, readonly) NSTimeInterval runTimeSinceLastResume;
@property (nonatomic, readonly) NSTimeInterval timeSinceLastPause;
@property (nonatomic, readonly) NSTimeInterval runTimeSinceLastPause;
@property (nonatomic, readonly) NSTimeInterval timeSinceStart;
@property (nonatomic, readonly) NSTimeInterval runTimeSinceStart;

- (void)addObject:(WorldObject *)object;
- (void)removeObject:(WorldObject *)object;

- (void)addUpdateObserver:(id<WorldUpdateObserver>)object;
- (void)removeUpdateObserver:(id<WorldUpdateObserver>)object;

@end
