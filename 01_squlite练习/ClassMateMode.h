//
//  ClassMateMode.h
//  Sqllite3Cdemo
//
//  Created by qingyun on 15/10/19.
//  Copyright (c) 2015年 河南青云信息技术有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ClassMateMode : NSObject
@property(nonatomic,assign)int ID;
@property(nonatomic,strong)NSString *NAME;
@property(nonatomic,strong)NSString *PHONE;
@property(nonatomic,strong)NSData *ICON;

-(instancetype)initWith:(NSString *)name Id:(int)ID phoneFor:(NSString *)phone icon:(NSData *)Icon;

@end
