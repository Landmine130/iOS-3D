//
//  Shader.h
//  Game
//
//  Created by Landon on 12/9/12.
//  Copyright (c) 2012 Landon. All rights reserved.
//

#import <Foundation/Foundation.h>

// Uniform index.
typedef struct
{
    GLint UNIFORM_MODELVIEWPROJECTION_MATRIX;
    GLint UNIFORM_NORMAL_MATRIX;
} UniformIndex;

// Attribute index.
enum {
	ATTRIB_VERTEX,
    ATTRIB_NORMAL
};

@interface Shader : NSObject

@property (nonatomic, readonly) GLuint program;
@property (nonatomic, readonly) UniformIndex uniforms;

- (void)manageAttributeLocationsForProgram:(GLuint)program;
- (void)manageAttributeLocationsForShader:(GLuint)shader ofType:(GLenum)type;

@end
