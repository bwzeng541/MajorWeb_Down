
#ifndef Header_h
#define Header_h
#define MajorDataSource @"www.webvaildUrl.com"
#define MajorPlugKey @"MajorZyCartoonPlug"
#define sendWebJsNodeMessageZySort @"sendWebJsNodeMessageZySort"

void initYYCache(NSString*name);
void syncCartoonList(NSArray *arraylist ,NSString*cartName, NSString *dataSource);
void syncCartoonHistory(NSString*url ,NSString*cartName,NSString *dataSource);

void syncCartoonFavourite(NSString*cartName,NSString *dataSource);

//通过漫画key找列表
NSArray* getCartList(NSString*key);
//通过漫画key找名字
NSString* getCartName(NSString*key);
//按时间排序返回所有key
NSArray* getAllCartKey(void);
NSString* getCartoonHistory(NSString *key);
//所有收藏
NSArray* getCartoonFavouriteKey(void);

void delCartoonFavouriteKey(NSString*key);
#endif /* Header_h */
