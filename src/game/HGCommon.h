#define IS_DEBUG_COLLISION 0

// game define
#define ENEMY_NUM 100
#define BULLET_NUM 200
#define ENEMY_BULLET_NUM 200
#define FIELD_SIZE 100
#define ZPOS 0
#define BACKGROUND_SCALE 1000
#define STAGE_SCALE 100
#define SCRATE 0.01

// util
#define HDebug(A, ...) NSLog(@"[Debug] Func:%s\tLine:%d\t%@", __PRETTY_FUNCTION__,__LINE__,[NSString stringWithFormat:A, ## __VA_ARGS__]);
#define HInfo(A, ...) NSLog(@"[Info] Func:%s\tLine:%d\t%@", __PRETTY_FUNCTION__,__LINE__,[NSString stringWithFormat:A, ## __VA_ARGS__]);
#define HError(A, ...) NSLog(@"[###ERROR###] Func:%s\tLine:%d\t%@", __PRETTY_FUNCTION__,__LINE__,[NSString stringWithFormat:A, ## __VA_ARGS__]);

namespace HGGame {
    
    typedef struct t_rect
    {
        float x, y, w, h;
    } t_rect;
    
    typedef struct t_size2d
    {
        float w, h;
    } t_size2d;
    
    typedef struct t_pos2d
    {
        float x, y;
    } t_pos2d;
    
    
}
