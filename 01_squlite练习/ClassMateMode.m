//
//  ClassMateMode.m
//  Sqllite3Cdemo
//
//  Created by qingyun on 15/10/19.
//  Copyright (c) 2015年 河南青云信息技术有限公司. All rights reserved.
//

#import "ClassMateMode.h"

@implementation ClassMateMode

-(instancetype)initWith:(NSString *)name Id:(int)ID phoneFor:(NSString *)phone icon:(NSData *)Icon{
    if (self=[super init]) {
        _ICON=Icon;
        _ID=ID;
        _NAME=name;
        _PHONE=phone;
    }
    return self;
}


@end
