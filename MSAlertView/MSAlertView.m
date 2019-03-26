//
//  MSAlertView.m
//  MSAlertView
//
//  Created by ypl on 2018/8/31.
//  Copyright © 2018年 ypl. All rights reserved.
//

#define MSRGBA(R, G, B, A) [UIColor colorWithRed:R / 255.0 green:G / 255.0 blue:B / 255.0 alpha:A]
#define MSUIColorFromRGB(rgbValue)   [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define kSeparatorColor  [UIColor lightGrayColor]

#import "MSAlertView.h"
#import <YYText.h>
#import <View+MASAdditions.h>
#import "MSDefine.h"
#import "MSUserInfo.h"
#import "MSButton.h"

static BOOL isAlerShow;
@interface MSAlertView ()
{
    CGFloat contentViewWidth;
    CGFloat contentViewHeight;
    BOOL isKeyboardShow;
}

@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) UIImageView *iconImageView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) YYLabel *subTitleLabel;
@property (strong, nonatomic) YYLabel *addressLabel;
@property (strong, nonatomic) UIImageView *closeImageView;
@property (strong, nonatomic) MSMainLoginVerifyCodeInputField *codeField;

@property (strong, nonatomic) NSMutableArray *buttonArray;
@property (strong, nonatomic) NSMutableArray *buttonTitleArray;
@property (nonatomic,copy) void (^dialogViewCompleteHandle)(NSInteger);
@end

@implementation MSAlertView

- (instancetype)initWithTitle:(NSString *)title icon:(UIImage *)icon message:(NSString *)message mode:(MSAlertViewMode)mode delegate:(id<MSAlertViewDelegate>)delegate buttonTitles:(NSString *)buttonTitles, ... NS_REQUIRES_NIL_TERMINATION{
    if(isAlerShow) {
        return nil;
    }
    if (self = [super initWithFrame:[UIScreen mainScreen].bounds]) {
        if(!_contentView||_contentView.hidden){
            _icon = icon;
            _title = title;
            _message = [NSString stringWithFormat:@"%@",message];
            _delegate = delegate;
            _mode = mode;
            _buttonArray = [NSMutableArray array];
            _buttonTitleArray = [NSMutableArray array];
            va_list args;
            va_start(args, buttonTitles);
            if (buttonTitles) {
                [_buttonTitleArray addObject:buttonTitles];
                while (1) {
                    NSString *  otherButtonTitle = va_arg(args, NSString *);
                    if(otherButtonTitle == nil) {
                        break;
                    } else {
                        [_buttonTitleArray addObject:otherButtonTitle];
                    }
                }
            }
            va_end(args);
            
            self.backgroundColor = [UIColor clearColor];
            _backgroundView = [[UIView alloc] initWithFrame:self.frame];
            _backgroundView.backgroundColor = [UIColor blackColor];
            [self addSubview:_backgroundView];
            
            [self initShowView];
        }
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (void)keyboardWillShow:(NSNotification *)sender {
    if (isKeyboardShow) {
        return;
    }
    if (self.mode==MSAlertViewModeMultipleInput) {
        [UIView animateWithDuration:0.25 animations:^{
            _contentView.centerY = self.centerY;
            _contentView.top-=WLTSize(60);
        }];
    }
}

- (void)keyboardWillHidden:(NSNotification *)sender {
    isKeyboardShow = NO;
    if (self.mode==MSAlertViewModeMultipleInput) {
        [UIView animateWithDuration:0.25 animations:^{
            _contentView.centerY = self.centerY;
        }];
    }
}

- (void)initShowView {
    if (!_contentView) {
        contentViewWidth = 280*[UIScreen mainScreen].bounds.size.width/320;
        contentViewHeight = _titleLabel?180:WLTSize(150);
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor whiteColor];
        _contentView.layer.cornerRadius = 5.0;
        _contentView.layer.masksToBounds = YES;
        _contentView.frame = CGRectMake(0, 0, contentViewWidth, contentViewHeight);
        _contentView.center = self.center;
    }
    [self addSubview:_contentView];
    [self initTitleAndIcon];
    [self initContent];
    [self initAllButtons];
}

- (void)initAllButtons {
    if (_buttonTitleArray.count > 0) {
        //CGFloat buttonWidth = (contentViewWidth / _buttonTitleArray.count)-40;
        for (NSString *buttonTitle in _buttonTitleArray) {
            NSInteger index = [_buttonTitleArray indexOfObject:buttonTitle];
            MSButton *button = [[MSButton alloc] initWithFrame:CGRectZero title:buttonTitle];
            [button addTarget:self action:@selector(buttonWithPressed:) forControlEvents:UIControlEventTouchUpInside];
            [_buttonArray addObject:button];
            [_contentView addSubview:button];
            
            [button mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(WLTNumSize(-20));
                if (_buttonTitleArray.count==1) {
                    make.left.equalTo(WLTNumSize(20));
                    make.right.equalTo(WLTNumSize(-20));
                }else{
                    make.left.equalTo(WLTNumSize(20+ (index*10)+index*(140)));
                    make.width.equalTo(WLTNumSize(140));
                }
                make.height.equalTo(WLTNumSize(44));
            }];
        }
    }
}

- (void)initTitleAndIcon {
    if (_icon != nil) {
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.image = _icon;
        [_iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_contentView);
            make.top.equalTo(WLTNumSize(20));
            make.width.equalTo(@80);
            make.height.equalTo(@80);
        }];
        [_contentView addSubview:_iconImageView];
    }
    if (_title != nil && ![_title isEqualToString:@""]) {
        _titleLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.text = _title;
            label.textAlignment = NSTextAlignmentLeft;
            label.font = [UIFont boldSystemFontOfSize:WLTSize(20)];
            label.numberOfLines = 0;
            label.lineBreakMode = NSLineBreakByWordWrapping;
            [_contentView addSubview:label];
            [label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(WLTNumSize(20));
                if (_icon!=nil) {
                    make.top.equalTo(_iconImageView).offset(10);
                }
                make.left.equalTo(WLTNumSize(20));
                make.right.equalTo(WLTNumSize(20));
            }];
            label;
        });
    }
    UIImageView *closeImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"common_close"]];
    [_contentView addSubview:closeImg];
    _closeImageView = closeImg;
    [closeImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(0));
        make.right.equalTo(@(0));
    }];
    closeImg.userInteractionEnabled = YES;
    [closeImg addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hide)]];
}

- (void)initMessage {
    if (_message != nil) {
        _messageLabel = [[YYTextView alloc] init];_messageLabel.editable = false;
//        _messageLabel.text = _message;
        _messageLabel.textColor = color_subTitle();
//        _messageLabel.numberOfLines = 0;
        _messageLabel.font = [UIFont systemFontOfSize:WLTSize(14)];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        paragraphStyle.lineSpacing = 3;
        NSDictionary *attributes = @{NSParagraphStyleAttributeName:paragraphStyle,NSFontAttributeName:font_RegularSize(WLTSize(14)),NSForegroundColorAttributeName:MSUIColorFromRGB(0x333333)};
        _messageLabel.attributedText = [[NSAttributedString alloc]initWithString:_message attributes:attributes];
        _messageLabel.textAlignment = NSTextAlignmentLeft;
        _messageLabel.textVerticalAlignment = YYTextVerticalAlignmentTop;
        _messageLabel.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _messageLabel.showsVerticalScrollIndicator = NO;
        [_contentView addSubview:_messageLabel];
        [_messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_titleLabel?:WLTNumSize(20)).offset(WLTSize(40));
            make.left.equalTo(WLTNumSize(20));
            make.right.equalTo(WLTNumSize(-20));
            make.bottom.equalTo(WLTNumSize(-64 - 10));
        }];

        CGSize size = [self messageSize:contentViewWidth-40 content:_message];
        CGFloat rHeight = WLTSize(234);
        if (size.height > rHeight) {
            UIImageView *bottom = [UIImageView new];bottom.backgroundColor = [UIColor whiteColor];
            [_contentView addSubview:bottom];
            [bottom mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.equalTo(@0);
                make.bottom.equalTo(_messageLabel);
                make.height.equalTo(WLTNumSize(50));
            }];
            [_contentView layoutIfNeeded];
            [MSUtils alphaGradientRampInView:bottom];
            size.height = rHeight;
        }
        _contentView.height += size.height;
        _contentView.center = self.center;
    }
}

- (void)initInputText {
    _subTitleLabel = ({
        YYLabel *label = [YYLabel new];
        label.font = font_MediumSize(WLTSize(14));
        label.textColor = color_subTitle();
        [_contentView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_titleLabel.mas_bottom).offset(16);
            make.left.equalTo(WLTNumSize(20));
            make.right.equalTo(WLTNumSize(-20));
        }];
        label;
    });
    MSMainLoginAccountInputField *phoneField = ({
        MSMainLoginAccountInputField *field = [MSMainLoginAccountInputField new];
        field.showCodeView = YES;
        field.enableFetchVerifyCode = YES;
        [_contentView addSubview:field];
        field.inputTextField.placeholder = @"";
        field.inputTextField.text = MSUserInfoObj.phoneNumber;
        field.inputTextField.font = font_RegularSize(WLTSize(14));
        field.inputTextField.enabled = NO;
        field.verifyCodeButton.titleLabel.font = font_RegularSize(WLTSize(14));
        field.verifyCodeButton.titleLabel.text = @"语音验证码";
        [field.verifyCodeButton setTitle:@"语音验证码" forState:UIControlStateNormal];
        [field mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_subTitleLabel.mas_bottom).offset(14);
            make.left.equalTo(WLTNumSize(20));
            make.right.equalTo(WLTNumSize(-20));
            make.height.equalTo(@(50));
        }];
        field;
    });
    
    _codeField = [MSMainLoginVerifyCodeInputField new];
    [_contentView addSubview:_codeField];
    _codeField.inputTextField.font = phoneField.inputTextField.font;
    _codeField.inputTextField.placeholder = @"请输入验证码";
    [_codeField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(phoneField.mas_bottom).offset(WLTSize(16));
        make.left.equalTo(@(20));
        make.right.equalTo(@(-20));
        make.height.equalTo(@(50));
    }];

    YYLabel *tips = ({
        YYLabel *label = [YYLabel new];
        label.text = @"即将转入以下地址";
        label.font = font_MediumSize(WLTSize(14));
        label.textColor = color_subTitle();
        [_contentView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_codeField.mas_bottom).offset(20);
            make.left.equalTo(WLTNumSize(20));
            make.right.equalTo(WLTNumSize(-20));
        }];
        label;
    });
    
    _addressLabel = ({
        YYLabel *label = [YYLabel new];
        label.numberOfLines = 0;
        label.lineBreakMode = NSLineBreakByCharWrapping;
        label.text = @"www.idouzi.com";
        label.font = font_RegularSize(WLTSize(13));
        label.textColor = color_subTitle();
        label.textVerticalAlignment = YYTextVerticalAlignmentTop;
        [_contentView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(tips.mas_bottom).offset(9);
            make.left.equalTo(WLTNumSize(20));
            make.right.equalTo(WLTNumSize(-20));
            make.height.equalTo(WLTNumSize(50));
        }];
        label;
    });
    _contentView.height += WLTSize(204);
    _contentView.center = self.center;
    
    //验证码
    WEAKSELF
    phoneField.verifyCodeShouldSendBlock = ^(NSString *phoneNumber, NSString *validate) {
        if (weakSelf.mobileCodeBlock) {
            weakSelf.mobileCodeBlock(phoneNumber,validate);
        }
    };
}

- (void)initSingleInputText {
     _nameField = ({
        MSMainLoginVerifyCodeInputField *field = [MSMainLoginVerifyCodeInputField new];
         field.inputTextField.keyboardType = UIKeyboardTypeDefault;
        [_contentView addSubview:field];
        field.inputTextField.font = font_RegularSize(WLTSize(14));
        field.inputTextField.placeholder = @"请输入8个字以内的昵称";
        [field mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_titleLabel.mas_bottom).offset(20);
            make.left.equalTo(WLTNumSize(20));
            make.right.equalTo(WLTNumSize(-20));
            make.height.equalTo(@(50));
        }];
        field;
    });
    _contentView.height += 40;
}

- (void)initContent {
    if (self.mode == MSAlertViewModeMultipleInput) {
        [self initInputText];
    }else if(self.mode == MSAlertViewModeSingleInput){
        _contentView.top-=80;
        [self initSingleInputText];
    }else if(self.mode == MSAlertViewModeText){
        [self initMessage];
    }
}

- (void)showBackground {
    _backgroundView.alpha = 0;
    [UIView beginAnimations:@"fadeIn" context:nil];
    [UIView setAnimationDuration:0.35];
    _backgroundView.alpha = 0.6;
    [UIView commitAnimations];
}

-(void)showAlertAnimation {
    CAKeyframeAnimation * animation;
    animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = 0.30;
    animation.removedOnCompletion = YES;
    animation.fillMode = kCAFillModeForwards;
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1, 1.1, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    animation.values = values;
    [_contentView.layer addAnimation:animation forKey:nil];
}

- (void)hideAlertAnimation {
    [UIView beginAnimations:@"fadeIn" context:nil];
    [UIView setAnimationDuration:0.35];
    _backgroundView.alpha = 0.0;
    [UIView commitAnimations];
}

- (void)buttonWithPressed:(UIButton *)button {
    if (_delegate && [_delegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)]) {
        NSInteger index = [_buttonTitleArray indexOfObject:button.titleLabel.text];
        [_delegate alertView:self clickedButtonAtIndex:index];
    }
    if (_dialogViewCompleteHandle) {
        NSInteger index = [_buttonTitleArray indexOfObject:button.titleLabel.text];
        _dialogViewCompleteHandle(index);
    }
    if (self.mode==MSAlertViewModeSingleInput) {
        if (_nameField.inputTextField.text.length==0) {
            return;
        }
        if (_delegate && [_delegate respondsToSelector:@selector(didSingleSubmit:)]) {
            [_delegate didSingleSubmit:_nameField.inputTextField.text];
        }
        if (self.didSingleSubmitBlock) {
            self.didSingleSubmitBlock(_nameField.inputTextField.text);
        }
        return;
    }else if(self.mode==MSAlertViewModeMultipleInput) {
        if (_codeField.inputTextField.text.length==0) {
            return;
        }
        if (_delegate && [_delegate respondsToSelector:@selector(didMuliteSubmit:)]) {
            [_delegate didMuliteSubmit:_codeField.inputTextField.text];
        }
        if (self.didMuliteSubmitBlock) {
            self.didMuliteSubmitBlock(_codeField.inputTextField.text);
        }
    }
    [self hide];
}

- (void)show {
    isAlerShow = YES;
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    NSArray *windowViews = [window subviews];
    if(windowViews && [windowViews count] > 0){
        UIView *subView = [windowViews objectAtIndex:[windowViews count]-1];
        for(UIView *aSubView in subView.subviews)
        {
            [aSubView.layer removeAllAnimations];
        }
        [window addSubview:self];
        [self showBackground];
        [self showAlertAnimation];
    }
}

- (void)hide {
    if (self.didCloseBlock) {
        self.didCloseBlock();
    }
    isAlerShow = NO;
    _contentView.hidden = YES;
    [self hideAlertAnimation];
    [self removeFromSuperview];
}

- (void)setSubTitle:(NSString *)subTitle {
    _subTitle = subTitle;
    _subTitleLabel.text = subTitle;
}

- (void)setAddress:(NSString *)address {
    _address = address;
    _addressLabel.text = address;
}

- (void)setIconTop:(CGFloat)top{
    //_iconImageView.y = top;
}

- (void)setTitleColor:(UIColor *)color fontSize:(CGFloat)size {
    if (color != nil) {
        _titleLabel.textColor = color;
    }
    
    if (size > 0) {
        _titleLabel.font = [UIFont systemFontOfSize:size];
    }
}

- (void)setMessageColor:(UIColor *)color fontSize:(CGFloat)size {
    if (color != nil) {
        _messageLabel.textColor = color;
    }
    
    if (size > 0) {
        _messageLabel.font = [UIFont boldSystemFontOfSize:size];
    }
}

- (void)setButtonTitleColor:(UIColor *)color fontSize:(CGFloat)size atIndex:(NSInteger)index {
    if (index>=_buttonArray.count) {
        return;
    }
    UIButton *button = _buttonArray[index];
    if (color != nil) {
        [button setTitleColor:color forState:UIControlStateNormal];
    }
    
    if (size > 0) {
        button.titleLabel.font = [UIFont systemFontOfSize:size];
    }
}

- (void)setButtonbackgroundColor:(UIColor *)color atIndex:(NSInteger)index {
    if (index>=_buttonArray.count) {
        return;
    }
    MSButton *button = _buttonArray[index];
    if (color != nil) {
        [button setBackgroundColor:color highlightColor:UIColorFromRGB(0xF9F9F9)];
    }
}

- (void)setHideClose:(BOOL)hideClose {
    _hideClose = hideClose;
    _closeImageView.hidden = hideClose;
}

- (void)setHideTitle:(BOOL)hideTitle {
    _hideTitle = hideTitle;
    _titleLabel.hidden = hideTitle;
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    _textAlignment = textAlignment;
    _messageLabel.textAlignment = textAlignment;
}

- (void)setTextVerticalAlignment:(YYTextVerticalAlignment)textVerticalAlignment {
    _textVerticalAlignment = textVerticalAlignment;
    _messageLabel.textVerticalAlignment = textVerticalAlignment;
}

- (void)setFirstResponder {
    [_codeField.inputTextField becomeFirstResponder];
}

- (void)setRecommondTips:(NSString *)tips {
    if (tips.length) {
        if (_buttonArray.count>0) {
            MSButton *button = _buttonArray[0];
            [button mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(WLTNumSize(-40));
            }];
        }
        UILabel *tipslabel = [[UILabel alloc] init];
        tipslabel.text = tips;
        tipslabel.font = font_RegularSize(WLTSize(12));
        tipslabel.textColor = color_subTitle();
        tipslabel.textAlignment = NSTextAlignmentCenter;
        [_contentView addSubview:tipslabel];
        [tipslabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(WLTNumSize(-14));
            make.left.equalTo(WLTNumSize(16));
            make.right.equalTo(WLTNumSize(-16));
        }];
        _contentView.height += 20;
    }
}

- (void)showAlertView:(MSAlertView *)alertView completion:(void (^)(NSInteger))completeBlock {
    _dialogViewCompleteHandle = completeBlock;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self endEditing:YES];
}

- (CGSize)messageSize:(CGFloat)width content:(NSString *)content {
    UIFont *font = font_RegularSize(WLTSize(15));
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 3;
    NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
    CGSize size = [content boundingRectWithSize:CGSizeMake(width, 2000)
                                     options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                  attributes:attributes context:nil].size;
    size.width = ceil(size.width);
    size.height = ceil(size.height);
    return size;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
@end
