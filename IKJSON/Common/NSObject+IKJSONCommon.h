//
//  NSObject+IKJSONCommon.h
//  IKJSON
//
//  Created by Ian Keen on 26/06/2015.
//  Copyright (c) 2015 Mustard. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^propertyBlock)(NSString *name, NSString *type, void * value);

@interface NSObject (IKJSONCommon_Protocols)
//outgoing
-(NSString *)jsonKeyForProperty:(NSString *)propertyName;
-(id)jsonValueForValue:(id)value jsonKey:(NSString *)jsonKey;

//incoming
-(NSDictionary *)objectForJson:(NSDictionary *)json;
-(NSString *)propertyForJsonKey:(NSString *)jsonKey;
-(id)valueForJsonValue:(id)jsonValue property:(NSString *)propertyName;
@end

@interface NSObject (IKJSONCommon_Introspection)
-(void)objectPropertyData:(propertyBlock)block;
@end

@interface NSObject (IKJSONCommon_JSON)
-(NSDictionary *)mappedJson:(NSDictionary *)json;
@end

extern NSString * valueType(id value);
