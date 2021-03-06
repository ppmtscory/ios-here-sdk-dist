//
//  CCCFSPaymentMethodViewController.h
//  SDKSampleAppWithSource
//
//  Created by Samuel Jerome on 6/20/14.
//  Copyright (c) 2014 PayPalHereSDK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PayPalHereSDK/PPHTransactionManager.h>

@interface CCCFSPaymentMethodViewController : UIViewController
<
UITextFieldDelegate,
UIAlertViewDelegate,
PPHTransactionControllerDelegate,
PPHTransactionManagerDelegate
>

@end
