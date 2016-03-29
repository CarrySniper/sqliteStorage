//
//  CKSqlStorage.m
//  sqliteStorage
//
//  Created by chen on 16/3/29.
//  Copyright © 2016年 ck_chan. All rights reserved.
//

#import "CKSqlStorage.h"

@implementation CKSqlStorage

/**
 *  第二步：实现声明单例方法 GCD
 *
 *  @return 返回单例对象
 */
+ (CKSqlStorage *)shareInstance
{
    static CKSqlStorage *singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[CKSqlStorage alloc] init];
    });
    return singleton;
}

/**
 *  初始化方法，创建数据库
 *
 *  @return 返回自身对象
 */
- (instancetype)init
{
    self = [super init];
    if (self) {
        //获取document目录路径
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:kDatabaseName];
        NSLog(@"数据库文件存放路径：%@",path);
        //判断是否存在数据库表
        BOOL isExst = [[NSFileManager defaultManager] fileExistsAtPath:path];
        if (isExst) {
            //如果存在，则直接open
            if(sqlite3_open([path UTF8String], &_database) != SQLITE_OK) {
                sqlite3_close(_database);
            }
        } else {
            //如果不存在，则CREATE一个名为：kTableName的主键为：uid的数据表。
            if (sqlite3_open([path UTF8String], &_database) == SQLITE_OK) {
                NSString *sqlStr = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' (id INTEGER PRIMARY KEY , key text, value text)",kTableName];
                const char *sqlCreateTable = [sqlStr UTF8String];
                sqlite3_stmt *statement;
                sqlite3_prepare_v2(_database, sqlCreateTable, -1, &statement, nil);
                sqlite3_step(statement);
                sqlite3_finalize(statement);
            } else {
                sqlite3_close(_database);
            }
        }
    }
    return self;
}

/**
 *  设置键值，插入或更新数据
 *
 *  @param value 值
 *  @param key   键
 */
- (void)setValue:(NSString *)value forKey:(NSString *)key
{
    sqlite3_stmt *statement = nil;
    NSString *valueStr = [self getValueForKey:key];
    if (valueStr) {
        //已有key，则可以更新UPDATE数据库中的值
        NSString *updateStr = [NSString stringWithFormat:@"UPDATE '%@' SET value=? WHERE key=?", kTableName];
        const char *sqlUpdate = [updateStr UTF8String];
        sqlite3_prepare_v2(_database, sqlUpdate, -1, &statement, NULL);
        sqlite3_bind_text(statement, 1, [value UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 2, [key UTF8String], -1, SQLITE_TRANSIENT);
        //这里的数字1，2，3，4代表上面的第几个问号，这里将值绑定变量
        
    }else{
        //没有key，则可以插入INSERT一条数据到数据库中
        NSString *insertStr = [NSString stringWithFormat:@"INSERT INTO '%@' (key, value) VALUES(?,?)", kTableName];
        const char *sqlInsert = [insertStr UTF8String];
        sqlite3_prepare_v2(_database, sqlInsert, -1, &statement, NULL);
        sqlite3_bind_text(statement, 1, [key UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 2, [value UTF8String], -1, SQLITE_TRANSIENT);
        //这里的数字1，2，3，4代表上面的第几个问号，这里将值绑定变量
    }
    sqlite3_step(statement);
    sqlite3_finalize(statement);    
}


/**
 *  查询语句，查询kTableName数据表中 是否存在该键key
 *
 *  @param key 所要查询的键
 *
 *  @return 查询结果的值，有即返回value，没有则返回nil
 */
- (NSString *)getValueForKey:(NSString *)key
{
    //查询语句SELECT
    NSString *sqlQuery = [NSString stringWithFormat: @"SELECT * FROM '%@' WHERE key = ?",kTableName];
    const char *sqlSelect = [sqlQuery UTF8String];
    sqlite3_stmt *statement = nil;
    sqlite3_prepare_v2(_database, sqlSelect, -1, &statement, NULL);
    sqlite3_bind_text(statement, 1, [key UTF8String], -1, SQLITE_TRANSIENT);
    //这里的数字1，2，3，4代表上面的第几个问号，这里将值绑定变量
    
    //查询结果集中一条一条的遍历所有的记录，这里的数字对应的是列值,注意这里的列值，跟上面sqlite3_bind_text绑定的列值不一样！一定要分开，不然会crash，只有这一处的列号不同，注意！
    while (sqlite3_step(statement) == SQLITE_ROW) {
        char *content = (char*)sqlite3_column_text(statement, 2);
        if(content) {
            NSString *value = [NSString stringWithCString:content encoding:NSUTF8StringEncoding];
            return value;
        }
    }
    sqlite3_finalize(statement);
    
    return nil;
}

/**
 *  删除键key对应的数据
 *
 *  @param key 所要删除的键
 */
- (void)deleteForKey:(NSString *)key
{
    NSString *deleteStr = [NSString stringWithFormat:@"DELETE FROM '%@' WHERE key = ?", kTableName];
    const char *sqlDelete = [deleteStr UTF8String];
    sqlite3_stmt *statement = nil;
    sqlite3_prepare_v2(_database, sqlDelete, -1, &statement, NULL);
    sqlite3_bind_text(statement, 1, [key UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_step(statement);
    sqlite3_finalize(statement);

}

/**
 *  删除所有数据
 */
- (void)deleteAllData
{
    NSString *deleteStr = [NSString stringWithFormat:@"DELETE FROM '%@'", kTableName];
    const char *sqlDelete = [deleteStr UTF8String];
    sqlite3_stmt *statement = nil;
    sqlite3_prepare_v2(_database, sqlDelete, -1, &statement, NULL);
    sqlite3_step(statement);
    sqlite3_finalize(statement);

}

- (void)dealloc {
    sqlite3_close(_database);
    _database = nil;
}

@end
