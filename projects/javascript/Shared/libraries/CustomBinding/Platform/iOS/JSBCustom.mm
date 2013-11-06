//
//  JSBCustom.m
//  x
//
//  Created by Huizhe Xiao on 13-10-22.
//  Copyright (c) 2013年 Huizhe Xiao. All rights reserved.
//

#import "JSBCustom.h"
#import "cocos2d.h"
#import "ScriptingCore.h"

#import "cocoa/CCString.h"
#import "cocoa/CCDictionary.h"
#import "cocoa/CCArray.h"
#include "jsapi.h"

cocos2d::CCObject* nsToCC(NSObject* o){
	if (!o || [o isKindOfClass:[NSNull class]]) {
		return NULL;
	}
	if ([o isKindOfClass:[NSNumber class]]) {
		if(CFNumberIsFloatType((CFNumberRef)o))
		{
			return cocos2d::CCDouble::create([(NSNumber*)o doubleValue]);
		}
		else
		{
			return cocos2d::CCInteger::create([(NSNumber*)o intValue]);
		}
	}else if([o isKindOfClass:[NSString class]]){
		return cocos2d::CCString::create([(NSString*)o cStringUsingEncoding:NSUTF8StringEncoding]);
	}else if([o isKindOfClass:[NSDictionary class]]){
		CCDictionary* result = cocos2d::CCDictionary::create();
		NSArray* allKeys = [(NSDictionary*)o allKeys];
		for (id<NSCopying> key in allKeys) {
			CCObject* value = nsToCC([(NSDictionary*)o objectForKey:key]);
			if ([(NSObject*)key isKindOfClass:[NSNumber class]]) {
				// int key
				result->setObject(value, [(NSNumber*)key intValue]);
			}else if ([(NSObject*)key isKindOfClass:[NSString class]]){
				// str key
				result->setObject(value, [(NSString*)key cStringUsingEncoding:NSUTF8StringEncoding]);
			}else{
				
				CCAssert(false, "only string or integer key supported.");
				continue;
			}
		}
		return result;
	}else if([o isKindOfClass:[NSArray class]]){
		
		CCArray* result = cocos2d::CCArray::create();
		for(NSObject* value in (NSArray*)o){
			result->addObject(nsToCC(value));
		}
		return result;
	}else{
		
		CCAssert(false, "the type isn't suppored.");
		return NULL;
	}
}
NSObject* nsFromCC(cocos2d::CCObject* obj){
	if(obj == NULL)
		return nil;
	CCString* strVal = NULL;
	CCDictionary* dictVal = NULL;
	CCArray* arrVal = NULL;
	CCDouble* doubleVal = NULL;
	CCBool* boolVal = NULL;
	CCFloat* floatVal = NULL;
	CCInteger* intVal = NULL;
	
	if((strVal = dynamic_cast<cocos2d::CCString *>(obj))) {
		return [NSString stringWithCString:strVal->getCString() encoding:NSUTF8StringEncoding];
	} else if ((dictVal = dynamic_cast<CCDictionary*>(obj))) {
		NSMutableDictionary* result = [NSMutableDictionary dictionary];
		CCArray* allKeys = dictVal->allKeys();
		unsigned int allKeysCount = allKeys->count();
		
		
		for(unsigned int i=0;i<allKeysCount;i++){
			CCObject* key = allKeys->objectAtIndex(i);
			CCString* strKey = NULL;
			CCInteger* intKey = NULL;
			CCObject* value = NULL;
			if((strKey = dynamic_cast<cocos2d::CCString *>(key))) {
				value = dictVal->objectForKey(strKey->getCString());
			}else if ((intKey = dynamic_cast<CCInteger*>(key))) {
				value = dictVal->objectForKey(intKey->getValue());
			}else{
				CCAssert(false, "only string or integer key supported.");
				value = NULL;
				
			}
			NSObject* nsKey = nsFromCC(key);
			if(!nsKey)
				nsKey = [NSNull null];
			
			NSObject* nsValue = nsFromCC(value);
			if(!nsValue)
				nsValue = [NSNull null];
			
			[result setObject:nsValue forKey:(id<NSCopying>)nsKey];
		}
		return result;
	} else if ((arrVal = dynamic_cast<CCArray*>(obj))) {
		NSMutableArray* result = [NSMutableArray array];
		unsigned int count = arrVal->count();
		for(unsigned int i=0;i<count;i++){
			NSObject* v = nsFromCC(arrVal->objectAtIndex(i));
			if (!v) {
				v = [NSNull null];
			}
			[result addObject:v];
		}
		return result;
	} else if ((doubleVal = dynamic_cast<CCDouble*>(obj))) {
		return [NSNumber numberWithDouble:doubleVal->getValue()];
	} else if ((floatVal = dynamic_cast<CCFloat*>(obj))) {
		return [NSNumber numberWithFloat:floatVal->getValue()];
	} else if ((intVal = dynamic_cast<CCInteger*>(obj))) {
		return [NSNumber numberWithInt:intVal->getValue()];
	} else if ((boolVal = dynamic_cast<CCBool*>(obj))) {
		return [NSNumber numberWithBool:boolVal->getValue()];
	} else {
		CCAssert(false, "the type isn't suppored.");
		return nil;
	}
	
}
//#include "jsb_dbg.h"
//#include "jsb_config.h"
//#include "jsb_basic_conversions.h"

static id<JSBCustom> delegate;

void APP_fireEvent(NSString* name, NSDictionary* params){
	
	JSContext* cx = ScriptingCore::getInstance()->getGlobalContext();
	JSObject* global = ScriptingCore::getInstance()->getGlobalObject();
	jsval appVal, __eventVal, callbackFunctionVal;
	
	JS_GetProperty(cx, global, "app", &appVal);
	JSObject* app = JSVAL_TO_OBJECT(appVal);
	
	
	JS_GetProperty(cx, app, "__event", &__eventVal);
	JSObject* __event = JSVAL_TO_OBJECT(__eventVal);
	
	
	JS_GetProperty(cx, __event, "callback", &callbackFunctionVal);
	
	jsval rval;
	unsigned argc=2;
	jsval argv[2];
	
	
	
	argv[0] = c_string_to_jsval(cx, [name cStringUsingEncoding:NSUTF8StringEncoding]);
	argv[1] = ccdictionary_to_jsval(cx, (CCDictionary*)nsToCC(params));
	
	JS_CallFunctionValue(cx, __event, callbackFunctionVal, argc, argv, &rval);
	
}
int APP_asyncCommandCallback(int callbackID, NSDictionary* params){
	JSContext* cx = ScriptingCore::getInstance()->getGlobalContext();
	JSObject* global = ScriptingCore::getInstance()->getGlobalObject();
	jsval appVal, __asyncVal, callbackFunctionVal;
	
	JS_GetProperty(cx, global, "app", &appVal);
	JSObject* app = JSVAL_TO_OBJECT(appVal);
	
	
	JS_GetProperty(cx, app, "__async", &__asyncVal);
	JSObject* __async = JSVAL_TO_OBJECT(__asyncVal);
	
	
	JS_GetProperty(cx, __async, "callback", &callbackFunctionVal);
	
	jsval rval;
	unsigned argc=2;
	jsval argv[2];
	argv[0] = INT_TO_JSVAL(callbackID);
	argv[1] = ccdictionary_to_jsval(cx, (CCDictionary*)nsToCC(params));
	
	JS_CallFunctionValue(cx, __async, callbackFunctionVal, argc, argv, &rval);
	
	int32_t result = 0;
	
	jsval_to_int32(cx, rval, &result);
	return result;
}
JSBool APP_command(JSContext *cx, uint32_t argc, jsval *vp)
{
	JSB_PRECONDITION2( argc <= 2, cx, JS_FALSE, "Invalid number of arguments" );
	jsval *argvp = JS_ARGV(cx,vp);
	JSBool ok = JS_TRUE;
	std::string stdName;
	cocos2d::CCDictionary* ccParams = NULL;
	
	ok &= jsval_to_std_string( cx, *argvp++, &stdName);
	if (argc == 2) {
		ok &= jsval_to_ccdictionary(cx, *argvp++, &ccParams);
	}
	
	NSString* name = [NSString stringWithCString:stdName.c_str() encoding:NSUTF8StringEncoding];
	NSDictionary *params = nil;
	if (ccParams) {
		params = (NSDictionary*)nsFromCC(ccParams);
	}
	
	JSB_PRECONDITION2(ok, cx, JS_FALSE, "Error processing arguments");
	
	static NSString* EVENT_BIND_COMMAND_PREFIX = @"__event-bind-";
	static int EVENT_BIND_COMMAND_PREFIX_LEN = [EVENT_BIND_COMMAND_PREFIX length];
	static NSString* EVENT_UNBIND_COMMAND_PREFIX = @"__event-unbind-";
	static int EVENT_UNBIND_COMMAND_PREFIX_LEN = [EVENT_UNBIND_COMMAND_PREFIX length];
	static NSString* ASYNC_COMMAND_PREFIX = @"__async-";
	static int ASYNC_COMMAND_PREFIX_LEN = [ASYNC_COMMAND_PREFIX length];
	
	if (name.length > EVENT_BIND_COMMAND_PREFIX_LEN && [[name substringToIndex:EVENT_BIND_COMMAND_PREFIX_LEN] isEqualToString:EVENT_BIND_COMMAND_PREFIX]){
		NSString* eventName = [name substringFromIndex:EVENT_BIND_COMMAND_PREFIX.length];
		[delegate jsEventBind:eventName];
		JS_SET_RVAL(cx, vp, JSVAL_VOID);
	}else if (name.length > EVENT_UNBIND_COMMAND_PREFIX_LEN && [[name substringToIndex:EVENT_UNBIND_COMMAND_PREFIX_LEN] isEqualToString:EVENT_UNBIND_COMMAND_PREFIX]){
		NSString* eventName = [name substringFromIndex:EVENT_UNBIND_COMMAND_PREFIX.length];
		[delegate jsEventUnbind:eventName];
		JS_SET_RVAL(cx, vp, JSVAL_VOID);
	}else  if (name.length > ASYNC_COMMAND_PREFIX_LEN && [[name substringToIndex:ASYNC_COMMAND_PREFIX_LEN] isEqualToString:ASYNC_COMMAND_PREFIX]) {
		NSString* asyncName = [name substringFromIndex:ASYNC_COMMAND_PREFIX.length];
		int asyncID = [[params objectForKey:@"id"] intValue];
		
		ASSERT([params isKindOfClass:[NSMutableDictionary class]], "params should be dictionary");
		id data = [params objectForKey:@"data"];
		ASSERT(asyncID > 0, "async id error");
		[delegate jsAsyncCommand:asyncName params:data callbackID:asyncID];
		JS_SET_RVAL(cx, vp, JSVAL_VOID);
	}else{
		int r = [delegate jsCommand:name params:params];
		
		JS_SET_RVAL(cx, vp, INT_TO_JSVAL(r));
	}
	return JS_TRUE;
};
void _customBindingsRegisterCallback(JSContext* _cx, JSObject* _global){
	JSObject *app = JS_NewObject(_cx, NULL, NULL, NULL);
	jsval appVal = OBJECT_TO_JSVAL(app);
	JS_SetProperty(_cx, _global, "app", &appVal);
	
	JS_DefineFunction(_cx, app, "command", APP_command, 0, JSPROP_READONLY | JSPROP_PERMANENT | JSPROP_ENUMERATE );
	
	ScriptingCore::getInstance()->runScript("custom-binding-jsb.js");
}
void APP_Config(id<JSBCustom> d){
	delegate = d;
	
	ScriptingCore::getInstance()->addRegisterCallback(_customBindingsRegisterCallback);
}