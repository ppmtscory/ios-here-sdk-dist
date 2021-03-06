//
//  STAppDelegate.m
//  SimplerTransaction
//
//  Created by Cotter, Vince on 11/14/13.
//  Copyright (c) 2013 PayPal Partner. All rights reserved.
//

#import "STAppDelegate.h"

#import "STOauthLoginViewController.h"
#import <PayPalHereSDK/PayPalHereSDK.h>

#define kSDKSampleApp_paymentFlow_authOnlyBool_Key @"SDKSampleApp.paymentFlow.authOnlyBool"

@interface STAppDelegate() <
PPHLoggingDelegate
>
@property (nonatomic,strong) id<PPHLoggingDelegate> sdkLogger;

@end

@implementation STAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Lets set the default stage in here
    self.selectedStage = DEFAULT_STAGE;
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.viewController = [[STOauthLoginViewController alloc] initWithNibName:@"STOauthLoginViewController_iPhone" bundle:nil];
    } else {
        self.viewController = [[STOauthLoginViewController alloc] initWithNibName:@"STOauthLoginViewController_iPad" bundle:nil];
    }

	self.navigationController = [[UINavigationController alloc] initWithRootViewController:self.viewController];
    self.window.rootViewController = self.navigationController;

	[self.window addSubview:self.navigationController.view];

    [self.window makeKeyAndVisible];

    self.refundableRecords = [[NSMutableArray alloc] init];
    self.authorizedRecords = [[NSMutableArray alloc] init];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *taxRate = ([defaults objectForKey:@"taxRate"]) ? [defaults objectForKey:@"taxRate"] : @".10";
    [defaults setObject:taxRate forKey:@"taxRate"];
    [defaults synchronize];
    
	NSLog(@"This is our Bundle Identifier Key: [%@]", [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleIdentifierKey]);

    
    // Let's setup the SDK ------------------------------
    
    /*
     * How to configure the SDK to use Live vs Sandbox
     */
     [PayPalHereSDK selectEnvironmentWithType:ePPHSDKServiceType_Sandbox];
   
    /* By default, the SDK has a remote logging facility for warnings and errors. This helps PayPal immensely in
     * diagnosing issues, but is obviously up to you as to whether you want to do remote logging, or perhaps you
     * have your own logging infrastructure. This sample app intercepts log messages and writes errors to the
     * remote logger but not warnings.
     */
    self.sdkLogger = [PayPalHereSDK loggingDelegate];
    [PayPalHereSDK setLoggingDelegate:self];
    
    /*
     * Let's tell the SDK who is referring these customers.
     * The referrer code is an important value which helps PayPal know which businesses and SDK
     * users are bringing customers into the PayPal system.  The referrer code is stored in the
     * invoices that are sent to the backend.
     */
    [PayPalHereSDK setReferrerCode:@"SDKSampleApp, Inc"];
    
    // Either the app, or the SDK must requrest location access if we'd like
    // the SDK to take payments.
    [PayPalHereSDK askForLocationAccess];
    
    // We keep track of the user's preference for sample app's payment flow.  Either Authorize-Only or Full-Capture
    self.paymentFlowIsAuthOnly = [[NSUserDefaults standardUserDefaults] boolForKey:kSDKSampleApp_paymentFlow_authOnlyBool_Key];
    

    
    return YES;
}

-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{   
	if ([url.host isEqualToString:@"oauth"]) {
        
		NSMutableDictionary *query = [[NSMutableDictionary alloc] init];
		for (NSString *keyValuePair in [url.query componentsSeparatedByString:@"&"]) {
			NSArray *pair = [keyValuePair componentsSeparatedByString:@"="];
			if (!(pair && [pair count] == 2)) continue;
            NSString *escapedData = [pair objectAtIndex:1];
            escapedData = [escapedData stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			[query setObject:escapedData forKey:[pair objectAtIndex:0]];
		}

		if ([query objectForKey:@"access_token"] && 
			[query objectForKey:@"expires_in"] && 
			[query objectForKey:@"refresh_url"] && 
			[self.viewController isKindOfClass:[STOauthLoginViewController class]]) {
			[self.viewController setActiveMerchantWithAccessTokenDict:query];
		}

	} else {
		NSLog(@"%s url.host is NOT \"oauth\" so we're leaving without doing anything!", __FUNCTION__);	
	}

	return YES;
}

- (void) setPaymentFlowIsAuthOnly:(BOOL)paymentFlowIsAuthOnly {
    [[NSUserDefaults standardUserDefaults] setBool:paymentFlowIsAuthOnly forKey:kSDKSampleApp_paymentFlow_authOnlyBool_Key];
    [[NSUserDefaults standardUserDefaults]  synchronize];
}

- (BOOL) paymentFlowIsAuthOnly {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kSDKSampleApp_paymentFlow_authOnlyBool_Key];
}

// Let's intercept the logging messages of the SDK
// and display them so we can see what's happening.
//
#pragma mark PPHLoggingDelegate methods
-(void)logPayPalHereInfo:(NSString *)message {
    NSLog(@"%@", message);
}

-(void)logPayPalHereError:(NSString *)message {
    NSLog(@"%@", message);
    [self.sdkLogger logPayPalHereError: message];
}

-(void)logPayPalHereWarning:(NSString *)message {
    NSLog(@"%@", message);
}

-(void)logPayPalHereDebug:(NSString *)message {
    NSLog(@"Debug: %@", message);
}

-(void)logPayPalHereHardwareInfo:(NSString *)message {
    NSLog(@"Debug: %@", message);
}


@end
