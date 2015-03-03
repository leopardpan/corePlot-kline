//
//  StockHeard.h
//  kline
//
//  Created by leopard on 15-3-3.
//  Copyright (c) 2015年 leopard. All rights reserved.
//

#ifndef kline_StockHeard_h
#define kline_StockHeard_h


struct StockPadding {
    
    CGFloat left;
    CGFloat top;
    CGFloat right;
    CGFloat bottom;
};
typedef struct StockPadding StockPadding;

struct StockDrawInfo {
    BOOL showLeft;
    BOOL showRight;
    BOOL showTop;
    BOOL showBottom;
    BOOL showHorizontal;
};
typedef struct StockDrawInfo StockDrawInfo;

struct StockGesture
{
    BOOL tap;
    BOOL pan;
    BOOL pinch;
};
typedef struct StockGesture StockGesture;

typedef enum
{
    EM_MARKET_ID_NORMAL_ALL = 0,
    EM_MARKET_ID_MIN = 0,
    
    EM_MARKET_ID_NORMAL_MIN = 0,
    EM_MARKET_ID_SZ,
    EM_MARKET_ID_SH,
    EM_MARKET_ID_SB,
    EM_MARKET_ID_NORMAL_MAX,
    
    EM_MARKET_ID_FT_MIN = 10,
    EM_MARKET_ID_FT_ZCE,
    EM_MARKET_ID_FT_DCE,
    EM_MARKET_ID_FT_CFFEX,
    EM_MARKET_ID_FT_SH,
    EM_MARKET_ID_FT_MAX,
    
    EM_MARKET_ID_MAX,
    EM_MARKET_ID_FT_SHZQ = EM_MARKET_ID_MAX
    
}MarketID;

#endif
