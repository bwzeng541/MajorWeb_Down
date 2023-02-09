
#import "MajorSchemeHelper.h"

#define WHSchemeHelperLocal  [NSString stringWithFormat:@"%@/schemlocal",AppSynchronizationDir]

static MajorSchemeHelper* _sharedHelper;

@implementation MajorSchemeHelper {
    NSArray* _schemes;
    NSArray* _prefixes;
    NSMutableArray *_localPrefixes;
}

- (void)parseJSON:(NSData*)jsonData
{
    if (jsonData != nil) {
        NSError* jsonError = nil;
        NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&jsonError];

        //解析没错
        if (jsonError == nil) {
            _schemes = [jsonDict objectForKey:@"schemes"];
            _prefixes = [jsonDict objectForKey:@"prefixes"];
        }
    }
}

+ (MajorSchemeHelper*)sharedHelper
{
    if (_sharedHelper == nil) {
        _sharedHelper = [[MajorSchemeHelper alloc] init];
    }

    return _sharedHelper;
}

- (id)init
{
    self = [super init];

    if (self) {
        NSString* defaultJSON = [NSString stringWithFormat:@"{ \"schemes\": [ \"itms\", \"itmss\", \"itms-apps\", \"itms-apps\",\"%@\" ],\"prefixes\": [ \"http://itunes.apple.com\", \"https://itunes.apple.com\" ] }",AppTeShuPre];

 
        _localPrefixes = [[NSMutableArray alloc]init];
        [self parseJSON:[defaultJSON dataUsingEncoding:NSUTF8StringEncoding]];
        [self reloadFromLocal];
        [self addPrefixes:_localPrefixes];
    }

    return self;
}

-(NSString *)getLocalMask{
    NSMutableString *strMsg = [NSMutableString string];
    for (int i = 0; i<_prefixes.count; i++) {
        [strMsg appendString:[_prefixes objectAtIndex:i]];
        if (i<_prefixes.count-1) {
            [strMsg appendString:@"|"];
        }
    }
    return strMsg;
}

- (void)reloadFromLocal{
    NSArray *array = [NSArray arrayWithContentsOfFile:WHSchemeHelperLocal];
    if (array.count>0) {
        [_localPrefixes addObjectsFromArray:array];
    }
}

- (void)addPrefixes:(NSArray*)array{
    if (array.count>0) {
        NSMutableArray *tmpArray = [NSMutableArray arrayWithArray:array];
        [tmpArray addObjectsFromArray:_prefixes];
        _prefixes = [NSArray arrayWithArray:tmpArray];
    }
}

- (void)addPrefixexFromUser:(NSString*)preStr
{
    if([preStr length]>4){
        __block BOOL schemeFound = NO;
        [_prefixes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL* stop) {
            if ([preStr isEqualToString:obj]) {
                schemeFound = YES;
                *stop = YES;
            }
        }];
        if (!schemeFound) {
            NSMutableArray *tmpArray = [NSMutableArray arrayWithArray:_prefixes];
            [tmpArray addObject:preStr];
            _prefixes = [NSArray arrayWithArray:tmpArray];
            [_localPrefixes addObject:preStr];
            [_localPrefixes writeToFile:WHSchemeHelperLocal atomically:YES];
        }
    }
}

-(NSString*)findSchemeUrl:(NSURL*)url{
    NSRange range = [url.absoluteString rangeOfString:@"scheme="];
    if(range.location!=NSNotFound){
      NSString *str =  [url.absoluteString substringFromIndex:range.location+range.length];
      NSArray *array =  [[[NSBundle mainBundle] infoDictionary]objectForKey:@"LSApplicationQueriesSchemes"];
        for (int i = 0; i < array.count; i++) {
           NSRange range = [str rangeOfString:[array objectAtIndex:i]];
            if (range.location != NSNotFound) {
                return str;
            }
        }
      return   nil;
    }
    return nil;
}

- (BOOL)isAppStoreLink:(NSURL*)url
{
    __block BOOL schemeFound = NO;

    [_schemes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL* stop) {
        if ([url.scheme isEqualToString:obj]) {
            schemeFound = YES;
            *stop = YES;
        }
    }];

    if (schemeFound == YES) {
        return YES;
    }

    __block BOOL hasPrefix = NO;

    [_prefixes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL* stop) {
        if ([url.absoluteString hasPrefix:obj]) {
            hasPrefix = YES;
            *stop = YES;
        }
    }];
    if (hasPrefix == YES) {
        return YES;
    }

    return NO;
}

//- (BOOL)isJBInstallLink:(NSURL*)url
//{
//    if ([url.absoluteString hasPrefix:@"itms-services://?action=download-manifest"]) {
//        return YES;
//    }
//    else {
//        return NO;
//    }
//}

- (NSString*)getAppId:(NSString*)searchedString
{
    NSError* error = nil;

    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:@"[0-9]{8,12}" options:0 error:&error];
    NSArray* matches = [regex matchesInString:searchedString options:0 range:NSMakeRange(0, [searchedString length])];
    for (NSTextCheckingResult* match in matches) {
        NSString* matchText = [searchedString substringWithRange:[match range]];
        if (matchText.length > 0) {
            return matchText;
        }
    }
    return nil;
}

+ (BOOL)validateUrl:(NSString*)candidate
{
    //  NSString *regex = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@", @"^((https|http|ftp|rtsp|mms)?://)", @"?(([0-9a-zA-Z_!~*'().&=+$%-]+: )?[0-9a-zA-Z_!~*'().&=+$%-]+@)?", @"(([0-9]{1,3}\\.){3}[0-9]{1,3}", @"|", @"([0-9a-zA-Z_!~*'()-]+\\.)*", @"([0-9a-zA-Z][0-9a-zA-Z-]{0,61})?[0-9a-zA-Z]\\.", @"[a-zA-Z]{2,6})", @"(:[0-9]{1,4})?", @"((/?)|", @"(/[0-9a-zA-Z_!~*'().;?:@&=+$,%#-]+)+/?)$"];
    NSString* candidateUrlString = candidate;
    if (![candidate.lowercaseString hasPrefix:@"http://"] && ![candidate.lowercaseString hasPrefix:@"https://"]) {
        candidateUrlString = [NSString stringWithFormat:@"http://%@", candidate];
    }
    NSString* urlRegEx = @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
    NSPredicate* urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
    return [urlTest evaluateWithObject:candidateUrlString];
}

@end
