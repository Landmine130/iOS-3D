//
//  Shader.fsh
//  Game
//
//  Created by Landon on 11/26/12.
//  Copyright (c) 2012 Landon. All rights reserved.
//

varying lowp vec4 colorVarying;

varying lowp vec2 TexCoordOut;
uniform sampler2D Texture;

void main()
{
    gl_FragColor = colorVarying * texture2D(Texture, TexCoordOut);
}
