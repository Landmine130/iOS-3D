//
//  GLView.h
//  TestGame
//
//  Created by Landon on 8/11/12.
//  Copyright (c) 2012 Landon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <GLKit/GLKit.h>

@class GLView;

@protocol GLViewDelegate <NSObject>

- (void)drawFrameForGLView:(GLView *)view;
- (void)update;

@end

@interface GLView : UIView {
	CAEAGLLayer *_eaglLayer;
	
	GLuint _framebuffer;
	GLuint _colorRenderbuffer;
	GLuint _depthRenderbuffer;
	
	GLuint _multisampleFramebuffer;
	GLuint _multisampleColorRenderbuffer;
	GLuint _multisampleDepthRenderbuffer;
	
	GLint _framebufferWidth;
	GLint _framebufferHeight;
	
}

@property (nonatomic, retain) EAGLContext *context;
@property (nonatomic, retain) IBOutlet id <GLViewDelegate> delegate;

@end

