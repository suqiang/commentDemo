//
//  SQCommentCellViewModel.m
//  CommentDemo
//
//  Created by suqianghotel on 16/8/21.
//  Copyright © 2016年 suqianghotel. All rights reserved.
//

#import "SQCommentCellViewModel.h"
#import "SQCommentModel.h"


@implementation SQCommentCellViewModel


- (void)setCommentModel:(SQCommentModel *)commentModel
{
    _commentModel = commentModel;
    
    CGFloat margin = 5;
    
    CGFloat contentLabelX = margin;
    CGFloat contentLabelY = 2;
    CGFloat contentLabelW = self.maxW - 2 * margin;
    CGFloat contentLabelH = 0;
    
    
    NSMutableParagraphStyle *para = [[NSMutableParagraphStyle alloc] init];
    para.lineSpacing = 2;
    NSDictionary *attr = @{
                            NSParagraphStyleAttributeName: para,
                            NSFontAttributeName: [UIFont systemFontOfSize:14],
                            NSForegroundColorAttributeName: [UIColor colorWithRed:46/256.0 green:46/256.0 blue:46/256.0 alpha:1]
                           };
    
    self.contentAttributedString = [[NSAttributedString alloc] initWithString:commentModel.all attributes:attr];
    contentLabelH = [self.contentAttributedString boundingRectWithSize:CGSizeMake(contentLabelW, MAXFLOAT)  options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.height;
    
    self.contentLabelF = CGRectMake(contentLabelX, contentLabelY, contentLabelW, contentLabelH);
    
    self.cellHeight = CGRectGetMaxY(self.contentLabelF) + 2;
}


@end
