//
//  MSAlertView.h
//  MSAlertView
//
//  Created by ypl on 2018/8/31.
//  Copyright © 2018年 ypl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YYTextView.h>
#import "JXMainLoginViewInputField.h"

typedef NS_ENUM(NSInteger, MSAlertViewMode) {
    MSAlertViewModeMultipleInput   = 0,
    MSAlertViewModeSingleInput  = 1,
    MSAlertViewModeText   = 2,
};

@protocol MSAlertViewDelegate;

@interface MSAlertView : UIView
@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UIImage *icon;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *subTitle;
@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) NSString *address;
@property (assign, nonatomic) BOOL hideClose;
@property (assign, nonatomic) BOOL hideTitle;
@property (strong, nonatomic) YYTextView *messageLabel;
@property (strong, nonatomic) MSMainLoginVerifyCodeInputField *nameField;
@property (assign, nonatomic) NSTextAlignment textAlignment;
@property (assign, nonatomic) YYTextVerticalAlignment textVerticalAlignment;
@property (nonatomic ,assign)MSAlertViewMode mode;
@property (weak, nonatomic) id<MSAlertViewDelegate> delegate;
@property( nonatomic, copy) void(^mobileCodeBlock)(NSString *phone,NSString *validate);
@property( nonatomic, copy) void(^didSingleSubmitBlock)(NSString *name);
@property( nonatomic, copy) void(^didMuliteSubmitBlock)(NSString *code);
@property( nonatomic, copy) void(^didCloseBlock)(void);

- (instancetype)initWithTitle:(NSString *)title icon:(UIImage *)icon message:(NSString *)message mode:(MSAlertViewMode)mode delegate:(id<MSAlertViewDelegate>)delegate buttonTitles:(NSString *)buttonTitles, ... NS_REQUIRES_NIL_TERMINATION;

- (void)show;

- (void)hide;

- (void)setTitleColor:(UIColor *)color fontSize:(CGFloat)size;

- (void)setMessageColor:(UIColor *)color fontSize:(CGFloat)size;

- (void)setButtonTitleColor:(UIColor *)color fontSize:(CGFloat)size atIndex:(NSInteger)index;

- (void)setButtonbackgroundColor:(UIColor *)color atIndex:(NSInteger)index;

- (void)setIconTop:(CGFloat)top;

- (void)setFirstResponder;

- (void)setRecommondTips:(NSString *)tips;

-(void)showAlertView:(MSAlertView *)alertView completion:(void (^)(NSInteger selectIndex))completeBlock;

@end


@protocol MSAlertViewDelegate <NSObject>
@optional
- (void)alertView:(MSAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

- (void)receiveMobileCode:(NSString *)phone;

- (void)didSingleSubmit:(NSString *)name;

- (void)didMuliteSubmit:(NSString *)code;
@end

