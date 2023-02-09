#import "NSObject+UISegment.h"

@implementation NSObject (UISegment)

+ (void)initiiWithFrame:(UIView*)parenView contenSize:(CGSize)contentSize vi:(UIView*)vi viSize:(CGSize)viSize vi2:(UIView*)vi2 index:(int)index count:(int)count{
    UIView * tempView = vi2;
    float ww = contentSize.width;
    NSInteger margin = (ww - viSize.width * count)/count;//设置相隔距离
    float startPos = margin / 2.0;
    CGSize size = viSize;
    float yy = (parenView.frame.size.height-size.height)/2;
    UIView * view = vi;
    if (index == 0) {
        view.frame = CGRectMake(margin-startPos,yy , size.width, size.height);
    }
    else if (index == (count-1)){
        view.frame = CGRectMake(tempView.frame.origin.x+tempView.frame.size.width+margin,yy, size.width, size.height);
    }
    else{
        view.frame = CGRectMake(tempView.frame.origin.x+tempView.frame.size.width+margin, yy, size.width, size.height);
    }
    tempView = view;
    [view layoutIfNeeded];
}

+ (void)initii:(UIView*)parenView contenSize:(CGSize)contentSize vi:(UIView*)vi viSize:(CGSize)viSize vi2:(UIView*)vi2 index:(int)index count:(int)count{
    UIView * tempView = vi2;
    float ww = contentSize.width;
    NSInteger margin = (ww - viSize.width * count)/count;//设置相隔距离
    float startPos = margin / 2.0;
    CGSize size = viSize;
    UIView * view = vi;
    if (index == 0) {
        [view mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(parenView).offset(margin-startPos);
            make.centerY.equalTo(parenView);
            make.height.mas_equalTo(size.height);
            make.width.mas_equalTo(size.width);
        }];
    }
    else if (index == (count-1)){
        [view mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(parenView).offset(-margin+startPos);
            make.left.equalTo(tempView.mas_right).offset(margin);
            make.centerY.equalTo(tempView);
            make.height.equalTo(tempView);
            make.width.equalTo(tempView);
            make.height.mas_equalTo(size.height);
            make.width.mas_equalTo(size.width);
        }];
    }
    else{
        [view mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(tempView.mas_right).offset(margin);
            make.centerY.equalTo(tempView);
            make.height.equalTo(tempView);
            make.width.equalTo(tempView);
            make.height.mas_equalTo(size.height);
            make.width.mas_equalTo(size.width);
        }];
    }
    tempView = view;
    [view layoutIfNeeded];
}
@end
