//
//  DBHandleOperation.m
//  FmdbDemo
//
//  Created by qingyun on 15/10/22.
//  Copyright (c) 2015年 河南青云信息技术有限公司. All rights reserved.
//

#import "DBHandleOperation.h"
#import "ClassMateMode.h"


#define  fileDB @"student.DB"

@interface DBHandleOperation ()
//数据库对象


@end

@implementation DBHandleOperation

+(instancetype)shareHandle{
    static DBHandleOperation *opration;
    static dispatch_once_t  once;
    dispatch_once(&once, ^{
        opration=[[DBHandleOperation alloc] init];
        [opration createTable];
    });

    return opration;
}

//创建数据库
-(BOOL)crateDB{
    //1.文件路径
    NSString *filePath=[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:fileDB];
    if (!_db) {
        _db=[FMDatabase databaseWithPath:filePath];
        return YES;
    }
    return NO;
}
//打开数据库
-(BOOL)openDB{
    
    return [_db open];
}
//关闭数据库
-(BOOL)closeDB{

    return [_db close];
}

//创建表
-(BOOL)createTable{
   //创建数据库
    if ([self crateDB]) {
       //打开数据库
        if ([self openDB]) {
         //sql
          NSString *sql=@"CReate table if not exists ClassMate(ID INTEGER PRIMARY KEY,NAME TEXT,PHONE text,ICON BLOB)";
         //执行我们sql语句
            if (![_db executeUpdate:sql]) {
                NSLog(@"======创建表失败");
                [self closeDB];
                return NO;
            }
         //关闭数据库
            [self closeDB];
            return YES;
        }
     }
 return NO;
}

-(BOOL)insertIntoMode:(ClassMateMode *)mode{
    //打开我们的数据库
    if ([self openDB]) {
     //编写我们的sql
     NSString *sql=@"insert into students values(?,?,?,?,?)";
     //执行插入操作
     if (![_db executeUpdate:sql,[NSNumber numberWithInt:mode.ID],mode.NAME,mode.PHONE,mode.ICON]) {
            NSLog(@"===插入失败");
         [self closeDB];
         return NO;
        }
        [self closeDB];
        
        return YES;
    }
    return NO;
}

-(BOOL)updateMode:(ClassMateMode *)mode{

    //打开我们的数据库
    if ([self openDB]) {
    //sql语句
      NSString *sql=@"update students set NAME=?,PHONE=?,ICON=? WHERE ID=?";
     
    //执行更新
        if (![_db executeUpdate:sql,mode.NAME,mode.PHONE,mode.ICON,[NSNumber numberWithInt:mode.ID]]) {
            NSLog(@"更新失败");
            [self closeDB];
            return NO;
        }
        [self closeDB];
        return YES;
     }
    return NO;
}

-(NSMutableArray *)selectALL{

    //打开我们的数据库
    if ([self openDB]) {
    //sql 语句
     NSString *sql=@"select *from students";
     //结果集对象
     FMResultSet *r=[_db executeQuery:sql];
        
     //存的数组
        NSMutableArray *arr=[NSMutableArray array];
        
     while ([r next]) {
      NSDictionary *dicValue= [r resultDictionary];
      //[arr addObject:   [[ClassMateMode alloc] initWithDic:dicValue]];
     }
        [self closeDB];
        return arr;
    }
    return nil;

}

-(BOOL)deleteForId:(int)Id{
   //打开数据库
    if(![self openDB]){
        return NO;
    }
   //sql
    NSString *sql=@"delete from students where ID=?";
   //执行sql
    
    if (![_db executeUpdate:sql,[NSNumber numberWithInt:Id]]) {
        NSLog(@"删除失败");
        
        [self closeDB];
        return NO;
    };
    [self closeDB];
    return YES;

}





@end
