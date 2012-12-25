//
//  ViewController.m
//  Game
//
//  Created by Landon on 11/26/12.
//  Copyright (c) 2012 Landon. All rights reserved.
//

#import "World.h"
#import "TargetedViewPoint.h"
#import "TextureShader.h"
#import "WorldObject.h"
#import "VisibleObject.h"
#import "Cube.h"
#import "PhysicsObject.h"

#define SCROLL_FRICTION .73f
#define SCROLL_SPEED .2f
#define MOVEMENT_SPEED_MULTIPLIER .001f
#define MAX_SPEED_TOUCH_DISTANCE 200

@interface World () {

    float _rotation;
    
	ViewPoint *_viewPoint;
	NSMutableOrderedSet *_objects;
	NSMutableOrderedSet *_observers;
	NSMutableOrderedSet *_touches;
	
	NSDate *_lastTouchUpdateTime;
	
	float _xRotationSpeed;
	float _yRotationSpeed;
		
	GLKVector3 _movementVector;
	GLKVector3 _orientationVector;
	
	CADisplayLink *_displayLink;
	NSTimeInterval _totalPuaseTimeBeforeCurrentPauseSinceLastUpdate;
	NSTimeInterval _totalRunTimeBeforeLastPause;
	NSTimeInterval _startTime;
	NSTimeInterval _lastResumeTime;
	NSTimeInterval _lastPauseTime;
	NSTimeInterval _lastUpdateTime;
}

@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;

- (void)setupGL;

- (GLKVector3)movementVectorForTouch:(UITouch *)touch;

- (NSTimeInterval)timePausedSinceLastUpdate;
- (NSTimeInterval)timePausedSinceLastPause;
- (NSTimeInterval)timePausedSinceLastResume;
- (NSTimeInterval)timePausedSinceStart;

@end

@implementation World

@synthesize objects = _objects;

- (void)addObject:(WorldObject *)object {

	[_objects addObject:object];
	[_observers addObject:object];
}

- (void)removeObject:(WorldObject *)object {
	[_objects removeObject:object];
	[_observers removeObject:object];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	_xRotationSpeed = 0;
	_yRotationSpeed = 0;
		
    self.context = [[[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2] autorelease];

    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
	_totalRunTimeBeforeLastPause = _lastPauseTime = _lastResumeTime = _totalPuaseTimeBeforeCurrentPauseSinceLastUpdate = _lastUpdateTime = 0;
	
    [self setupGL];
	
	_objects = [[NSMutableOrderedSet alloc] init];
	_observers = [[NSMutableOrderedSet alloc] init];

	[self addObject:[[[PhysicsObject alloc] initWithModelName:@"banana" andMass:1] autorelease]];

	Shader *shader = [[Shader alloc] init];
	
	[_objects addObject:[[[PhysicsObject alloc] initWithVertexArray:gCubeVertexData vertexCount:216 / 6 normalCount:216 / 6 textureMapCount:0 texture:0 shader:shader] autorelease]];
	[[_objects objectAtIndex:1] setMass:1];

	[shader release];
	
	[(WorldObject *)[_objects objectAtIndex:0] setPosition:GLKVector3Make(0, 0, -10)];
	[(WorldObject *)[_objects objectAtIndex:1] setPosition:GLKVector3Make(0, 0, 0.0f)];
	
	[(PhysicsObject *)[_objects objectAtIndex:0] addCollidableObject:[_objects objectAtIndex:1]];
	[(PhysicsObject *)[_objects objectAtIndex:1] addCollidableObject:[_objects objectAtIndex:0]];

	//[[_physicsObjects objectAtIndex:0] applyForce:GLKVector3Make(0, 0.1f, 0) forDuration:1];
	
	_viewPoint = [[TargetedViewPoint alloc] initWithTarget:[_objects objectAtIndex:0] distanceFromTarget:4];
	_viewPoint.orientation = GLKVector3Make(GLKMathDegreesToRadians(30), 0, 0);
	
	_touches = [[NSMutableOrderedSet alloc] init];
	
	_lastTouchUpdateTime = [[NSDate alloc] init];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
	return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
        
		[EAGLContext setCurrentContext:self.context];
        
        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }

    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[_touches unionSet:touches];
	
	if ([_touches count] == 1) {
		
		_movementVector = [self movementVectorForTouch:[_touches objectAtIndex:0]];
	}
	else {
		_movementVector = GLKVector3Make(0, 0, 0);
	 }
	 
	/*
	if ([_touches count] == 1) {
		if ([_viewPoint isKindOfClass:[TargetedViewPoint class]]) {
			if ([((TargetedViewPoint *)_viewPoint).target isKindOfClass:[PhysicsObject class]]) {
				PhysicsObject *target = (PhysicsObject *)((TargetedViewPoint *)_viewPoint).target;
				[target applyForce:GLKVector3Normalize([_viewPoint vectorToObject:target]) forDuration:0 atPosition:GLKVector3Make(.5, 0, 0) isRelativeToCenter:YES];
			}
		}
	}
	 */
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	
	[_touches minusSet:touches];
	
	if ([_touches count] == 1) {
		
		_movementVector = [self movementVectorForTouch:[_touches objectAtIndex:0]];
	}
	else {
		_movementVector = GLKVector3Make(0, 0, 0);
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
	if ([_touches count] == 1) {
		
		_movementVector = [self movementVectorForTouch:[_touches objectAtIndex:0]];
		
	}
	else {
		_movementVector = GLKVector3Make(0, 0, 0);
		
		if ([_touches count] == 2) {
			UITouch *touch1 = [_touches objectAtIndex:0];
			UITouch *touch2 = [_touches objectAtIndex:1];
			
			float xChange = [touch1 locationInView:self.view].x - [touch1 previousLocationInView:self.view].x;
			xChange = (xChange + [touch2 locationInView:self.view].x - [touch2 previousLocationInView:self.view].x) / 2.0f;
			float yChange = [touch1 locationInView:self.view].y - [touch1 previousLocationInView:self.view].y;
			yChange = (yChange + [touch2 locationInView:self.view].y - [touch2 previousLocationInView:self.view].y) / 2.0f;
			
			GLKVector3 orientation = _viewPoint.orientation;
			orientation.y -= GLKMathDegreesToRadians(xChange * SCROLL_SPEED);
			orientation.x -= GLKMathDegreesToRadians(yChange * SCROLL_SPEED);
			_viewPoint.orientation = orientation;
			
			NSDate *currentTime = [[NSDate alloc] init];
			NSTimeInterval elapsedTime = [currentTime timeIntervalSinceDate:_lastTouchUpdateTime];
			[_lastTouchUpdateTime release];
			_lastTouchUpdateTime = currentTime;
			
			
			if (elapsedTime) {
				_xRotationSpeed = yChange / elapsedTime * SCROLL_SPEED;
				_yRotationSpeed = xChange / elapsedTime * SCROLL_SPEED;
			}
		}
	}
	
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[_touches minusSet:touches];
	/*
	if ([_viewPoint isKindOfClass:[TargetedViewPoint class]]) {
		if ([((TargetedViewPoint *)_viewPoint).target isKindOfClass:[PhysicsObject class]]) {
			PhysicsObject *target = (PhysicsObject *)((TargetedViewPoint *)_viewPoint).target;
			[target stop];
		}
	}
	*/
	if ([_touches count] == 1) {
		
		_movementVector = [self movementVectorForTouch:[_touches objectAtIndex:0]];
	}
	else {
		_movementVector = GLKVector3Make(0, 0, 0);
	}
}

- (GLKVector3)movementVectorForTouch:(UITouch *)touch {
	CGPoint point = [touch locationInView:self.view];
	
	
	point.x = point.x - CGRectGetMidX(self.view.bounds);
	point.y = point.y - CGRectGetMidY(self.view.bounds);
	
	float distanceFromCenter = sqrtf(point.x * point.x + point.y * point.y);
	
	if (distanceFromCenter > MAX_SPEED_TOUCH_DISTANCE) {
		distanceFromCenter = MAX_SPEED_TOUCH_DISTANCE;
	}
	
	float radians = atan2f(-point.y, point.x) - _viewPoint.orientation.y;
	
	point.x = cos(radians) * MOVEMENT_SPEED_MULTIPLIER * distanceFromCenter;
	point.y = sin(radians) * MOVEMENT_SPEED_MULTIPLIER * distanceFromCenter;
		
	_orientationVector = GLKVector3Make(0, radians - GLKMathDegreesToRadians(90), 0);
	
	return GLKVector3Make(point.x, 0, point.y);
}

- (void)addUpdateObserver:(id<WorldUpdateObserver>)object {
	[_observers addObject:object];
}

- (void)removeUpdateObserver:(id<WorldUpdateObserver>)object {
	[_observers removeObject:object];
}

- (void)setPaused:(BOOL)paused {
	if (paused != _displayLink.paused) {
		if (paused) {
			_displayLink.paused = paused;
			_totalRunTimeBeforeLastPause = _totalRunTimeBeforeLastPause + self.timeSinceLastResume;
			_lastPauseTime = [NSDate timeIntervalSinceReferenceDate];
		}
		else {
			_lastResumeTime = [NSDate timeIntervalSinceReferenceDate];
			_totalPuaseTimeBeforeCurrentPauseSinceLastUpdate += _lastResumeTime - _lastPauseTime;
			_displayLink.paused = paused;
		}
	}
}

- (BOOL)paused {
	return _displayLink.paused;
}

- (NSTimeInterval)timeSinceLastUpdate {
	return [NSDate timeIntervalSinceReferenceDate] - _lastUpdateTime;
}

- (NSTimeInterval)timeSinceLastPause {
	return [NSDate timeIntervalSinceReferenceDate] - _lastPauseTime;
}

- (NSTimeInterval)timeSinceLastResume {
	return [NSDate timeIntervalSinceReferenceDate] - _lastResumeTime;
}

- (NSTimeInterval)timeSinceStart {
	return [NSDate timeIntervalSinceReferenceDate] - _startTime;
}

- (NSTimeInterval)runTimeSinceLastUpdate {
	return [NSDate timeIntervalSinceReferenceDate] - _lastUpdateTime - [self timePausedSinceLastUpdate];
}

- (NSTimeInterval)runTimeSinceLastPause {
	return [NSDate timeIntervalSinceReferenceDate] - _lastPauseTime - [self timePausedSinceLastPause];
}

- (NSTimeInterval)runTimeSinceLastResume {
	return [NSDate timeIntervalSinceReferenceDate] - _lastResumeTime - [self timePausedSinceLastResume];
}

- (NSTimeInterval)runTimeSinceStart {
	return [NSDate timeIntervalSinceReferenceDate] - _startTime - [self timePausedSinceStart];
}

- (NSTimeInterval)timePausedSinceLastUpdate {
	if (_lastUpdateTime > _lastPauseTime) {
		return 0;
	}
	else {
		if (_displayLink.paused) {
			return _totalPuaseTimeBeforeCurrentPauseSinceLastUpdate + self.timeSinceLastPause;
		}
		else {
			return _totalPuaseTimeBeforeCurrentPauseSinceLastUpdate;
		}
	}
}

- (NSTimeInterval)timePausedSinceLastPause {
	if (_displayLink.paused) {
		return self.timeSinceLastPause;
	}
	else {
		return _lastResumeTime - _lastPauseTime;
	}
}

- (NSTimeInterval)timePausedSinceLastResume {
	if (_displayLink.paused) {
		return self.timeSinceLastPause;
	}
	else {
		return 0;
	}
}

- (NSTimeInterval)timePausedSinceStart {
	if (_displayLink.paused) {
		return _totalRunTimeBeforeLastPause + self.timeSinceLastPause;
	}
	else {
		return _totalRunTimeBeforeLastPause + _lastResumeTime - _lastPauseTime;
	}
}

#pragma mark - GLVieDelegate Methods

- (void)update
{
	_totalPuaseTimeBeforeCurrentPauseSinceLastUpdate = 0;
	NSTimeInterval elapsedTime = self.runTimeSinceLastUpdate;

	//NSLog(@"%f", self.timeSinceLastUpdate);
	
	
	
	// ViewPoint movement
	if ([_touches count] != 2) {
		
		float friction = powf(SCROLL_FRICTION, elapsedTime);
		
		_xRotationSpeed *= friction;
		_yRotationSpeed *= friction;
		
		GLKVector3 orientation = _viewPoint.orientation;
		orientation.x -= GLKMathDegreesToRadians(_xRotationSpeed * elapsedTime);
		orientation.y -= GLKMathDegreesToRadians(_yRotationSpeed * elapsedTime);
		_viewPoint.orientation = orientation;
	}
	
	// Player movement
	if ([_viewPoint isKindOfClass:[TargetedViewPoint class]]) {
		WorldObject *target = ((TargetedViewPoint *)_viewPoint).target;
		if ([target isKindOfClass:[PhysicsObject class]] && (_movementVector.x != 0 || _movementVector.y != 0 || _movementVector.z != 0)) {
			[(PhysicsObject *)target stop];
		}
		[target move:_movementVector];
		target.orientation = _orientationVector;
		
	}
	
	// Notify observers
	int count = [_observers count];
	for (int i = 0; i < count; i++) {
		
		id<WorldUpdateObserver> o = [_observers objectAtIndex:i];
		
		[o worldIsUpdating:self timeSinceLastUpdate:elapsedTime];
	}
	_lastUpdateTime = [NSDate timeIntervalSinceReferenceDate];
}

- (void)drawFrameForGLView:(GLView *)view;
{
	glClearColor(0.75f, 0.75f, .75f, 1.0f);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	glActiveTexture(GL_TEXTURE0);
	
	float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(_viewPoint.fieldOfView, aspect, _viewPoint.minimumSightDistance, _viewPoint.maximumSightDistance);
    	
    GLKMatrix4 baseModelViewMatrix = GLKMatrix4MakeRotation(_viewPoint.orientation.x, 1.0f, 0.0f, 0.0f);
    baseModelViewMatrix = GLKMatrix4RotateY(baseModelViewMatrix, _viewPoint.orientation.y);
    baseModelViewMatrix = GLKMatrix4RotateZ(baseModelViewMatrix, _viewPoint.orientation.z);
	
	GLKVector3 viewPosition = _viewPoint.position;
	baseModelViewMatrix = GLKMatrix4Translate(baseModelViewMatrix, -viewPosition.x, -viewPosition.y, viewPosition.z);
	
	int count = [_objects count];
	for (int i = 0; i < count; i++) {
		VisibleObject *o = [_objects objectAtIndex:i];
		if (!o.hidden) {
			GLKVector3 objectPosition = o.position;
			
			GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(objectPosition.x, objectPosition.y, -objectPosition.z);
			modelViewMatrix = GLKMatrix4RotateX(modelViewMatrix, o.orientation.x);
			modelViewMatrix = GLKMatrix4RotateY(modelViewMatrix, o.orientation.y);
			modelViewMatrix = GLKMatrix4RotateZ(modelViewMatrix, o.orientation.z);
			
			modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);
			
			o.normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelViewMatrix), NULL);
			o.modelViewProjectionMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
			
			
			glBindVertexArrayOES(o.vertexArray);
			
			if ([o.shader isKindOfClass:[TextureShader class]]) {
				glBindTexture(GL_TEXTURE_2D, o.texture);
				glUniform1i(((TextureShader *)(o.shader)).textureIndex.textureUniform, 0);
			}
			glUseProgram(o.shader.program);
			
			glUniformMatrix4fv(o.shader.uniforms.UNIFORM_MODELVIEWPROJECTION_MATRIX, 1, 0, o.modelViewProjectionMatrix.m);
			glUniformMatrix3fv(o.shader.uniforms.UNIFORM_NORMAL_MATRIX, 1, 0, o.normalMatrix.m);
			
			//glDrawElements(GL_TRIANGLES, o.vertexCount, GL_FLOAT, o.data);
			glDrawArrays(GL_TRIANGLES, 0, o.vertexCount);
		}
	}
}

#pragma mark - Open GL ES Setup

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];

	GLView *view = (GLView *)self.view;
	view.delegate = self;
    view.context = self.context;
	
	glEnable(GL_TEXTURE_2D);
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_SRC_ALPHA_SATURATE);
    glEnable(GL_DEPTH_TEST);

	_displayLink = [CADisplayLink displayLinkWithTarget:view selector:@selector(drawFrame)];
	_displayLink.frameInterval = 2;
	
	_startTime = [NSDate timeIntervalSinceReferenceDate];
	[_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}


- (void)dealloc
{
    [EAGLContext setCurrentContext:self.context];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
    
	self.context = nil;
	self.effect = nil;
	[_viewPoint release];
	[_objects release];
	[_observers release];
	[_touches release];
	
    [super dealloc];
}

@end
