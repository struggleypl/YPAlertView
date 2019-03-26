//
//  MSAlertView+Extension.h
//  MobiledataShare
//
//  Created by ypl on 2018/11/21.
//  Copyright © 2018年 JiuXi Technology. All rights reserved.
//

#import "MSAlertView.h"

@interface MSAlertView (Extension)

+ (void)alertShowTitle:(NSString *)title message:(NSString *)message cancelButton:(NSString *)cancelButton otherButton:(NSString *)otherButton completion:(void (^)(NSInteger))completeBlock;

@end
