
#import <Foundation/Foundation.h>

@interface Record : NSObject <NSCoding> {
    NSString *titleNum;
    NSString *titleName;
    NSString *iconStr;
    NSString *titleUrl;
    NSString *typeStr;
    NSString *dateStr;
    NSString *superNum;
    NSString *subNum;
    NSString *dataCount;
    NSString *webUrl;
//    NSData *picData;
}
@property(nonatomic, strong) NSString *titleNum;
@property(nonatomic, strong) NSString *titleName;
@property(nonatomic, strong) NSString *iconStr;
@property(nonatomic, strong) NSString *titleUrl;
@property(nonatomic, strong) NSString *typeStr;
@property(nonatomic, strong) NSString *dateStr;
@property(nonatomic, strong) NSString *superNum;
@property(nonatomic, strong) NSString *subNum;
@property(nonatomic, strong) NSString *dataCount;
@property(nonatomic, strong) NSString *webUrl;

//@property(nonatomic, strong)NSData *picData;
- (void)encodeWithCoder:(NSCoder *)aCoder;

- (id)initWithCoder:(NSCoder *)aDecoder;
@end


@interface WebTailorFavoriteRecord:NSObject <NSCoding>
@property(nonatomic, strong) Record *record;
@property(nonatomic, strong) NSString* key;
@end
