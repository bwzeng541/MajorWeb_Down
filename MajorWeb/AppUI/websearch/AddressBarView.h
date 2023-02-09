
#import <Foundation/Foundation.h>
@protocol AddressBarViewDelegate <UITextFieldDelegate>

@optional
- (void)editChange:(UITextField *)txt;
- (void)popSystem;
@end

@interface AddressBarView : UITextField
{

    __weak id <AddressBarViewDelegate> editDelegate;
    NSString *oldText;
    UIImageView *_accessoryView;
}

@property(nonatomic) BOOL enlarged;
@property(nonatomic, strong) NSString *oldText;
@property(nonatomic, weak) id <AddressBarViewDelegate> editDelegate;

- (void)cleanText;

@end
