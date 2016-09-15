//
//  SQTopicTableViewCell.h
//  CommentDemo
//
//  Created by suqianghotel on 16/8/21.
//  Copyright © 2016年 suqianghotel. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SQTopicCellViewModel, SQTopicTableViewCell, SQCommentModel;


@protocol SQTopicTableViewCellDelegate <NSObject>

@optional
- (void)cell:(SQTopicTableViewCell *)cell didUserClicked:(NSString *)username;
- (void)cell:(SQTopicTableViewCell *)cell didReplyClicked:(SQCommentModel *)commentModel;
- (void)cellToggleExpentContent:(SQTopicTableViewCell *)cell;

@end

@interface SQTopicTableViewCell : UITableViewCell
@property(nonatomic, strong) SQTopicCellViewModel *topicViewModel;
@property(nonatomic, weak) id<SQTopicTableViewCellDelegate> delegate;
@end
