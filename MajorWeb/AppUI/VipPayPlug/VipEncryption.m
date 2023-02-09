// http://www.wuleilei.com/

#import "VipEncryption.h"
#import "NSData+AES256.h"



@implementation VipEncryption
+ (NSString *)decryptString:(NSString *)base64StringToDecrypt{
   NSData *dataV = [[NSData alloc]initWithBase64EncodedString:base64StringToDecrypt options:0];
   NSData *data = [dataV AES128DecryptWithKeyFix:@"dd358748fcabdda1e1ef8b12d5a5384a"];
   return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}
@end
