//
//  MSReadingIncomeAlertView.h
//  MobiledataShare
//
//  Created by Cai on 2019/1/24.
//  Copyright © 2019 JiuXi Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSReadingIncomeAlertView : UIView
+ (instancetype)alertReadingIncomeWithADF:(NSString*)adf convert:(NSString*)rb maxRMB:(NSString *)maxRMB completionBlock:(void(^)(void))callback;
@end
