//
//  SQCommentModel.h
//  CommentDemo
//
//  Created by suqianghotel on 16/8/21.
//  Copyright © 2016年 suqianghotel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SQCommentModel : NSObject
@property(nonatomic, copy) NSString *from;
@property(nonatomic, copy) NSString *to;
@property(nonatomic, copy) NSString *content;

@property(nonatomic, copy) NSString *all;
@end
