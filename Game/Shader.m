//
//  Shader.m
//  Game
//
//  Created by Landon on 12/9/12.
//  Copyright (c) 2012 Landon. All rights reserved.
//

#import "Shader.h"
#import <GLKit/GLKit.h>

@interface Shader ()

- (BOOL)loadProgramForName:(NSString *)name;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;

@end

@implementation Shader

- (id)init {
	if (self = [super init]) {
		const char *name = object_getClassName([self class]);
		NSString *className = [NSString stringWithCString:name encoding:NSStringEncodingConversionAllowLossy];
		if (![self loadProgramForName:className]) {
			[self autorelease];
			return nil;
		}
	}
	return self;
}

#pragma mark -  OpenGL ES 2 shader compilation

- (BOOL)loadProgramForName:(NSString *)name
{
		
	// Create shader _program.
	_program = glCreateProgram();
	
	GLuint vertShader, fragShader;
	NSString *vertShaderPathname, *fragShaderPathname;
	
	// Create and compile vertex shader.
	vertShaderPathname = [[NSBundle mainBundle] pathForResource:name ofType:@"vsh"];
	if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
		NSLog(@"Failed to compile vertex shader");
		return NO;
	}
	
	// Create and compile fragment shader.
	fragShaderPathname = [[NSBundle mainBundle] pathForResource:name ofType:@"fsh"];
	if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
		NSLog(@"Failed to compile fragment shader");
		return NO;
	}
		
	// Attach vertex shader to _program.
	glAttachShader(_program, vertShader);
	
	// Attach fragment shader to _program.
	glAttachShader(_program, fragShader);
	
	[self manageAttributeLocationsForProgram:_program];

	// Link _program.
	if (![self linkProgram:_program]) {
		NSLog(@"Failed to link _program: %d", _program);
		
		if (vertShader) {
			glDeleteShader(vertShader);
		}
		if (fragShader) {
			glDeleteShader(fragShader);
		}
		if (_program) {
			glDeleteProgram(_program);
		}
		
		return NO;
	}
	
	// Get uniform locations.
	_uniforms.UNIFORM_MODELVIEWPROJECTION_MATRIX = glGetUniformLocation(_program, "modelViewProjectionMatrix");
	_uniforms.UNIFORM_NORMAL_MATRIX = glGetUniformLocation(_program, "normalMatrix");
	
	// Release vertex and fragment shaders.
	if (vertShader) {
		glDetachShader(_program, vertShader);
		glDeleteShader(vertShader);
	}
	if (fragShader) {
		glDetachShader(_program, fragShader);
		glDeleteShader(fragShader);
	}
    return YES;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source) {
        NSLog(@"Failed to load vertex shader %@", file);
        return NO;
    }
	
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
	[self manageAttributeLocationsForShader:*shader ofType:type];
	
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
	
    return YES;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"_program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (void)manageAttributeLocationsForProgram:(GLuint)program {
	
	glBindAttribLocation(program, GLKVertexAttribPosition, "position");
	glBindAttribLocation(program, GLKVertexAttribNormal, "normal");
}

- (void)manageAttributeLocationsForShader:(GLuint)shader ofType:(GLenum)type {
	
}

- (void)dealloc {
	if (_program) {
		glDeleteProgram(_program);
		_program = 0;
	}
	[super dealloc];
}

@end
