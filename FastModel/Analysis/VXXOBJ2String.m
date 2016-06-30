//
//  VXXOBJ2String.m
//  FastModel
//
//  Created by Volitation小星 on 16/6/25.
//  Copyright © 2016年 wangkun. All rights reserved.
//

#import "VXXOBJ2String.h"
#import "VXXInitMethod.h"
#import "VXXChangClassName.h"

@interface VXXOBJ2String ()

@property (strong,nonatomic) NSMutableDictionary* undefineKeyList;

@property (strong,nonatomic) NSMutableDictionary* modelArr;

@property (strong,nonatomic) NSString* currentClass;

@end

@implementation VXXOBJ2String

-(NSMutableDictionary *)classTypeDict{
    if (!_classTypeDict) {
        
        _classTypeDict = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    
    return _classTypeDict;
}

-(NSMutableDictionary *)undefineKeyList{
    
    if (!_undefineKeyList) {
        
        _undefineKeyList = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    
    return _undefineKeyList;
}

-(NSMutableDictionary *)modelArr{
    
    if (!_modelArr) {
        
        _modelArr = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    
    return _modelArr;
    
}

static VXXOBJ2String* instance;

+(instancetype)shareOBJ2StringWithCurrentClass:(NSString*)className{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil) {
            
            instance = [VXXOBJ2String new];
            
        }
    });
    
    instance.currentClass = className;
    
    return instance;
}

-(NSString*)obj2String:(id)className andName:(NSString *)name{
    
    NSString* newName = [self checkNameAndReplace:name];
    
    NSString* s;
    
    
    if ([className isKindOfClass:[NSString class]]) {
        //数字类型
          s = [NSString stringWithFormat:@"\r\n@property (copy,nonatomic) %@* %@;\r\n",@"NSNumber",newName];
        return s;
    }
    
    if ([className isSubclassOfClass:[NSString class]]) {
        s = [NSString stringWithFormat:@"\r\n@property (copy,nonatomic) %@* %@;\r\n",@"NSString",newName];
    }
    
    if (!s) {
        // s为空的时候这个时候是说明是布尔
        s = [NSString stringWithFormat:@"\r\n@property (copy,nonatomic) %@* %@;\r\n",@"NSNumber",newName];
        
    }
    
    if (![newName isEqualToString:name]) {
        //这里需要添加注释
        
        NSMutableString* mString = [NSMutableString stringWithFormat:@"\r\n//这个属性的名称被替换了原名称为:%@%@",name,s];
        
        //修改后可能要走undefineKey方法
        
        self.undefineKeyList[name] = self.currentClass;
        
        s = mString.copy;
    }
    
    
    
    return s;
}

//检查是否
-(NSString*)checkNameAndReplace:(NSString*)name{
    
    if ([name isEqualToString:@"id"]) {
        
        name = @"idx";
        
    }
    
    if ([name isEqualToString:@"int"]) {
        name = @"intx";
    }
    
    
    return name;
}


-(NSString*)addRenameWords{
    
    NSMutableString* mString = [NSMutableString stringWithCapacity:100];
    
    [self.undefineKeyList enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {

        if ([self.currentClass isEqualToString:obj]) {
            
            [mString appendFormat:@"\r\n\tif ([key isEqualToString:@\"%@\"]) {\r\n\t\tself.%@x = value;\r\n\t}\r\n",key,key];
            
        }
     
    }];
    
    return mString.copy;
    
}


-(NSString*)array2StringWithName:(NSString *)name andClassName:(NSString*)className{
    
    //数组类型需要记录下来,需要生成新的构造方法构造方法
    [self.modelArr setValue:name forKey:className];
    
    NSString* s = [NSString stringWithFormat:@"\r\n@property (copy,nonatomic) NSArray* %@;\r\n",name];
    
    return s;
}

-(VXXInitMethod*)addInitMethod{
    
    VXXInitMethod* initMethod = [VXXInitMethod new];
    
    initMethod.hasArray = NO;
    
    [self.modelArr enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
       
        if([self.currentClass isEqualToString:key]){
            //当前类含有数组,需要添加语句
            initMethod.hasArray = YES;
            
            NSString* name = obj;
            
            NSString* newName = [VXXChangClassName changeNameWithName:name andMode:@"class"];
            
            //头文件
            
            NSString* importWordString = [NSString stringWithFormat:@"#import \"%@.h\"\r\n",newName];
  
            initMethod.importWords = importWordString;
            
            //构造方法
            NSString* initMethodString = [NSString stringWithFormat:@"\r\n\t\tNSMutableArray* mArr%@ = [NSMutableArray arrayWithCapacity:10];\r\n\r\n\t\tfor (NSDictionary* dict in self.%@) {\r\n\r\n\t\t\t%@* p = [%@ %@WithDict:dict];\r\n\r\n\t\t\t[mArr%@ addObject:p];\r\n\r\n\t\t\tself.%@ = mArr%@.copy;\r\n\r\n\t\t}",newName,name,newName,newName,name,newName,name,newName];
            
            initMethod.iniWords = initMethodString;
            
        }
        
    }];
    
    return initMethod;
}

-(NSString*)addInitExtraInMFile{
    
    NSString* s = self.classTypeDict[self.currentClass];
    
    NSMutableString* ms = [NSMutableString string];
    
    if ([s isEqualToString:@"NSArray"]) {
        
        [ms appendString:@"\n+(NSArray*)$classNameM/$WithData:(NSData*)data{\n\n\tNSArray* d = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];\n\n\tNSMutableArray* mArr = [NSMutableArray arrayWithCapacity:20];\n\n\tfor (NSDictionary* dict in d) {\n\n\t\t$className/$* t = [$className/$ $classNameM/$WithDict:dict];\n\n\t\t[mArr addObject:t];\n\n\t}\n\n\treturn mArr.copy;\n}"];
        
    }
    
    return ms;
}

-(NSString*)addInitExtraInHFile{
    
    NSString* s = self.classTypeDict[self.currentClass];
    
    NSMutableString* ms = [NSMutableString string];
    
    if ([s isEqualToString:@"NSArray"]) {
        
         [ms appendString:@"\n+(NSArray*)$classNameM/$WithData:(NSData*)data;\n"];
        
    }
    
    return ms;
}




@end