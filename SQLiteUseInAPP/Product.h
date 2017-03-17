//
//  Product.h
//  SQLiteUseInAPP
//
//  Created by 敬庭超 on 2017/3/16.
//  Copyright © 2017年 敬庭超. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Product : NSObject
@property(nonatomic,assign) NSUInteger  ID;
@property(nonatomic,copy) NSString  *name;
@property(nonatomic,copy) NSString *manufacturer;
@property(nonatomic,copy) NSString  *details;
@property(nonatomic,assign) float  price;
@property(nonatomic,assign) NSUInteger  quantity;
@property(nonatomic,copy) NSString *countryOfOrigin;
@property(nonatomic,copy) NSString  *image;









@end
