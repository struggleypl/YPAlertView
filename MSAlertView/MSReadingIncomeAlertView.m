//
//  MSReadingIncomeAlertView.m
//  MobiledataShare
//
//  Created by Cai on 2019/1/24.
//  Copyright © 2019 JiuXi Technology. All rights reserved.
//

#import "MSReadingIncomeAlertView.h"
#import "MSDefine.h"

typedef void(^callback)(void);
@interface MSReadingIncomeAlertView()
{
    CGFloat contentViewWidth;
    CGFloat contentViewHeight;
}
@property (copy) NSString *adfValue,*rmbValue,*maxRMBValue;
@property (copy) callback presscallback;

@property (strong, nonatomic) UILabel *titleLabel,*adfLabel,*adfTipLabel;
@property (strong, nonatomic) UIImageView *iconImageView;
@property (strong, nonatomic) UIImage *icon;
@property (strong, nonatomic) NSString *title;

@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UIView *backgroundView;
@end

@implementation MSReadingIncomeAlertView
+ (instancetype)alertReadingIncomeWithADF:(NSString*)adf convert:(NSString*)rb maxRMB:(NSString *)maxRMB completionBlock:(void(^)(void))callback{
    MSReadingIncomeAlertView *view = [[MSReadingIncomeAlertView alloc] initWithFrame:CGRectZero adfValue:adf rb:rb maxRMB:maxRMB icon:[UIImage imageNamed:@"adf-icon"]];
    view.presscallback = callback;
    [view show];
    return view;
}

- (instancetype)initWithFrame:(CGRect)frame adfValue:(NSString*)adf rb:(NSString*)rb maxRMB:(NSString *)maxRMB icon:(UIImage*)icon;
{
    if (self = [super initWithFrame:[UIScreen mainScreen].bounds]) {
        _adfValue = adf;
        _icon = icon;
        _rmbValue = rb;
        _maxRMBValue = maxRMB;
        self.backgroundColor = [UIColor clearColor];
        _backgroundView = [[UIView alloc] initWithFrame:self.frame];
        _backgroundView.backgroundColor = [UIColor blackColor];
        [self addSubview:_backgroundView];
        
        [self initShowView];
    }
    return self;
}

- (void)initShowView {
    if (!_contentView) {
        contentViewWidth = 280*[UIScreen mainScreen].bounds.size.width/320;
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


- (void)initTitleAndIcon {
    UIImageView *closeImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"common_close"]];
    [_contentView addSubview:closeImg];
    [closeImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(0));
        make.right.equalTo(@(0));
    }];
    closeImg.userInteractionEnabled = YES;
    [closeImg addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hide)]];
    
    _title = @"你的阅读奖励已到账";
    if (_title != nil && ![_title isEqualToString:@""]) {
        _titleLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.text = _title;
            label.textAlignment = NSTextAlignmentCenter;
            label.font = font_MediumSize(WLTSize(16));
            [_contentView addSubview:label];
            [label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(WLTNumSize(20));
                make.left.right.equalTo(@0);
            }];
            label;
        });
    }
    
//    if (_icon != nil) {
//        _iconImageView = [[UIImageView alloc] init];
//        _iconImageView.image = _icon;
//        [_contentView addSubview:_iconImageView];
//        [_iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.centerX.equalTo(_contentView);
//            make.top.equalTo(_titleLabel.mas_bottom).offset(WLTSize(12));
//            make.width.height.equalTo(WLTNumSize(140));
//        }];
//    }
}

-(void)initContent{
    UIImageView *adfImageView = ({
        UIImageView *img = [[UIImageView alloc] initWithImage:_icon];
        [_contentView addSubview:img];
        img;
    });
    
    UILabel *adfLabel = ({
        UILabel *label = [UILabel new];label.textColor = color_red();
        label.textAlignment = NSTextAlignmentCenter;
        label.font = font_MediumSize(WLTSize(13));
        label.text = [NSString stringWithFormat:@"奖励 %@ ADF",_adfValue];
        label;
    });
    UILabel *adfLabelTip = ({
        UILabel *label = [UILabel new];label.textColor = color_title();
        label.textAlignment = NSTextAlignmentCenter;
        label.font = font_RegularSize(WLTSize(11));
        label.text = [NSString stringWithFormat:@"约（￥%.2f）",[_rmbValue floatValue]];
        label;
    });
    [_contentView addSubview:adfLabel];_adfLabel = adfLabel;
    [_contentView addSubview:adfLabelTip];_adfTipLabel = adfLabelTip;
    
    [adfImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(WLTNumSize(70));
        make.top.equalTo(_titleLabel.mas_bottom).offset(WLTSize(1));
        make.width.height.equalTo(WLTNumSize(16));
    }];
    
    [adfLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(adfImageView.mas_right).offset(WLTSize(4));
        make.centerY.equalTo(adfImageView);
    }];
    
    [adfLabelTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(adfLabel.mas_right).offset(WLTSize(4));
        make.bottom.equalTo(adfLabel);
    }];
//    _contentView.height += CGRectGetMaxY(adfLabelTip.frame);
}

- (void)initAllButtons {
    UIImageView *bgImageView = ({
        UIImageView *img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"invest_reward_bg"]];
        img.contentMode = UIViewContentModeScaleAspectFill;
        img.clipsToBounds = YES;
        img.userInteractionEnabled = YES;
        [_contentView addSubview:img];
        img;
    });
    
    MSButton *button = [[MSButton alloc] initWithFrame:CGRectZero title:@"去投资"];
    [button addTarget:self action:@selector(buttonWithPressed:) forControlEvents:UIControlEventTouchUpInside];
    button.titleLabel.font = font_MediumSize(WLTSize(14));
    button.layer.cornerRadius = 2;
    [bgImageView addSubview:button];
    
    UILabel *adfLabelTip = ({
        UILabel *label = [UILabel new];
        label.textColor = color_light();
        label.textAlignment = NSTextAlignmentCenter;
        label.font = font_SemiboldSize(WLTSize(16));
        label.numberOfLines = 2;
        label.text = _maxRMBValue;
        label;
    });
    [bgImageView addSubview:adfLabelTip];
    
    [bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(WLTNumSize(75));
        make.left.equalTo(WLTNumSize(16));
        make.right.equalTo(WLTNumSize(-16));
        make.height.equalTo(WLTNumSize(120));
    }];
    
    [adfLabelTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(WLTNumSize(20));
        make.left.equalTo(WLTNumSize(46));
        make.right.equalTo(WLTNumSize(-46));
    }];
    
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(WLTNumSize(35));
        make.width.equalTo(bgImageView).multipliedBy(0.5);
        make.centerX.equalTo(bgImageView);
        make.bottom.equalTo(bgImageView.mas_bottom).offset(WLTSize(-12));
    }];
    
    [_contentView layoutIfNeeded];
    _contentView.height += CGRectGetMaxY(bgImageView.frame) + WLTSize(20);
    _contentView.center = self.center;
}

- (void)buttonWithPressed:(UIButton*)sender{
    if (_presscallback) {
        _presscallback();
    }
    [self hide];
}

- (void)hide {
    _contentView.hidden = YES;
    [self hideAlertAnimation];
    [self removeFromSuperview];
}

- (void)show {
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
    self.alpha = 0.0;
    [UIView commitAnimations];
}
@end
