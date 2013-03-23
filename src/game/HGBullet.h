#import "HGLTypes.h"
#import "HGLGraphics2D.h"

namespace HGGame {
    namespace actor {
    
        enum HG_BULLET_TYPE {
            HG_BULLET_N1,
            HG_BULLET_N2
        };
        
        class HGActor;
        class HGBullet : public HGActor
        {
        public:
            HGBullet();
            ~HGBullet();
            void draw();
            void update();
            void init(HG_BULLET_TYPE type);
            
        private:
            HG_BULLET_TYPE type;
            int updateCount;
            bool isTextureInit;
            hgles::HGLTexture core;
            hgles::HGLTexture glow;
        };
    }
    
}
