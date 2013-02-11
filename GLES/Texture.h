//
//  IndexBuffer.h
//  Shooter
//
//  Created by 濱田 洋太 on 12/12/24.
//  Copyright (c) 2012年 hayogame. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLTypes.h"
#import <string>
#import <GLKit/GLKit.h>

class Texture
{
public:
    static Texture* createTextureWithAsset(std::string name);
    Texture();
    void bind();
    void unbind();
    void setTextureArea(int textureW,int textureH, int x, int y, int w, int h);
    ~Texture();
    
private:
    GLuint textureId;
    size_t width;
    size_t height;
    GLKMatrix4 textureMatrix;
};
