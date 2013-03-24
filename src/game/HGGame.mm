#import "HGGame.h"
#import "HGLES.h"
#import "HGUtil.h"
#import "HGLObject3D.h"
#import "HGLObjLoader.h"
#import "HGExplode.h"
#import "HGHit.h"
#import "HGLTexture.h"
#import "HGLVector3.h"
#import "HGActor.h"
#import "HGFighter.h"
#import "HGCPU.h"
#import "HGPlayer.h"
#import "HGBullet.h"
#import "HGCommon.h"
#import "HGCollision.h"
#import "HGHitAnime.h"

#import <vector>
#import <map>
//#import <mutex>

namespace HGGame {
    
    class RemoveActor
    {
    public:
        bool operator()(HGActor* a) const { return !a->isActive; }
    };
    
    // flag
    bool fire;
    double lastFireTime;
    float fireDegree;
    
    // game objects
    HGPlayer* _player;
    
    typedef std::vector<HGActor*> T_ACTOR_VEC;
    typedef std::vector<HGActor*>* T_ACTOR_VEC_PTR;
    
    std::vector<HGBullet*> _bullets;
    std::vector<HGBullet*> _bulletsInActive;
    std::vector<HGBullet*> _enemyBullets;
    std::vector<HGBullet*> _enemyBulletsInActive;
    std::vector<HGFighter*> _enemies;
    std::vector<HGFighter*> _friends;
    std::vector<hgles::t_hgl2di*> background;
    std::vector<hgles::t_hgl2di*> barriar;
    std::vector<hgles::t_hgl2di*> nebula;
    std::vector<HGActor*> _effects;
    
    // camera
    hgles::HGLVector3 _cameraPosition;
    hgles::HGLVector3 _cameraRotate;
    
    unsigned int updateCount;
    
    // now
    double now_time;
    
    // center of field
    t_pos2d center_of_field;
    
    // size of field
    t_size2d size_of_field;
    
    // フィールド
    hgles::t_hgl2di* field;
    float field_alpha_diff = -0.05;
    hgles::Color field_color_diff = {0.02, 0.05, 0.02, 1};
    
    // あたり判定
#define COL_FLD_SPLIT_NUM 5 
    typedef std::map<int, std::vector<HGActor*>> T_COL_LIST;
    typedef std::map<int, std::vector<HGActor*>>* T_COL_LIST_PTR;
    T_COL_LIST col_bullets;
    T_COL_LIST col_enemyBullets;
    t_size2d size_of_cell = {FIELD_SIZE/COL_FLD_SPLIT_NUM, FIELD_SIZE/COL_FLD_SPLIT_NUM};
    
    //pthread_mutex_t	mutex;  // MUTEX
    
    int rand(int from, int to)
    {
        int r = std::rand()%(to - from);
        return r+from;
    }
    
    void onMoveLeftPad(int degree, float power)
    {
        if (_player)
        {
            if (power > 0)
            {
                if (!fire) _player->setDirectionWithDegree(degree);
                _player->setMoveDirectionWithDegree(degree);
            }
            _player->setVelocityWithPower(power);
        }
    }
    
    double getNowTime()
    {
        return now_time;
    }
    
    HGBullet* getBullet(WHICH_SIDE side)
    {
        switch (side) {
            case FRIEND_SIDE:
                if (_bulletsInActive.size() > 0)
                {
                    HGBullet* t = _bulletsInActive.back();
                    _bulletsInActive.pop_back();
                    _bullets.push_back(t);
                    return t;
                }
                return NULL;
            case ENEMY_SIDE:
                if (_enemyBulletsInActive.size() > 0)
                {
                    HGBullet* t = _enemyBulletsInActive.back();
                    _enemyBulletsInActive.pop_back();
                    _enemyBullets.push_back(t);
                    return t;
                }
                return NULL;
            default:
                assert(0);
        }
    }
    
    bool is_out_of_field(hgles::HGLVector3* position, t_size2d* size)
    {
        t_size2d* field_size = get_size_of_field();
        if (position->x + size->w/2 > field_size->w)
        {
            return true;
        }
        if (position->y + size->h/2 > field_size->h)
        {
            return true;
        }
        if (position->x - size->w/2 < 0)
        {
            return true;
        }
        if (position->y - size->h/2 < 0)
        {
            return true;
        }
        return false;
    }
    
    t_size2d* get_size_of_field()
    {
        return &size_of_field;
    }
    
    t_pos2d* get_center_of_field()
    {
        return &center_of_field;
    }
    
    int get_cell_of_pointer(t_pos2d* s)
    {
        if (s->x < 0 || s->y < 0) return -1;
        if (s->x > size_of_field.w || s->y > size_of_field.h) return -1;
        int wx = (int)(s->x / size_of_cell.w);
        int wy = (int)(s->y / size_of_cell.h);
        return wx + wy * COL_FLD_SPLIT_NUM;
    }
    
    void registerActorToColList(HGActor* actor, T_COL_LIST_PTR col_list)
    {
        t_size2d* size = &actor->realSize;
        t_pos2d tmp_pos = {actor->position.x, actor->position.y};
        tmp_pos.x -= size->w/2;
        tmp_pos.y -= size->h/2;
        while (1)
        {
            int num = get_cell_of_pointer(&tmp_pos);
            if (num > 0)
            {
                (*col_list)[num].push_back(actor);
            }
            tmp_pos.x += size_of_cell.w;
            if (tmp_pos.x > actor->position.x + size->w/2)
            {
                tmp_pos.y += size_of_cell.h;
                if (tmp_pos.y > actor->position.y + size->h/2)
                {
                    break;
                }
            }
        }
    }
    
    void registerActorToColListForSmall(HGActor* actor, T_COL_LIST_PTR col_list)
    {
        t_pos2d tmp_pos = {actor->position.x, actor->position.y};
        int num = get_cell_of_pointer(&tmp_pos);
        if (num >= 0)
        {
            (*col_list)[num].push_back(actor);
        }
    }
    
    void getCellList(HGActor* actor, std::vector<int>* list)
    {
        t_size2d* size = &actor->realSize;
        t_pos2d tmp_pos = {actor->position.x, actor->position.y};
        while (1)
        {
            list->push_back(get_cell_of_pointer(&tmp_pos));
            tmp_pos.x += size_of_cell.w;
            if (tmp_pos.x > actor->position.x + size->w/2)
            {
                tmp_pos.y += size_of_cell.h;
                if (tmp_pos.y > actor->position.y + size->h/2)
                {
                    break;
                }
            }
        }
        
    }
    
    void initialize()
    {
        srand((unsigned int)time(NULL));
        updateCount = 0;
        initSpriteIndexTable();
        initializeCollision();
        size_of_field = {FIELD_SIZE, FIELD_SIZE};
        center_of_field = {FIELD_SIZE/2, FIELD_SIZE/2};
        
        // create players
        _player = new HGPlayer();
        _player->init(HG_FIGHTER, FRIEND_SIDE);
        _player->position.set(center_of_field.x, center_of_field.y, ZPOS);
        _player->setDirectionWithDegree(0);
        fire = false;
        _friends.push_back(_player);
        
        // create enemies
        for (int i = 0; i < ENEMY_NUM; ++i)
        {
            HGCPU* t;
            t = new HGCPU();
            t->init(HG_FIGHTER, ENEMY_SIDE);
            t->position.x = (i*2) + -2 + center_of_field.x;
            t->position.y = 1 + center_of_field.y;
            t->position.z = ZPOS;
#warning 仮
            t->target = _player;
            _enemies.push_back(t);
        }
        
        // create bullets
        for (int i = 0; i < BULLET_NUM; ++i)
        {
            HGBullet* t;
            t = new HGBullet();
            _bulletsInActive.push_back(t);
        }
        
        // create bullets
        for (int i = 0; i < ENEMY_BULLET_NUM; ++i)
        {
            HGBullet* t;
            t = new HGBullet();
            _enemyBulletsInActive.push_back(t);
        }
        
        // create background
        for (int i = 0; i < 5; ++i)
        {
            hgles::t_hgl2di* t = new hgles::t_hgl2di();
            t->texture = *hgles::HGLTexture::createTextureWithAsset("space.png");
            t->texture.repeatNum = 1;
            t->scale.set(BACKGROUND_SCALE, BACKGROUND_SCALE, BACKGROUND_SCALE);
            switch (i) {
                case 0:
                    t->position.set(-1*BACKGROUND_SCALE/2+center_of_field.x, center_of_field.y, ZPOS);
                    t->rotate.set(0, 90*M_PI/180, 0);
                    break;
                case 1:
                    t->position.set(BACKGROUND_SCALE/2+center_of_field.x, center_of_field.y, ZPOS);
                    t->rotate.set(0, -90*M_PI/180, 180*M_PI/180);
                    break;
                case 2:
                    t->position.set(center_of_field.x, BACKGROUND_SCALE/2+center_of_field.y, ZPOS);
                    t->rotate.set(-90*M_PI/180, 0, 0);
                    break;
                case 3:
                    t->position.set(center_of_field.x, -BACKGROUND_SCALE/2+center_of_field.y, ZPOS);
                    t->rotate.set(90*M_PI/180, 0, 0);
                    break;
                case 4:
                    t->position.set(center_of_field.x, center_of_field.y, -1*BACKGROUND_SCALE/2 + ZPOS);
                    t->rotate.set(0, 0, 0);
                    break;
                    /*
                case 5:
                    t->position.set(0, 0, 1*BACKGROUND_SCALE/2 + ZPOS);
                    t->rotate.set(180*M_PI/180, 0, 0);
                    break;*/
                default:
                    break;
            }
            background.push_back(t);
        }
        
        // create deep sky
        for (int i = 0; i < 2; ++i)
        {
            hgles::t_hgl2di* t = new hgles::t_hgl2di();
            t->texture = *hgles::HGLTexture::createTextureWithAsset("space_a.png");
            t->texture.repeatNum = 1;
            t->texture.blendColor = {2.0, 2.0, 2.0, 1.0};
            t->scale.set(500, 500, 300);
            int x = rand(0, 20) * (rand(0, 1)?-1:1);
            int y = rand(0, 20) * (rand(0, 1)?-1:1);
            int rz = rand(0, 360) * (rand(0, 1)?-1:1);
            t->position.set(x+center_of_field.x, y+center_of_field.y, -200 + ZPOS + i * 20);
            t->rotate.set(0, 0, rz*M_PI/180);
            nebula.push_back(t);
        }
        
        
        // create nebula
        for (int i = 0; i < 1; ++i)
        {
            int SIZE = rand(500, 650);
            hgles::t_hgl2di* t = new hgles::t_hgl2di();
            t->texture = *hgles::HGLTexture::createTextureWithAsset("proc_sheet_nebula.png");
            t->texture.repeatNum = 1;
            t->texture.color = {1.0, 1.0, 1.0, 0.6};
            t->texture.blendColor = {0.7, 0.7, 0.7, 0.6};
            t->texture.sprWidth = 256;
            t->texture.sprHeight = 256;
            t->texture.setTextureArea(rand(0,4)*256, rand(0,4)*256, 256, 256);
            t->scale.set(SIZE, SIZE, SIZE);
            int x = rand(0, STAGE_SCALE);
            int y = rand(0, STAGE_SCALE);
            t->position.set(x+center_of_field.x, y+center_of_field.y, -1*BACKGROUND_SCALE/2 + ZPOS);
            t->rotate.set(0, 0, rand(0, 360)*M_PI/180);
            nebula.push_back(t);
        }
        
        // フィールド境界
        field = new hgles::t_hgl2di();
        field->texture = *hgles::HGLTexture::createTextureWithAsset("rect.png");
        field->texture.blendColor = {2.0, 2.0, 2.0, 1.0};
        field->texture.color = {1,1,1,1};
        field->scale.set(FIELD_SIZE*2, FIELD_SIZE*2, 1);
        field->position.set(center_of_field.x, center_of_field.y, ZPOS);
        
    }
    
    
    void update(t_keystate* keystate)
    {
        //pthread_mutex_lock(&mutex); // スレッド保護
        //try {
        
            // 現在時間の更新
        NSDate* nowDt = [NSDate date];
        now_time = [nowDt timeIntervalSince1970];
        ++updateCount;
        
        // あたり判定
        col_bullets.clear();
        col_enemyBullets.clear();
        
        if (_player)
        {
            if (keystate->fire)
            {
                fire = true;
                fireDegree = _player->degree;
            }
            else
            {
                fire = false;
            }
            
            if (fire && _player->isActive)
            {
                _player->fire();
            }
        }
        
        // move friends
        for (std::vector<HGFighter*>::iterator itr = _friends.begin(); itr != _friends.end(); ++itr)
        {
            HGFighter* a = *itr;
            a->update();
            
#warning hgfighterに移動
            if (a->life <= 0)
            {
                a->explodeCount--;
                if (a->explodeCount == 0)
                {
                    a->isActive = false;
                    createEffect(EFFECT_EXPLODE_NORMAL, &a->position);
                }
                else if (a->explodeCount%3 == 0)
                {
                    hgles::HGLVector3 pos = a->getRandomRealPosition();
                    createEffect(EFFECT_EXPLODE_NORMAL, &pos);
                }
            }
        }
        
        // move enemies
        for (std::vector<HGFighter*>::iterator itr = _enemies.begin(); itr != _enemies.end(); ++itr)
        {
            HGFighter* a = *itr;
            a->update();
            
#warning hgfighterに移動
            if (a->life <= 0)
            {
                a->explodeCount--;
                if (a->explodeCount == 0)
                {
                    a->isActive = false;
                    createEffect(EFFECT_EXPLODE_NORMAL, &a->position);
                }
                else if (a->explodeCount%3 == 0)
                {
                    hgles::HGLVector3 pos = a->getRandomRealPosition();
                    createEffect(EFFECT_EXPLODE_NORMAL, &pos);
                }
            }
        }
        
        // move bullets
        for (std::vector<HGBullet*>::iterator itr = _bullets.begin(); itr != _bullets.end(); ++itr)
        {
            HGBullet* a = *itr;
            a->update();
            registerActorToColListForSmall(a, &col_bullets);
        }
        
        // move bullets
        for (std::vector<HGBullet*>::iterator itr = _enemyBullets.begin(); itr != _enemyBullets.end(); ++itr)
        {
            HGBullet* a = *itr;
            a->update();
            registerActorToColListForSmall(a, &col_enemyBullets);
        }
        
        // update effects
        for (std::vector<HGActor*>::reverse_iterator itr = _effects.rbegin(); itr != _effects.rend(); ++itr)
        {
            HGActor* a = *itr;
            a->update();
        }
        
        //////////////
        // あたり判定
        //////////////
        
        // collision check (enemy with bullet)
        std::vector<int> tmp_colcell_list;
        for (std::vector<HGFighter*>::iterator itr = _enemies.begin(); itr != _enemies.end(); ++itr)
        {
            HGFighter* a = *itr;
            if (a->life <= 0)
            {
                continue;
            }
            
            tmp_colcell_list.clear();
            getCellList(a, &tmp_colcell_list);
            for (std::vector<int>::iterator itr2 = tmp_colcell_list.begin(); itr2 != tmp_colcell_list.end(); ++itr2)
            {
                int num = *itr2;
                T_ACTOR_VEC_PTR bullets = &col_bullets[num];
                for (T_ACTOR_VEC::iterator itr3 = bullets->begin(); itr3 != bullets->end(); ++itr3)
                {
                    HGBullet* b = (HGBullet*)*itr3;
                    if (a->isCollideWith(b))
                    {
                        b->isActive = false;
#warning 仮
                        a->life--;
                        if (a->life == 0)
                        {
                            createEffect(EFFECT_EXPLODE_NORMAL, &a->position);
                        }
                        else
                        {
                            createEffect(EFFECT_HIT_NORMAL, &a->position);
                        }
                    }
                }
            }
            
        }
        
        // collision check (friends with bullet)
        for (std::vector<HGFighter*>::iterator itr = _friends.begin(); itr != _friends.end(); ++itr)
        {
            HGFighter* a = *itr;
            
            if (a->life <= 0)
            {
                continue;
            }
            
            tmp_colcell_list.clear();
            getCellList(a, &tmp_colcell_list);
            for (std::vector<int>::iterator itr2 = tmp_colcell_list.begin(); itr2 != tmp_colcell_list.end(); ++itr2)
            {
                int num = *itr2;
                T_ACTOR_VEC_PTR bullets = &col_enemyBullets[num];
                
                for (T_ACTOR_VEC::iterator itr3 = bullets->begin(); itr3 != bullets->end(); ++itr3)
                {
                    HGBullet* b = (HGBullet*)*itr3;
                    if (a->isCollideWith(b))
                    {
                        b->isActive = false;
#warning 仮
                        a->life--;
                        if (a->life == 0)
                        {
                            createEffect(EFFECT_EXPLODE_NORMAL, &a->position);
                        }
                        else
                        {
                            createEffect(EFFECT_HIT_NORMAL, &a->position);
                        }
                    }
                }
            }
            
        }
        
        //////////////
        // フィールドの境界設定
        //////////////
        
        field->texture.color.a += field_alpha_diff;
        if (field->texture.color.a < 0.2)
        {
            field_alpha_diff *= -1;
            field->texture.color.a = 0.2;
        }
        if (field->texture.color.a > 1)
        {
            field_alpha_diff *= -1;
            field->texture.color.a = 1;
        }
        field->texture.blendColor.r += field_color_diff.r;
        field->texture.blendColor.g += field_color_diff.g;
        field->texture.blendColor.b += field_color_diff.b;
        if (field->texture.blendColor.b > 2)
        {
            field->texture.blendColor.b = 2;
            field_color_diff.r *= -1;
            field_color_diff.g *= -1;
            field_color_diff.b *= -1;
        }
        else if (field->texture.blendColor.b < 0.5)
        {
            field->texture.blendColor.b  = 0.5;
            field_color_diff.r *= -1;
            field_color_diff.g *= -1;
            field_color_diff.b *= -1;
        }
        
        //////////////
        // 不要オブジェクト削除
        //////////////
        {
            for (std::vector<HGBullet*>::iterator itr = _bullets.begin(); itr != _bullets.end(); ++itr)
            {
                if (!(*itr)->isActive)
                {
                    _bulletsInActive.push_back(*itr);
                }
            }
            std::vector<HGBullet*>::iterator end_it = remove_if( _bullets.begin(), _bullets.end(), RemoveActor() );
            _bullets.erase( end_it, _bullets.end() );
        }
        
        {
            for (std::vector<HGBullet*>::iterator itr = _enemyBullets.begin(); itr != _enemyBullets.end(); ++itr)
            {
                if (!(*itr)->isActive)
                {
                    _enemyBulletsInActive.push_back(*itr);
                }
            }
            std::vector<HGBullet*>::iterator end_it = remove_if( _enemyBullets.begin(), _enemyBullets.end(), RemoveActor() );
            _enemyBullets.erase( end_it, _enemyBullets.end() );
        }
        
        {
            std::vector<HGFighter*> tmp;
            for (std::vector<HGFighter*>::iterator itr = _enemies.begin(); itr != _enemies.end(); ++itr)
            {
                if (!(*itr)->isActive)
                {
                    tmp.push_back(*itr);
                }
            }
            std::vector<HGFighter*>::iterator end_it = remove_if( _enemies.begin(), _enemies.end(), RemoveActor() );
            _enemies.erase( end_it, _enemies.end() );
            for (std::vector<HGFighter*>::iterator itr = tmp.begin(); itr != tmp.end(); ++itr)
            {
                delete (*itr);
            }
        }
        
        {
            std::vector<HGFighter*> tmp;
            for (std::vector<HGFighter*>::iterator itr = _enemies.begin(); itr != _enemies.end(); ++itr)
            {
                if (!(*itr)->isActive)
                {
                    tmp.push_back(*itr);
                    if (_player == *itr)
                    {
                        _player = NULL;
                    }
                }
            }
            std::vector<HGFighter*>::iterator end_it = remove_if( _friends.begin(), _friends.end(), RemoveActor() );
            _friends.erase( end_it, _friends.end() );
            for (std::vector<HGFighter*>::iterator itr = tmp.begin(); itr != tmp.end(); ++itr)
            {
                delete (*itr);
            }
        }
        
        /*
        }
        catch (...) // 全例外をキャッチ
        {
            HDebug(@"some error happed");
        }
        pthread_mutex_unlock(&mutex);*/
        
    }
    
    void createEffect(EFFECT_TYPE type, hgles::HGLVector3* position)
    {
        switch (type) {
            case EFFECT_HIT_NORMAL:
            {
                HGHitAnime* ex = new HGHitAnime();
                ex->init();
                ex->position = *position;
                _effects.push_back((HGActor*)ex);
                break;
            }
            case EFFECT_EXPLODE_NORMAL:
            {
                HGExplode* ex = new HGExplode();
                ex->init();
                ex->position = *position;
                _effects.push_back((HGActor*)ex);
                break;
            }
            default:
                assert(0);
        }
        
    }
    
    
    void render()
    {
        /*
        pthread_mutex_lock(&mutex); // スレッド保護
        try {*/
            
        // 光源なし
        glUniform1f(hgles::HGLES::uUseLight, 0.0);
        
        // set camera
        if (_player)
        {
            _cameraPosition.x = _player->position.x * -1;
            _cameraPosition.y = _player->position.y * -1;
            _cameraPosition.z = -20;
            //_cameraRotate.x = -28 * M_PI/180;
            hgles::HGLES::cameraPosition = _cameraPosition;
            hgles::HGLES::cameraRotate = _cameraRotate;
            hgles::HGLES::updateCameraMatrix();
        }
        
        // 2d
        glDisable(GL_DEPTH_TEST);
        
            // draw bg
            /*
             for (std::vector<HGObject*>::reverse_iterator itr = _background.rbegin(); itr != _background.rend(); ++itr)
             {
             HGObject* a = *itr;
             a->draw();
             }*/
        
        hgles::HGLES::pushMatrix();
        hgles::HGLES::mvMatrix = GLKMatrix4Rotate(hgles::HGLES::mvMatrix, hgles::HGLES::cameraRotate.x*-1, 1, 0, 0);
        hgles::HGLES::mvMatrix = GLKMatrix4Rotate(hgles::HGLES::mvMatrix, hgles::HGLES::cameraRotate.y*-1, 0, 1, 0);
        
        // draw bg
        for (std::vector<hgles::t_hgl2di*>::reverse_iterator itr = background.rbegin(); itr != background.rend(); ++itr)
        {
            hgles::HGLGraphics2D::draw(*itr);
        }
        
        // draw nebula
        for (std::vector<hgles::t_hgl2di*>::reverse_iterator itr = nebula.rbegin(); itr != nebula.rend(); ++itr)
        {
            hgles::HGLGraphics2D::draw(*itr);
        }
        
        hgles::HGLES::popMatrix();
        
        // draw field
        hgles::HGLGraphics2D::draw(field);
        
        // draw enemies
        for (std::vector<HGFighter*>::reverse_iterator itr = _enemies.rbegin(); itr != _enemies.rend(); ++itr)
        {
            HGFighter* a = *itr;
            a->draw();
#if IS_DEBUG_COLLISION
            a->drawCollision();
#endif
        }
        
        // draw bullets
        for (std::vector<HGBullet*>::reverse_iterator itr = _bullets.rbegin(); itr != _bullets.rend(); ++itr)
        {
            HGBullet* a = *itr;
            a->draw();
#if IS_DEBUG_COLLISION
            a->drawCollision();
#endif
        }
        
        for (std::vector<HGBullet*>::reverse_iterator itr = _enemyBullets.rbegin(); itr != _enemyBullets.rend(); ++itr)
        {
            HGBullet* a = *itr;
            a->draw();
#if IS_DEBUG_COLLISION
            a->drawCollision();
#endif
        }
        
        // draw friends
        for (std::vector<HGFighter*>::reverse_iterator itr = _friends.rbegin(); itr != _friends.rend(); ++itr)
        {
            HGFighter* a = *itr;
            a->draw();
#if IS_DEBUG_COLLISION
            a->drawCollision();
#endif
        }
        
        // draw effects
        for (std::vector<HGActor*>::reverse_iterator itr = _effects.rbegin(); itr != _effects.rend(); ++itr)
        {
            HGActor* a = *itr;
            a->draw();
        }
        
        /*
        }
        catch (...) // 全例外をキャッチ
        {
            HDebug(@"some error happed");
        }
        pthread_mutex_unlock(&mutex);
        */
    }
    
    
}
