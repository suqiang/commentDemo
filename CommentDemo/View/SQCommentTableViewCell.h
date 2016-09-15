//
//  SQCommentTableViewCell.h
//  CommentDemo
//
//  Created by suqianghotel on 16/8/21.
//  Copyright © 2016年 suqianghotel. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SQCommentCellViewModel, SQCommentTableViewCell;

@protocol SQCommentTableViewCellDelegate <NSObject>
- (void)cell:(SQCommentTableViewCell *)cell didUserInfoClicked:(NSString *)username;

@end
@interface SQCommentTableViewCell : UITableViewCell
@property(nonatomic, strong) SQCommentCellViewModel *commentCellVM;
@property(nonatomic, weak) id<SQCommentTableViewCellDelegate> delegate;

@end
