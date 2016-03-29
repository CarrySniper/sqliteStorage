//
//  CKSqlStorage.h
//  sqliteStorage
//
//  Created by chen on 16/3/29.
//  Copyright © 2016年 ck_chan. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <sqlite3.h>                                 //要添加libsqlite3(dylib/tbd)框架

static NSString *kDatabaseName = @"cjqDB.sqlite";   //数据库的名称,可以定义成任何类型的文件
static NSString *kTableName = @"userInfo";          //数据表的名称

@interface CKSqlStorage : NSObject{
    sqlite3 *_database;

}

//第一步：创建声明单例方法
+ (CKSqlStorage *)shareInstance;

- (void)setValue:(NSString *)value forKey:(NSString *)key;

- (NSString *)getValueForKey:(NSString *)key;

- (void)deleteForKey:(NSString *)key;

- (void)deleteAllData;

//第三步：声明想要保存的数据类型

#define KEY_USER_UID            @"sqlUserId"        //保存用户的uid
#define KEY_USER_NAME           @"sqlUserName"      //保存用户的名称
#define KEY_USER_PHONE          @"sqlUserPhone"     //保存用户的手机


//第四步：通过单例保存数据

/*
 赋值：[[CKSqlStorage shareInstance] setValue:@"89757" forKey:KEY_USER_UID];
 取值：NSString *value = [[CKSqlStorage shareInstance] getValueForKey:KEY_USER_UID];
 */

@end
