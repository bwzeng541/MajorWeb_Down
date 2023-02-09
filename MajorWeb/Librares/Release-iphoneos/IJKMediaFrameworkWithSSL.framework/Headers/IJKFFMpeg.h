#import <Foundation/Foundation.h>
#ifdef __cplusplus
#define IJK_EXTERN extern "C" __attribute__((visibility ("default")))
#else
#define IJK_EXTERN extern __attribute__((visibility ("default")))
#endif


IJK_EXTERN NSInteger const ForceExitFFMpegCode;
//IJK_EXTERN NSString *const jik_ffmpeg_cmd_stop_notifi;
//IJK_EXTERN NSString *const jik_ffmpeg_cmd_progress_notifi;
//IJK_EXTERN NSString *const jik_ffmpeg_cmd_getInfo_notifi;
#define IJKMsgTypeKey @"msgTypeKey"
#define IJKMsgContent @"msgContent"

@interface IJKFFMpeg : NSObject
{

}
//把网络上的文件拷贝到本地，不支持断点，只能覆盖
+(int)IJK_ffmpeg_copyUrlToLocalFile:(const char *)urlfile local:(const char*)local;
//得到远程流信息
+(int)IJK_ffmpeg_getUrlInfo:(const char *)urlfile refer:(const char*)refer;

+(int)IJK_ffmpeg_gethlsInfo:(const char *)urlfile refer:(const char*)refer;

+(int)IJK_ffmpeg_concat:(NSArray*)files outFile:(NSString*)outfile;

+(int)IJK_ffmpeg_concat2:(NSString*)localM3u8Url outFile:(NSString*)outfile;

+(int)IJK_ffmpeg_main:(int)argc argv:(char **)argv requestType:(int)type;

+(void)addMsg:(NSString*)msgType msg:(id)msg;

+(void)forceExitFFmpeg;

+(NSData*)ase_128_decry:(void*)byte datalen:(NSInteger)dateLaen key:(void*)key keyLen:(NSInteger)keyLen;
@end
