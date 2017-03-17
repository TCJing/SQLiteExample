//
//  DBAccess.m
//  SQLiteUseInAPP
//
//  Created by 敬庭超 on 2017/3/16.
//  Copyright © 2017年 敬庭超. All rights reserved.
//

//sqlite3_errmsg函数获得错误码的文本信息
//构建应用会因为没有找到SQLite函数而失败。尽管包含合适的头文件，但编译器不知道从哪里查找SQLite库的二进制文件，所以需要将libsqlite框架添加到Xcode项目中.添加libsqlite3.0
#import "DBAccess.h"
static sqlite3 *database;
@implementation DBAccess
-(instancetype)init{
    if (self = [super init]) {
        [self initializeDatabase];
    }
    return self;
}
-(void)initializeDatabase{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"catalog" ofType:@"db"];
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) {
        NSLog(@"opening Database");
    }else{
        //打开失败
        sqlite3_close(database);
        //condition: 0 无条件抛出错误
        //获取错误信息： sqlite3_errmsg()
        NSAssert1(0, @"Failed to open database: '%s'.", sqlite3_errmsg(database));
    }
}
-(void)closeDatabase{
    if (sqlite3_close(database) != SQLITE_OK) {
        NSAssert1(0, @"Error: falied to close database: '%s'.", sqlite3_errmsg(database));
    }
}
-(NSMutableArray *)getAllProducts{
    NSMutableArray *products = [NSMutableArray array];
    const char *sql = "select Product.ProductID,Product.Name,Manufacturer.Name,Product.Details,Product.Price,Product.QuantityOnHand,Country.Country,Product.Image from Product,Manufacturer,Country where Manufacturer.ManufacturerID=Product.ManufacturerID and Product.CountryOfOriginID=Country.CountryID;";
    //要在代码中运行SQL查询，需要创建一个SQLite👉语句对象👈，该对象将在数据库上执行SQL语句。
    //结果集（结果的集合）
    sqlite3_stmt *statement;
    //准备statement来编译SQL查询 into byte-code
    /*参数以此为： 一个数据库连接 ， 一条SQL语句， 该语句的最大长度或-1(表明读取到第一个NULL为止)，用来遍历结果的语句句柄， 指向该SQL语句第一个字节的指针或此处使用的NULL*/
    //返回类型是一个int类型可以是SQLITE_OK或者一个错误码
    //应当注意的是这里是准备语句，并不实际执行该语句，直到调用sqlite3_step函数开始获取行之前该语句才执行
    //sqlite3_prepare预编译语句，既然是预编译这个时候就不会执行语句
    int sqlResult = sqlite3_prepare(database, sql, -1, &statement, NULL);
    //如果该函数返回OK，则可以使用sqlite3_step函数一次一行地遍历结果
    if (sqlResult == SQLITE_OK) {
        //sqlite3_step遍历结果集
        while (sqlite3_step(statement) == SQLITE_ROW) {
            //对于每一行，分配一个Product对象
            Product *product = [[Product alloc] init];
            /*
             现在已经从行中获取了数据。可以使用一组成为"结果集"接口的函数来获取指定字段。使用其中的哪个函数取决于想要获取的列的数据类型
             SQLITE_API const void *SQLITE_STDCALL sqlite3_column_blob(sqlite3_stmt*, int iCol);
             SQLITE_API int SQLITE_STDCALL sqlite3_column_bytes(sqlite3_stmt*, int iCol);
             SQLITE_API int SQLITE_STDCALL sqlite3_column_bytes16(sqlite3_stmt*, int iCol);
             SQLITE_API double SQLITE_STDCALL sqlite3_column_double(sqlite3_stmt*, int iCol);
             SQLITE_API int SQLITE_STDCALL sqlite3_column_int(sqlite3_stmt*, int iCol);
             SQLITE_API sqlite3_int64 SQLITE_STDCALL sqlite3_column_int64(sqlite3_stmt*, int iCol);
             SQLITE_API const unsigned char *SQLITE_STDCALL sqlite3_column_text(sqlite3_stmt*, int iCol);
             SQLITE_API const void *SQLITE_STDCALL sqlite3_column_text16(sqlite3_stmt*, int iCol);
             SQLITE_API int SQLITE_STDCALL sqlite3_column_type(sqlite3_stmt*, int iCol);
             SQLITE_API sqlite3_value *SQLITE_STDCALL sqlite3_column_value(sqlite3_stmt*, int iCol);
             
             该列表中的每一个函数的第一个参数是预编译的语句，第二个参数是想要获取的字段在SQL语句中的索引。该索引是基于0的。想要获取SQL语句中的第一个字段，即int类型的产品ID，需要使用下面这个函数：
             sqlite3_column_int(statement, 0);
             */
            char *name = (char *)sqlite3_column_text(statement, 1);
            char *manufacturer = (char *)sqlite3_column_text(statement, 2);
            char *details = (char *)sqlite3_column_text(statement, 3);
            char *countryOfOrigin = (char *)sqlite3_column_text(statement, 6);
            char *image = (char *)sqlite3_column_text(statement, 7);
            product.ID = sqlite3_column_int(statement, 0);
            product.name = (name) ? [NSString stringWithUTF8String:name] : @"";
            product.manufacturer = (manufacturer) ? [NSString stringWithUTF8String:manufacturer] : @"";
            product.details = (details) ? [NSString stringWithUTF8String:details] : @"";
            product.price = sqlite3_column_int(statement, 4);
            product.quantity = sqlite3_column_int(statement, 5);
            product.countryOfOrigin = (countryOfOrigin) ? [NSString stringWithUTF8String:countryOfOrigin] : @"";
            product.image = (image) ? [NSString stringWithUTF8String:image] : @"";
            [products addObject:product];
        }
        //调用sqlite3_finalize释放和预编译的语句相关的资源
        sqlite3_finalize(statement);
    }else{
        NSLog(@"Problem with the database:");
        NSLog(@"%d",sqlResult);
    }
    
    return products;
}
//参数化查询：
/*
 SQL提供了一系列函数用于绑定参数，
 
 SQLITE_API int SQLITE_STDCALL sqlite3_bind_blob(sqlite3_stmt*, int, const void*, int n, void(*)(void*));
 SQLITE_API int SQLITE_STDCALL sqlite3_bind_blob64(sqlite3_stmt*, int, const void*, sqlite3_uint64,
 void(*)(void*));
 SQLITE_API int SQLITE_STDCALL sqlite3_bind_double(sqlite3_stmt*, int, double);
 SQLITE_API int SQLITE_STDCALL sqlite3_bind_int(sqlite3_stmt*, int, int);
 SQLITE_API int SQLITE_STDCALL sqlite3_bind_int64(sqlite3_stmt*, int, sqlite3_int64);
 SQLITE_API int SQLITE_STDCALL sqlite3_bind_null(sqlite3_stmt*, int);
 SQLITE_API int SQLITE_STDCALL sqlite3_bind_text(sqlite3_stmt*,int,const char*,int,void(*)(void*));
 SQLITE_API int SQLITE_STDCALL sqlite3_bind_text16(sqlite3_stmt*, int, const void*, int, void(*)(void*));
 SQLITE_API int SQLITE_STDCALL sqlite3_bind_text64(sqlite3_stmt*, int, const char*, sqlite3_uint64,
 void(*)(void*), unsigned char encoding);
 SQLITE_API int SQLITE_STDCALL sqlite3_bind_value(sqlite3_stmt*, int, const sqlite3_value*);
 SQLITE_API int SQLITE_STDCALL sqlite3_bind_zeroblob(sqlite3_stmt*, int, int n);
 SQLITE_API int SQLITE_STDCALL sqlite3_bind_zeroblob64(sqlite3_stmt*, int, sqlite3_uint64);
 
 使用的绑定函数应该对应要绑定的数据类型。每个绑定函数的第一个参数是预编译语句。第二个参数是SQL语句中的参数索引(从1开始)。剩余的参数根据想要绑定的数据类型有所不同
 要在运行时绑定文本，可使用sqlite3_bind_text函数，如下所示：
 sqlite3_bind_text(statement,1,value,-1,SQLITE_TRANSIENT);
 value是运行时确定的文本
 */

//写入数据库：在本实例当中写入数据库会遇到问题，我们这里的数据库位于应用包中，😱但应用包是只读的😱。
/*
 为了能够写入数据库，需要创建一个可编辑的副本。在设备上将该可编辑的副本放入到😉文档目录中😉。
 */
//这段代码显示了如何检查可写的数据库是否已经存在，并且如果不存在，则创建一个可编辑的副本
//用bundle中的默认的database创建一个可编辑的副本到应用程序的documents文件夹中
-(void)createEditableDatabase {
    //查看可编辑的database是否已经存在
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    //获取沙盒的位置
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    //拼接document文件夹下的文件的路径
    NSString *writableDB = [documentsDir stringByAppendingPathComponent:@"catalog.db"];
    //判断文件是否存在
    success = [fileManager fileExistsAtPath:writableDB];
    //如果可编辑的database已经存在就返回
    if (success) return;
    //文件不存在。。。
    //获得database在应用包中的位置
    
    NSString *defaultPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"catalog.db"];
    //copy 副本 完成副本的拷贝
    //从应用包 -> 沙盒
    success = [fileManager copyItemAtPath:defaultPath toPath:writableDB error:&error];
    if (!success) {
        NSAssert1(0, @"Failed to create writable database file:'%@'.", [error localizedDescription]);
    }
}
@end
