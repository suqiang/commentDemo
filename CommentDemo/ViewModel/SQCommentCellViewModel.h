//
//  SQCommentCellViewModel.h
//  CommentDemo
//
//  Created by suqianghotel on 16/8/21.
//  Copyright © 2016年 suqianghotel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class SQCommentModel;
@interface SQCommentCellViewModel : NSObject
@property(nonatomic, assign) CGFloat maxW;
@property(nonatomic, strong) SQCommentModel *commentModel;
@property(nonatomic, copy) NSAttributedString *contentAttributedString;
@property(nonatomic, assign) CGRect  contentLabelF;
@property(nonatomic, assign) float cellHeight;
@end
