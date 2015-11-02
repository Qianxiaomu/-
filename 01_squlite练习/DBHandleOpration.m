//
//  DBHandleOpration.m
//  Sqllite3Cdemo
//
//  Created by qingyun on 15/10/19.
//  Copyright (c) 2015年 河南青云信息技术有限公司. All rights reserved.
//

#import "DBHandleOpration.h"
#import "ClassMateMode.h"
#include <sqlite3.h>
#define DB @"CLASS.DB"

//_db   数据库对象
static sqlite3 *_db;

@implementation DBHandleOpration

+(instancetype)ShardDBHandle{

    static dispatch_once_t once;
    static DBHandleOpration *opration;

    
    dispatch_once(&once, ^{
    //只会执行一次
      opration=[[DBHandleOpration alloc] init];
      //创建表
      [opration creatTable];
  });
    return opration;
}



//获取要存储的文件路径
//libary 文件夹
-(NSString *)getPath{
    return NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0];
}
//打开数据库
-(BOOL)openDb{
    if(_db){
     return YES;
    }
    const char *file=[[[self getPath] stringByAppendingPathComponent:DB] UTF8String];
    //打开数据库 给_db 句柄赋值
    int result=sqlite3_open(file, &_db);
    if (result!=SQLITE_OK) {
        NSLog(@"=====打开数据库失败");
        return  NO ;
    }
    return YES;
}
//关闭数据库
-(BOOL)CloseDb{
    if(sqlite3_close(_db)!=SQLITE_OK){
        NSLog(@"=====关闭数据库失败");
        return NO;
    }
    //关闭数据后，将我们_db释放，为了我们的打开数据库的判断
    _db=NULL;
    NSLog(@"关闭数据库成功");
    return YES;
}

-(BOOL)creatTable{
  NSString *sql=@"create table if not exists ClassMate(ID INTEGER PRIMARY KEY,NAME TEXT,PHONE TEXT UNIQUE,ICON BLOB)";
 //1 打开数据库
    if(![self openDb]){
        return NO;
    }
    
 //2.执行sql
    char *merrmsg;
    if(sqlite3_exec(_db, [sql UTF8String], NULL, NULL, &merrmsg)!=SQLITE_OK){
        NSLog(@"%s",merrmsg);
        [self CloseDb];
        free(merrmsg);
        return NO;
    }
 //3.关闭数据库
    [self CloseDb];
    return YES;
}

-(BOOL)insertFisrt:(ClassMateMode *)mode{
//1 打开数据库
    if (![self openDb]) {
      return NO;
    }
//2将sql语句转成我们的预编译语句对象
  //2.1 SQL 语句edit
    NSString *sql=@"insert into ClassMate(ID,NAME,PHONE,ICON)Values(?,?,?,?)";
  //2.2 声明预编译指针
     //第三个参数 表示我们sql语句的全部 -1
     //第五个参数 表示 sql地址，一般传 null
    sqlite3_stmt *stmt;
    if(sqlite3_prepare_v2(_db,[sql UTF8String], -1,&stmt, NULL)!=SQLITE_OK){
        NSLog(@"预编译失败");
        [self CloseDb];
        return NO;
    };
//3 bind 参数
   //;
   
    sqlite3_bind_int(stmt,1,mode.ID);
    // 四个参数 -1 全部  字符串的长度
    //第五个参数  是个析构函数 对我们没有 用 NULL
    sqlite3_bind_text(stmt, 2, [mode.NAME UTF8String], -1, NULL);
    sqlite3_bind_text(stmt, 3,[mode.PHONE UTF8String],(int)strlen([mode.PHONE UTF8String]), NULL);
    sqlite3_bind_blob(stmt, 4, mode.ICON.bytes,(int)mode.ICON.length, NULL);
    
//4执行预编译对象 step
    if(sqlite3_step(stmt)!=SQLITE_DONE){
        NSLog(@"===执行没有完成");
        [self CloseDb];
        return NO;
    };
//5释放预编译对象
    sqlite3_finalize(stmt);
//6关闭数据库
    [self CloseDb];
    return YES;
}

-(BOOL)updateValueForMode:(ClassMateMode *)mode{
 //1打开数据库
    if (![self openDb]) {
        return NO;
    }
 //2编写sql语句
    NSString *sql=@"update ClassMate set NAME=?,PHONE=?,ICON=? WHERE ID=?";
 //3将sql语句转换成预编译对象 句柄
    //预编译对象
    sqlite3_stmt *stmt;
    //第三个参数 -1 表示sql语句的全部
    //第五个参数 null sql的地址 与我们没有关系；传null即可
    if(sqlite3_prepare_v2(_db, [sql UTF8String], -1, &stmt, NULL)!=SQLITE_OK){
        NSLog(@"预编译失败");
        [self CloseDb];
        return NO;
    }
 //4.bind 参数
    sqlite3_bind_text(stmt, 1, [mode.NAME UTF8String], -1, NULL);
    sqlite3_bind_text(stmt, 2, [mode.PHONE UTF8String], -1, NULL);
    sqlite3_bind_blob(stmt, 3, mode.ICON.bytes, (int)mode.ICON.length, NULL);
    sqlite3_bind_int(stmt, 4, mode.ID);
 //5执行step 预编译对象
    if(sqlite3_step(stmt)!=SQLITE_DONE){
        NSLog(@"执行失败");
        [self CloseDb];
        return NO;
    }
    
 //6.释放预编译对象
    sqlite3_finalize(stmt);
 //7 关闭数据库
    [self CloseDb];
    
    return YES;
}

-(NSMutableArray *)selectAll{
  //1 打开数据库
    if (![self openDb]) {
         return nil;
    }
    
  //2编辑sql
    NSString *sql=@"select * from ClassMate";

  //3 将sql转化成我们的预编译对象
    //3.1 预编译对像
    sqlite3_stmt *stmt;
    if(sqlite3_prepare_v2(_db, [sql UTF8String], -1, &stmt, NULL)!=SQLITE_OK){
        NSLog(@"编译失败");
        [self CloseDb];
        return nil;
    }
  //4执行预编译
    //创建一个数组
    NSMutableArray *dataArr;
    while (sqlite3_step(stmt)==SQLITE_ROW) {
        if (!dataArr) {
            dataArr=[NSMutableArray array];
        }
        
    //4.2 循环读取每列字段
      //4.2.1 读取我们ID
      int ID=sqlite3_column_int(stmt, 0);
      
      //4.2.2 读取我们NAME
     const unsigned char *name=sqlite3_column_text(stmt, 1);
        
      //4.2.3 读取我们PHONE
      const unsigned char *phone=sqlite3_column_text(stmt, 2);

      //4.2.4 读取我们icon
     const void*icon=sqlite3_column_blob(stmt, 3);
     int size=sqlite3_column_bytes(stmt, 3);
        NSData *data=[NSData dataWithBytes:icon length:size];
        //创建mode
     ClassMateMode *mode=[[ClassMateMode alloc] initWith:[NSString stringWithUTF8String:(const char *)name] Id:ID phoneFor:[NSString stringWithUTF8String:(const char *)phone] icon:data];
        [dataArr addObject:mode];
        
    }
    

    //5释放预编译对象
    sqlite3_finalize(stmt);
    
    //6关闭数据库
    [self CloseDb];
    
    return dataArr;
}

-(BOOL)deleteValueForMode:(ClassMateMode *)mode
{
    if (![self openDb]) {
        return NO;
    }
    NSString *sql = [NSString stringWithFormat:@"delete from ClassMate where ID= %d ",mode.ID];
    //where NAME = '%@', 防止中文,mode.NAME;
    char *errmsg;
    if (sqlite3_exec(_db, [sql UTF8String], NULL, NULL, &errmsg)!=SQLITE_OK) {
        NSLog(@"%s",errmsg);
        [self CloseDb];
        free(errmsg);
        return NO;
    }
    [self CloseDb];
    return YES;
}

@end
