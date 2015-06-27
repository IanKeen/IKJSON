//
//  AppDelegate.m
//  IKJSON
//
//  Created by Ian Keen on 26/06/2015.
//  Copyright (c) 2015 Mustard. All rights reserved.
//

#import "AppDelegate.h"
#import "NSObject+IKJSONIncoming_NSObject.h"
#import "IKJSONShared.h"

typedef NS_ENUM(NSUInteger, TOOption) {
    TOOptionOne,
    TOOptionTwo,
};

@interface Child : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic) int age;
@end
@implementation Child
@end

@interface TestObject : NSObject <IKJSONIncomingValueMapping, IKJSONOutgoingValueMapping>
@property (nonatomic, strong) NSArray *children;
@property (nonatomic, strong) NSString *_string;
@property (nonatomic, strong) NSNumber *_number;
@property (nonatomic) BOOL _bool;
@property (nonatomic) NSInteger _nsinteger;
@property (nonatomic) int _integer;
@property (nonatomic) float _float;
@property (nonatomic) double _double;
@property (nonatomic) TOOption _option;
@property (nonatomic, strong, setter=myCustomSetter:) id _customSetter;
@property (nonatomic, readonly) NSString *_readOnly;
@property (nonatomic, strong) Child *_child;
@end
@implementation TestObject
-(void)myCustomSetter:(id)value { __customSetter = value; }
-(id)mappedJSONValueForValue:(id)value jsonKey:(NSString *)jsonKey {
    if ([jsonKey isEqualToString:@"_option"]) { return @(self._option); }
    return value;
}
-(id)mappedValueForJSONValue:(id)jsonValue property:(NSString *)propertyName {
    if ([propertyName isEqualToString:@"_option"]) { return @(TOOptionTwo); }
    return jsonValue;
}
@end


@interface AppDelegate ()
@end

@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSDictionary *json
    = @{
        @"_string": @"string value",
        @"_number": @123,
        @"_bool": @"true",
        @"_nsinteger": @"5",
        @"_integer": @56,
        @"_float": @3.2,
        @"_double": @"4.5",
        @"_option": @1,
        @"_customSetter": @"custom setter value",
        @"_readOnly": @"string string string",
        @"_child": @{
                @"name": @"Childs name",
                @"age": @"5"
                },
        @"children": @[
                @{
                    @"name": @"Sub child1",
                    @"age": @"84"
                    },
                @{
                    @"name": @"Sub child2",
                    @"age": @"24"
                    },
                ],
        };
    
    //when
    TestObject *obj = [TestObject new];
    [obj ponsoPopulate:json];
    
    
    return YES;
}
@end
