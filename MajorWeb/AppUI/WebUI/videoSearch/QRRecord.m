//
//  QRRecord.m
//  QRBrowerCode
//
//  Created by bxing zeng on 2020/4/16.
//  Copyright © 2020 cxh. All rights reserved.
//

#import "QRRecord.h"
#import <CommonCrypto/CommonDigest.h>
#import "DateTools.h"

@implementation QRCommon
+(NSString*)dateFormater:(NSDate*)date{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    return [formatter stringFromDate:date];
}

+(NSString *) md5From:(NSString*)str
{
    const char *cStr = [str UTF8String];
      unsigned char result[16];
      CC_MD5( cStr, (unsigned int) strlen(cStr), result);
      return [NSString stringWithFormat:
              @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
              result[0], result[1], result[2], result[3],
              result[4], result[5], result[6], result[7],
              result[8], result[9], result[10], result[11],
              result[12], result[13], result[14], result[15]
              ];
}
@end

 

@implementation QRWordItem
 
@end
 
@implementation QRSearhWord
+ (NSString *)primaryKey {
    return @"uuid";
}

-(id)init{
    self = [super init];
    return self;
}
+(QRSearhWord*)buildQRSearhWord:(NSString*)searchWord {
    QRSearhWord *v =[[QRSearhWord alloc] init];
    v.uuid = [QRCommon md5From:searchWord];
    v.word = searchWord;
    NSDate *now = [NSDate date];
    NSString* yymmrr =  [NSString stringWithFormat:@"%ld%02ld%02ld",[now year],[now month],[now day]];
    NSString* hhssmm =  [NSString stringWithFormat:@"%02ld%02ld%02ld",[now hour],[now minute],[now second]];
    v.serialNumber = [[NSString stringWithFormat:@"%@%@",yymmrr,hhssmm] integerValue];
    return v;
}
@end

 
