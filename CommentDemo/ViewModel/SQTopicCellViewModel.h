//
//  SQTopicCellViewModel.h
//  CommentDemo
//
//  Created by suqianghotel on 16/8/21.
//  Copyright © 2016年 suqianghotel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class SQTopicModel, SQCommentCellViewModel;

@interface SQTopicCellViewModel : NSObject
@property(nonatomic, strong) SQTopicModel *topicModel;
@property(nonatomic, strong) NSArray *commentCellViewModels;
@property(nonatomic, assign) CGRect iconF;
@property(nonatomic, assign) CGRect nameLabelF;
@property(nonatomic, assign) CGRect contentF;
@property(nonatomic, assign) CGRect toggoleButtonF;
@property(nonatomic, assign) CGRect tableviewF;
@property(nonatomic, assign) CGFloat cellHeight;

@end
