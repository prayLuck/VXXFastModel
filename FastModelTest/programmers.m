//
//  programmers.m
//  FastModel
//
//  Created by Volitation小星 on 16/6/24.
//  Copyright © 2016年 wangkun. All rights reserved.
//

#import "programmers.h"


@interface programmers ()



@end

@implementation programmers






- (instancetype)initWithDict:(NSDictionary *)dict {

    if (self = [super init]) {

        [self setValuesForKeysWithDictionary:dict];

        
    }

    return self;
}

-(void)setValue:(id)value forUndefinedKey:(NSString *)key{

    

}


+ (instancetype)programmersWithDict:(NSDictionary *)dict {

    return [[self alloc] initWithDict:dict];

}



@end
