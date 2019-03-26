//
//  MSAlertView+Extension.m
//  MobiledataShare
//
//  Created by ypl on 2018/11/21.
//  Copyright © 2018年 JiuXi Technology. All rights reserved.
//

#import "MSAlertView+Extension.h"
#import "MSDefine.h"

@implementation MSAlertView (Extension)

+ (void)alertShowTitle:(NSString *)title message:(NSString *)message cancelButton:(NSString *)cancelButton otherButton:(NSString *)otherButton completion:(void (^)(NSInteger))completeBlock {
    MSAlertView *alert = [[MSAlertView alloc] initWithTitle:title icon:nil message:message mode:MSAlertViewModeText delegate:nil buttonTitles:cancelButton,otherButton, nil];
    alert.hideClose = NO;
    alert.hideTitle = YES;
    alert.textAlignment = NSTextAlignmentCenter;
    alert.textVerticalAlignment = YYTextVerticalAlignmentBottom;
    [alert setMessageColor:nil fontSize:WLTSize(18)];
    [alert setButtonbackgroundColor:color_disable() atIndex:0];
    [alert setButtonTitleColor:color_thirdTitle() fontSize:0 atIndex:0];
    [alert showAlertView:alert completion:completeBlock];
    [alert show];
}
@end
