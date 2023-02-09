
#import "AppAdSchemeHelper.h"

#define AppSynchronizationDir [NSString stringWithFormat:@"%@",[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)objectAtIndex:0]]
#define WHSchemeHelperLocal  [NSString stringWithFormat:@"%@/schemlocal",AppSynchronizationDir]

static AppAdSchemeHelper* _sharedHelper;

@implementation AppAdSchemeHelper {
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

+ (AppAdSchemeHelper*)sharedHelper
{
    if (_sharedHelper == nil) {
        _sharedHelper = [[AppAdSchemeHelper alloc] init];
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


 

@end
