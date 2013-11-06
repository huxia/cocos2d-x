//
//  JSBCustom.h
//  x
//
//  Created by Huizhe Xiao on 13-10-22.
//  Copyright (c) 2013年 Huizhe Xiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocoa/CCObject.h"
@protocol JSBCustom <NSObject>
-(int)jsCommand:(NSString*)name params:(NSDictionary*)params;
-(void)jsAsyncCommand:(NSString*)name params:(NSDictionary*)params callbackID:(int)callbackID;
-(void)jsEventBind:(NSString*)name;
-(void)jsEventUnbind:(NSString*)name;
@end
void APP_fireEvent(NSString* name, NSDictionary* params);
int APP_asyncCommandCallback(int callbackID, NSDictionary* params);
void APP_Config(id<JSBCustom> delegate);
cocos2d::CCObject* nsToCC(NSObject* o);
NSObject* nsFromCC(cocos2d::CCObject* o);

