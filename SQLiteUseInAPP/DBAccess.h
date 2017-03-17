//
//  DBAccess.h
//  SQLiteUseInAPP
//
//  Created by 敬庭超 on 2017/3/16.
//  Copyright © 2017年 敬庭超. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Product.h"
#import <sqlite3.h>
@interface DBAccess : NSObject
-(NSMutableArray *)getAllProducts;
-(void)closeDatabase;
-(void)initializeDatabase;
@end
