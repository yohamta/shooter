#define IS_DEBUG 0
#define IS_BACKGROUND 1
#define IS_ALLYVIEW 1
#define IS_STATUS 1
#define IS_GAME_MAIN 1
#define IS_GAME_GL 1
#define IS_BUTTON_ANIME 1
#define IS_BUTTON_IMAGE 1
#define IS_PLAYER_DETAIL 1
#define IS_GAME_EXEC 1
#define IS_REPORT 1
#define IS_BGM 1
#define IS_MENU_REUSE 1
#define IS_STATUS_REUSE 1
#define IS_REPORT_REUSE 1

#define STR2NSSTR(a) [NSString stringWithCString:a.c_str() encoding:NSUTF8StringEncoding]
#define NSSTR2STR(a) std::string([a UTF8String])

#define MAIN_FONT_COLOR [UIColor colorWithHexString:@"#7deded"]
#define MAIN_BORDER_COLOR [UIColor colorWithHexString:@"#7deded"]
#define SUB_FONT_COLOR [UIColor colorWithHexString:@"#55aa55"]
#define SUB_BACK_COLOR [UIColor colorWithHexString:@"#aaffaa"]

#define BGM_BOSS @"game_maoudamashii_2_lastboss03.mp3"
#define BGM_BATTLE @"game_maoudamashii_1_battle21.mp3"
#define BGM_MENU @"game_maoudamashii_4_field07.mp3"
#define BGM_CLEAR @"game_maoudamashii_9_jingle05.mp3"

#define SE_CLICK @"Flashpoint001a.caf"
#define SE_GUN @"silencer.caf"
#define SE_HIT @"tm2_hit000.caf"
#define SE_BOM @"tm2_bom002.caf"
#define SE_ENEMY_APPROACH @"EnemiesApproaching.caf"
#define SE_ENEMY_ELIMINATED @"EnemyEliminated.caf"
#define SE_UNITLOST @"UnitLost.caf"

#define ICON_CHECK @"ic_check"
#define ICON_SELECT_ALL @"ic_select_all"
#define ICON_DESELECT @"ic_deselect"
#define ICON_SORT @"ic_sort"

#define ADDMOB_PUBLISHER_ID @"a1522432707c35f"
#define GAMEFEAT_MEDIA_ID @"2344"

#if IS_DEBUG
#define IS_GAMEFEAT 0
#define IS_MEDIBAAD 0
#define IS_MAIN_ADMOB 1
#define IS_PLAYER_DETAIL_ADMOB 0
#define IS_REPORT_VIEW_ADMOB 1
#else
#define IS_GAMEFEAT 0
#define IS_MEDIBAAD 0
#define IS_MAIN_ADMOB 1
#define IS_PLAYER_DETAIL_ADMOB 0
#define IS_REPORT_VIEW_ADMOB 1
#endif

#define MENU_ANIMATION_DURATION 0.2

