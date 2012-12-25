//
//  Shader.vsh
//  Game
//
//  Created by Landon on 11/26/12.
//  Copyright (c) 2012 Landon. All rights reserved.
//

attribute vec4 position;
attribute vec3 normal;

varying lowp vec4 colorVarying;

uniform mat4 modelViewProjectionMatrix;
uniform mat3 normalMatrix;

attribute vec2 TexCoordIn;
varying vec2 TexCoordOut;

void main()
{
    vec3 eyeNormal = normalize(normalMatrix * normal);
    vec3 lightPosition = vec3(0.0, 1.0, 1.0);
    vec4 diffuseColor = vec4(1.5, 1.5, 1.5, 1.0);
    
    float nDotVP = max(.4, dot(eyeNormal, normalize(lightPosition)));
                 
    colorVarying = diffuseColor * nDotVP;
    
    gl_Position = modelViewProjectionMatrix * position;
	
	TexCoordOut = TexCoordIn;
}
