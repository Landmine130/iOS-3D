//
//  TextureShader.m
//  Game
//
//  Created by Landon on 12/10/12.
//  Copyright (c) 2012 Landon. All rights reserved.
//

#import "TextureShader.h"
#import <GLKit/GLKit.h>

@implementation TextureShader

- (void)manageAttributeLocationsForShader:(GLuint)shader ofType:(GLenum)type {

	if (type == GL_VERTEX_SHADER) {
		glBindAttribLocation(shader, GLKVertexAttribTexCoord0, "TexCoordIn");
		glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
	}
	else {
		_textureIndex.textureUniform = glGetUniformLocation(shader, "Texture");
	}
}


@end
