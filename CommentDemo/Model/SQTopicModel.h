//
//  SQTopicModel.h
//  CommentDemo
//
//  Created by suqianghotel on 16/8/21.
//  Copyright © 2016年 suqianghotel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SQTopicModel : NSObject
@property(nonatomic, copy) NSString *icon;
@property(nonatomic, copy) NSString *userame;
@property(nonatomic, copy) NSString *content;
@property(nonatomic, assign, getter = isExpanded) BOOL expanded;
@property(nonatomic, strong) NSArray *commentModels;
@end
