//
//  DBHandleOperation.h
//  FmdbDemo
//
//  Created by qingyun on 15/10/22.
//  Copyright (c) 2015年 河南青云信息技术有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

@class StudentMode;
@interface DBHandleOperation : NSObject

@property(nonatomic,strong)FMDatabase *db;

+(instancetype)shareHandle;
/*
 *插入数据
 */
-(BOOL)insertIntoMode:(StudentMode *)mode;
/*
 *更新数据
 */
-(BOOL)updateMode:(StudentMode *)mode;
 /*
 * 查询所有数据
 */
-(NSMutableArray *)selectALL;
 /*
 *根据ID删除一条记录
 */
-(BOOL)deleteForId:(int)Id;



@end
