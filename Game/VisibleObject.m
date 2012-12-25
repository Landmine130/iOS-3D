//
//  Object.m
//  TestGame
//
//  Created by Landon on 8/11/12.
//  Copyright (c) 2012 Landon. All rights reserved.
//

#import "VisibleObject.h"
#import "clawForLandon.h"
#import "pokeball.h"
#import "ModelData.h"
#import "TextureShader.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

@implementation VisibleObject

- (id)initWithModelName:(NSString *)name {
	
	self.hidden = NO;
	[ModelData loadModelDataForName:name synchronized:YES];
	ModelData *modelData = [ModelData modelDataForName:name];
	GLuint texture = [VisibleObject textureForFilePath:name];
	Shader *shader;
	
	if (modelData.textureMapCount) {
		shader = [[TextureShader alloc] init];
	}
	else {
		shader = [[Shader alloc] init];
	}
	
	if (self = [self initWithVertexArray:modelData.data vertexCount:modelData.vertexCount normalCount:modelData.normalCount textureMapCount:modelData.textureMapCount texture:texture shader:shader]) {
		
	}
	
	[shader release];
	
	return self;
}

// Future optimization: share buffers for objects that use the same model
- (id)initWithVertexArray:(GLfloat *)data vertexCount:(int)vertexCount normalCount:(int)normalCount textureMapCount:(int)textureMapCount texture:(GLuint)texture shader:(Shader *)shader {
	if (self = [super init]) {

		self.hidden = NO;
		self.texture = texture;
		self.shader = shader;
		
		glGenVertexArraysOES(1, &_vertexArray);

		[self setVertexArray:data vertexCount:vertexCount normalCount:normalCount textureMapCount:textureMapCount];
	}
	return self;
}

- (void)setVertexArray:(float *)data vertexCount:(int)vertexCount normalCount:(int)normalCount textureMapCount:(int)textureMapCount {
	
	_vertexCount = vertexCount;
	_normalCount = normalCount;
	_textureMapCount = textureMapCount;
	_totalDataCount = ((vertexCount + normalCount) * 3 + textureMapCount * 2);
	_data = data;
	
	glBindVertexArrayOES(_vertexArray);
	
	glDeleteBuffers(1, &_vertexBuffer);
	
	glGenBuffers(1, &_vertexBuffer);
	glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
	
	glBufferData(GL_ARRAY_BUFFER, (vertexCount * 3 + normalCount * 3 + textureMapCount * 2) * sizeof(GLfloat), data, GL_STATIC_DRAW);
	
	glEnableVertexAttribArray(GLKVertexAttribPosition);
	glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 0, BUFFER_OFFSET(0));
	glEnableVertexAttribArray(GLKVertexAttribNormal);
	glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 0, BUFFER_OFFSET(vertexCount * sizeof(GLfloat) * 3));
	if (_texture && textureMapCount) {
		glBindTexture(GL_TEXTURE_2D, _texture);
		glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
		glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 0, BUFFER_OFFSET((vertexCount + normalCount) * 3 * sizeof(GLfloat)));
	}
	glBindVertexArrayOES(0);
}

+ (GLuint)textureForFilePath:(NSString *)fileName {
    // 1
	fileName = [fileName stringByAppendingString:@".jpg"];
    CGImageRef spriteImage = [UIImage imageNamed:fileName].CGImage;
    if (!spriteImage) {
        NSLog(@"Failed to load image %@", fileName);
        exit(1);
    }
	
    // 2
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
	
    GLubyte * spriteData = (GLubyte *) calloc(width*height*4, sizeof(GLubyte));
	
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4,
													   CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
	
    // 3
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spriteImage);
	
    CGContextRelease(spriteContext);
	
    // 4
    GLuint texName;
    glGenTextures(1, &texName);
    glBindTexture(GL_TEXTURE_2D, texName);
	
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
	
    free(spriteData);
	glBindTexture(GL_TEXTURE_2D, 0);
	
    return texName;
}

-(void)dealloc {
	glDeleteBuffers(1, &_vertexBuffer);
    glDeleteVertexArraysOES(1, &_vertexArray);
	self.shader = nil;
	
	[super dealloc];
}

@end
