//
//  testjsAppController.h
//  testjs
//
//  Created by Rolando Abarca on 3/19/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import "JSBCustom.h"
@class RootViewController;

@interface AppController : NSObject <UIAccelerometerDelegate, UIAlertViewDelegate, UITextFieldDelegate,UIApplicationDelegate,JSBCustom> {
    UIWindow *window;
    RootViewController    *viewController;
}

@end

