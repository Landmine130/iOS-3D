//
//  GLView.m
//  TestGame
//
//  Created by Landon on 8/11/12.
//  Copyright (c) 2012 Landon. All rights reserved.
//

#import "GLView.h"

@implementation GLView

- (id)initWithCoder:(NSCoder *)aDecoder {
	
    self = [super initWithCoder:aDecoder];
    if (self) {

		_eaglLayer = (CAEAGLLayer*)self.layer;
		_eaglLayer.contentsScale *= [[UIScreen mainScreen] scale];
	}
	return self;
}


- (void)setContext:(EAGLContext *)newContext {
	
	if (newContext != self.context) {
		[self.context release];
		_context = newContext;
		[self.context retain];
		
		if (self.context) {
			[EAGLContext setCurrentContext:self.context];
			
			glGenFramebuffers(1, &_framebuffer);
			glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);
			
			glGenRenderbuffers(1, &_colorRenderbuffer);
			glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderbuffer);
			[self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
			glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderbuffer);
			
			glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_framebufferWidth);
			glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_framebufferHeight);
			/*
			glGenRenderbuffers(1, &_depthRenderbuffer);
			glBindRenderbuffer(GL_RENDERBUFFER, _depthRenderbuffer);
			glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, _framebufferWidth, _framebufferHeight);
			glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthRenderbuffer);
			*/
			GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
			if (status != GL_FRAMEBUFFER_COMPLETE) {
				NSLog(@"failed to make complete framebuffer object %x", status);
			}
			
			glGenFramebuffers(1, &_multisampleFramebuffer);
			glBindFramebuffer(GL_FRAMEBUFFER, _multisampleFramebuffer);
			
			glGenRenderbuffers(1, &_multisampleColorRenderbuffer);
			glBindRenderbuffer(GL_RENDERBUFFER, _multisampleColorRenderbuffer);
			glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER, 4, GL_RGBA8_OES, _framebufferWidth, _framebufferHeight);
			glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _multisampleColorRenderbuffer);
			
			glGenRenderbuffers(1, &_multisampleDepthRenderbuffer);
			glBindRenderbuffer(GL_RENDERBUFFER, _multisampleDepthRenderbuffer);
			glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER, 4, GL_DEPTH_COMPONENT16, _framebufferWidth, _framebufferHeight);
			glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _multisampleDepthRenderbuffer);
			
			if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
				NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
		}
	}
}

- (void)drawFrame {
	glBindFramebuffer(GL_FRAMEBUFFER, _multisampleFramebuffer);
	glViewport(0, 0, _framebufferWidth, _framebufferHeight);

	[self.delegate update];
	
	[self.delegate drawFrameForGLView:self];
	
	glBindFramebuffer(GL_DRAW_FRAMEBUFFER_APPLE, _framebuffer);
	glBindFramebuffer(GL_READ_FRAMEBUFFER_APPLE, _multisampleFramebuffer);
	glResolveMultisampleFramebufferAPPLE();
	
	const GLenum discards[]  = {GL_COLOR_ATTACHMENT0,GL_DEPTH_ATTACHMENT};
	glDiscardFramebufferEXT(GL_READ_FRAMEBUFFER_APPLE,2,discards);
	
	glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderbuffer);
	[self.context presentRenderbuffer:GL_RENDERBUFFER];
}


+ (Class) layerClass
{
    return [CAEAGLLayer class];
}


@end
