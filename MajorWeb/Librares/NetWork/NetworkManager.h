//
//  NetworkManager.h
//  qiangche
//
//  Created by ios-mac on 15/8/19.
//
//

#import <Foundation/Foundation.h>

typedef void (^ReturnBlock)(NSDictionary *returnDict);

@interface NetworkManager : NSObject

@property (strong, nonatomic)ReturnBlock returnBlock;

+ (NetworkManager *)shareInstance;


- (NSURLSessionDataTask *)getInfoFromUrl:(NSString *)url callback:(ReturnBlock)infoBlock;
- (NSURLSessionDataTask *)getInfoNewAboutFilmsListWithType:(NSInteger)type  Kind:(NSString*)kind Page:(NSInteger)page Country:(NSString*)country Count:(NSInteger)count callback:(ReturnBlock)infoBlock;

- (void)GETInfo:(ReturnBlock)infoBlock param:(NSDictionary *)paramDict URL:(NSString *)url;

- (NSURLSessionDataTask *)getInfoAboutFilmsListWithType:(NSInteger)type Area:(NSInteger)area Kind:(NSInteger)kind Year:(NSInteger)year Page:(NSInteger)page Count:(NSInteger)count callback:(ReturnBlock)infoBlock;





@end
