#import "HGLObject3D.h"
#import "HGLVector3.h"
#import "HGLTexture.h"

class HGActor
{
public:
    HGActor():
        velocity(0),
        aspect(0),
        moveAspect(0),
        scale(1,1,1),
        rotate(0,0,0),
        position(0,0,0),
        acceleration(0,0,0),
        object3d(NULL),
        useLight(false),
        alpha(1.0),
        textureRepeatNum(1),
        texture(NULL){}
    
    virtual void draw();
    void move();
    void setVelocity(float velocity);
    virtual void setAspect(float degree);
    void setTextureArea(int x, int y, int w, int h);
    void setObject3D(HGLObject3D* obj);
    void setObject3D(HGLObject3D* obj, HGLTexture* tex);
    void setMoveAspect(float degree);
    
    ~HGActor();
    
    HGLVector3 position;
    HGLVector3 rotate;
    HGLVector3 scale;
    float velocity; // 速度
    float aspect; // radian
    float moveAspect; // radian
    float alpha; // alpha
    float textureRepeatNum;
    
protected:
    bool useLight; // 光源
    HGLTexture* texture;
    
private:
    HGLObject3D* object3d; // 3Dオブジェクト
    HGLVector3 acceleration; // 加速
    // スプライト処理用
    GLKMatrix4 textureMatrix;
    
};
