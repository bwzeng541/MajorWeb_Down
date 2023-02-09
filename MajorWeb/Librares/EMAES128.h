#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCrypto.h>

@interface NSData(AES128)

-(NSString *)base64String;
-(NSString *)utf8String;

@end

@interface NSString(AES128)

-(NSData *)base64Data;
-(NSData *)base64DataInUTF8;

@end

@interface EMAES128 : NSObject

+(instancetype)shared;
/*
-(NSData *)encryptWithData:(NSData *)data key:(NSString *)key;
-(NSData *)encryptWithData:(NSData *)data keyData:(NSData *)keyData;
-(NSString *)encryptWithContent:(NSString *)content key:(NSString *)key;

-(NSData *)decryptWithData:(NSData *)data key:(NSString *)key;
-(NSData *)decryptWithData:(NSData *)data keyData:(NSData *)keyData;
-(NSString *)decryptWithContent:(NSString *)content key:(NSString *)key;

-(CCCryptorRef)cryptorWithOperation:(CCOperation)operation key:(NSString *)key;
-(NSData *)cipherDataWithCryptor:(CCCryptorRef)cryptor data:(NSData *)data;

-(NSData*)encryptCBC128Mode:(NSData*)data withKey:(NSString*)key;

//to base64 string.
-(NSString*)encryptCBC128Mode:(NSString*)data key:(NSString*)key;

//to base64 string.
-(NSString*)encryptCBC128Mode:(NSString*)data withKey:(NSString*)key vector:(NSString *)vector;

//base64 key
-(NSString *)decryptCBC128ModeWithDataStr:(NSString*)data withKey:(NSString*)key;
*/
-(NSData*)decryptCBC128Mode:(NSString *)data withKey:(NSString*)key vector:(NSString *)vector;

-(NSData *)decryptCBC128Mode:(NSData*)data withKey:(NSString*)key;
-(NSData*) decryptCBC128Mode:(NSData*)data withKey:(NSData*)key vectorKey:(NSData *)vectorKey ;
@end
