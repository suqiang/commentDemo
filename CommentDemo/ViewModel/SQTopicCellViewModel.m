//
//  SQTopicCellViewModel.m
//  CommentDemo
//
//  Created by suqianghotel on 16/8/21.
//  Copyright © 2016年 suqianghotel. All rights reserved.
//

#import "SQTopicCellViewModel.h"
#import "SQTopicModel.h"
#import "SQCommentModel.h"
#import "SQCommentCellViewModel.h"

@implementation SQTopicCellViewModel


- (void)setTopicModel:(SQTopicModel *)topicModel
{
    _topicModel = topicModel;
    
    CGFloat margin = 15;
    CGFloat conentW = [UIScreen mainScreen].bounds.size.width - 2 * margin;
    
    
    CGFloat iconX = margin;
    CGFloat iconY = margin;
    CGFloat iconWH = 50;
    
    self.iconF = CGRectMake(iconX, iconY, iconWH, iconWH);
    
    
    CGFloat nameLabelX = CGRectGetMaxX(self.iconF) + margin;
    CGFloat nameLabelW = 250;
    CGFloat nameLabelH = 20;
    
    CGFloat contentLabelX = nameLabelX;
    CGFloat contentLabelW = conentW - margin - iconWH;
    CGFloat contentLabelH = 0;
    
    UIFont *contentLabelFont = [UIFont systemFontOfSize:15];
    contentLabelH = [topicModel.content boundingRectWithSize:CGSizeMake(contentLabelW, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:contentLabelFont} context:nil].size.height;
    
    int lineNum = contentLabelH / contentLabelFont.lineHeight;
    
    
    CGFloat toggoleButtonX = contentLabelX;
    CGFloat toggoleButtonW = 32;
    CGFloat toggoleButtonH = 0;
    
    if (lineNum > 5) {
        
        if (topicModel.isExpanded == NO) {
            contentLabelH = contentLabelFont.lineHeight * 5;
        }
        toggoleButtonH = 20;
    
    }
    
    
    CGFloat tableViewX = contentLabelX;
    CGFloat tableViewW = [UIScreen mainScreen].bounds.size.width - margin - tableViewX;
    CGFloat tableViewH = 0;
    
    NSArray *commentModels = topicModel.commentModels;
    
    NSMutableArray *mutableVMs = [NSMutableArray array];
    
    if (commentModels.count > 0) {
        for (int i = 0; i < commentModels.count; i++) {
            SQCommentCellViewModel *commmentVM = [[SQCommentCellViewModel alloc] init];
            commmentVM.maxW = tableViewW;
            commmentVM.commentModel = commentModels[i];
            
            tableViewH += commmentVM.cellHeight;
            
            [mutableVMs addObject:commmentVM];
        }
    }
    self.commentCellViewModels = mutableVMs.copy;
    
    
    
    if (nameLabelH > 0) {
        self.cellHeight += margin;
        self.nameLabelF = CGRectMake(nameLabelX, self.cellHeight, nameLabelW, nameLabelH);
        self.cellHeight += nameLabelH;
    }
    
    if (contentLabelH > 0) {
        self.cellHeight += margin * 0.5;
        self.contentF = CGRectMake(contentLabelX, self.cellHeight, contentLabelW, contentLabelH);
        self.cellHeight += contentLabelH;
        
    }
    
    if (toggoleButtonH > 0) {
        self.cellHeight += margin * 0.5;
        self.toggoleButtonF = CGRectMake(toggoleButtonX,  self.cellHeight, toggoleButtonW, toggoleButtonH);
        self.cellHeight += toggoleButtonH;
    }
    
    if (tableViewH > 0) {
        self.cellHeight += margin * 0.5 ;
        self.tableviewF = CGRectMake(tableViewX, self.cellHeight, tableViewW, tableViewH);
        self.cellHeight += tableViewH;
    }

    
    self.cellHeight += margin * 0.5;
    
}

@end
