#import "EMAES128.h"
#import "NSData+Base64.h"

NSString *const kInitVector = @"kV5ttAmmaL7lsRvXKeUEzA==";

size_t const kKeySize = kCCKeySizeAES128;

#pragma mark - Category

#pragma mark - NSData
@implementation NSData(RgAES128)

-(NSString *)base64String {
    return [self base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

-(NSString *)utf8String {
    return [[NSString alloc]initWithData:self encoding:NSUTF8StringEncoding];
}

@end

#pragma mark - NSString


@implementation NSString(RgAES128)

-(NSData *)base64Data {
    return [[NSData alloc] initWithBase64EncodedString:self options:NSDataBase64DecodingIgnoreUnknownCharacters];
}

-(NSData *)base64DataInUTF8 {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [data base64EncodedDataWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

@end


#pragma mark - RgAES128

@interface EMAES128()

@property (nonatomic, strong) NSData *iv;

@end

@implementation EMAES128

+ (instancetype)shared {
    static EMAES128 *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

/*
-(NSString *)encryptWithContent:(NSString *)content key:(NSString *)key {
    NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
    NSData *keyData = key.base64Data;
    return [self encryptWithData:data keyData:keyData].base64String;
}

-(NSData *)encryptWithData:(NSData *)data key:(NSString *)key {
    return [self encryptWithData:data keyData:key.base64Data];
}

-(NSData *)encryptWithData:(NSData *)data keyData:(NSData *)keyData {
    return [self encryptWithData:data keyData:keyData iv:self.iv];
}

-(NSData *)encryptWithData:(NSData *)data keyData:(NSData *)keyData iv:(NSData *)iv {
    return [self cipherCTRWithOperation:kCCEncrypt data:data key:keyData iv:iv];
}

-(NSString *)decryptWithContent:(NSString *)content key:(NSString *)key {
    NSData *data = content.base64Data;
    NSData *keyData = key.base64Data;
    return [self decryptWithData:data keyData:keyData].utf8String;
}

-(NSData *)decryptWithData:(NSData *)data key:(NSString *)key {
    return [self decryptWithData:data keyData:key.base64Data];
}

-(NSData *)decryptWithData:(NSData *)data keyData:(NSData *)keyData {
    return [self decryptWithData:data keyData:keyData iv:self.iv];
}

-(NSData *)decryptWithData:(NSData *)data keyData:(NSData *)keyData iv:(NSData *)iv {
    return [self cipherCTRWithOperation:kCCDecrypt data:data key:keyData iv:iv];
}

-(CCCryptorRef)cryptorWithOperation:(CCOperation)operation key:(NSString *)key {
    return [self cryptorCTRWithOperation:operation key:key.base64Data iv:self.iv];
}

-(CCCryptorRef)cryptorCTRWithOperation:(CCOperation)operation key:(NSData *)key iv:(NSData *)iv {
    CCCryptorRef cryptor;
    CCCryptorCreateWithMode(operation,
                            kCCModeCTR,
                            kCCAlgorithmAES,
                            ccNoPadding,
                            iv.bytes ? iv.bytes : NULL,
                            key.bytes,
                            key.length,
                            NULL,
                            0,
                            0,
                            kCCModeOptionCTR_BE,
                            &cryptor);
    return cryptor;
}

-(NSData *)cipherDataWithCryptor:(CCCryptorRef)cryptor data:(NSData *)data {
    NSMutableData *sourceM = [[NSMutableData alloc] initWithData:data];
    size_t bufferLength = CCCryptorGetOutputLength(cryptor, sourceM.length, true);
    size_t outLength;
    NSMutableData *outData = [[NSMutableData alloc] initWithLength:bufferLength];
    CCCryptorStatus result = CCCryptorUpdate(cryptor,
                                             sourceM.bytes,
                                             sourceM.length,
                                             outData.mutableBytes,
                                             outData.length,
                                             &outLength);
    if (result != kCCSuccess) {
        outData = nil;
    }
    return outData;
}

-(NSData *)cipherCTRWithOperation:(CCOperation)operation data:(NSData *)data key:(NSData *)key iv:(NSData *)iv {
    NSMutableData *sourceM = [[NSMutableData alloc] initWithData:data];
    CCCryptorRef cryptor;
    CCCryptorStatus result = CCCryptorCreateWithMode(operation,
                                                     kCCModeCTR,
                                                     kCCAlgorithmAES,
                                                     ccNoPadding,
                                                     iv.bytes ? iv.bytes : NULL,
                                                     key.bytes,
                                                     key.length,
                                                     NULL,
                                                     0,
                                                     0,
                                                     kCCModeOptionCTR_BE,
                                                     &cryptor);
    size_t bufferLength = CCCryptorGetOutputLength(cryptor, sourceM.length, true);
    size_t outLength;
    NSMutableData *outData = [[NSMutableData alloc] initWithLength:bufferLength];
    if (result == kCCSuccess) {
        result = CCCryptorUpdate(cryptor,
                                 sourceM.bytes,
                                 sourceM.length,
                                 outData.mutableBytes,
                                 outData.length,
                                 &outLength);
        if (result != kCCSuccess) {
            outData = nil;
        }
    } else {
        outData = nil;
    }
    return outData;
}


-(NSData *)iv {
    if(!_iv) {
        _iv = @"kV5ttAmmaL7lsRvXKeUEzA==".base64Data;
    }
    return _iv;
}


#pragma mark EecryptCBC128Mode
-(NSData*)encryptCBC128Mode:(NSData*)data withKey:(NSString*)key {
    return [self encryptCBC128Mode:data withKey:[NSData dataFromBase64String:key] vectorKey:[NSData dataFromBase64String:kInitVector]];
}

-(NSString*)encryptCBC128Mode:(NSString*)data key:(NSString*)key {
    return [self encryptCBC128Mode:data withKey:key vector:kInitVector];
}

-(NSString*)encryptCBC128Mode:(NSString*)data withKey:(NSString*)key vector:(NSString *)vector {
    NSData *d = [data dataUsingEncoding:NSUTF8StringEncoding];
    NSData *k = [NSData dataFromBase64String:key];
    NSData *v = [NSData dataFromBase64String:vector];
    NSData *result = [self encryptCBC128Mode:d withKey:k vectorKey:v];
    return [result base64EncodedString];
}

-(NSData*)encryptCBC128Mode:(NSData*)data withKey:(NSData*)key vectorKey:(NSData *)vectorKey {
    NSAssert(data, @"Missing data to encrypt");
    
    size_t bufferSize           = [data length] + kCCBlockSizeAES128;
    void* buffer                = malloc(bufferSize);
    
    size_t bytesEncrypted    = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES, kCCOptionPKCS7Padding,
                                          [key bytes], [key length],
                                          [vectorKey bytes],
                                          [data bytes], [data length],
                                          buffer, bufferSize,
                                          &bytesEncrypted);
    
    if (cryptStatus == kCCSuccess){
        
        NSData *data = [NSData dataWithBytesNoCopy:buffer length:bytesEncrypted];
        return data;
    } else{
        free(buffer);
        @throw [NSException exceptionWithName:@"NSException" reason:@"We encountered an issue while encrypting." userInfo:nil];
    }
}
*/
#pragma mark DecryptCBC128Mode
/*
-(NSData *)decryptCBC128Mode:(NSData*)data withKey:(NSString*)key {
    return [NSData dataFromBase64String: [self decryptCBC128Mode:[data base64EncodedString] withKey:key vector:kInitVector]];
}

-(NSString *)decryptCBC128ModeWithDataStr:(NSString*)data withKey:(NSString*)key {
    return [self decryptCBC128Mode:data withKey:key vector:kInitVector];
}
*/
-(NSData*)decryptCBC128Mode:(NSString *)data withKey:(NSString*)key vector:(NSString *)vector {
    NSData *d = [NSData dataFromBase64String:data];
    
    unichar *buf = malloc(sizeof(unichar) * [key length]);
    if (!buf) return nil;
    [key getCharacters:buf range:NSMakeRange(0, [key length])];
    
    NSData *k = [NSData dataWithBytes:buf length:[key length]];
    
    unichar *buf2 = malloc(sizeof(unichar) * [vector length]);
    if (!buf2) return nil;
    [vector getCharacters:buf2 range:NSMakeRange(0, [vector length])];
    
    NSData *v = [NSData dataWithBytes:buf2 length:[vector length]];
    
    free(buf);
    free(buf2);
    NSData *result = [self decryptCBC128Mode:d withKey:k  vectorKey:v];
    return result;//[result base64EncodedString];
}

-(NSData*) decryptCBC128Mode:(NSData*)data withKey:(NSData*)key vectorKey:(NSData *)vectorKey {
    
    size_t bufferSize           = [data length] + kCCBlockSizeAES128;
    void* buffer                = malloc(bufferSize);
    
    size_t bytesDecrypted    = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES, kCCOptionPKCS7Padding,
                                          [key bytes], [key length],
                                          [vectorKey bytes],
                                          [data bytes], [data length],
                                          buffer, bufferSize,
                                          &bytesDecrypted);
    
    if (cryptStatus == kCCSuccess) {
        NSData *plaintext = [NSData dataWithBytesNoCopy:buffer length:bytesDecrypted];
        return plaintext;
    } else{
        free(buffer);
        @throw [NSException exceptionWithName:@"NSException" reason:@"We encountered an issue while decrypting." userInfo:nil];
    }
}




@end
