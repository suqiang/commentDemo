//
//  SQTopicTableViewCell.m
//  CommentDemo
//
//  Created by suqianghotel on 16/8/21.
//  Copyright © 2016年 suqianghotel. All rights reserved.
//

#import "SQTopicTableViewCell.h"
#import "SQCommentModel.h"
#import "SQTopicModel.h"
#import "SQTopicCellViewModel.h"
#import "SQCommentTableViewCell.h"
#import "SQCommentCellViewModel.h"
#import "TTTAttributedLabel.h"



@interface SQTopicTableViewCell()<UITableViewDelegate, UITableViewDataSource, SQCommentTableViewCellDelegate>
@property(nonatomic, strong) UIImageView *icon;
@property(nonatomic, strong) TTTAttributedLabel *nameLabel;
@property(nonatomic, strong) TTTAttributedLabel *topicLabel;
@property(nonatomic, strong) UITableView *commentTableView;
@property(nonatomic, strong) UIButton *toggoleButton;
@end

@implementation SQTopicTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.preservesSuperviewLayoutMargins = YES;
        
        
        if ([self respondsToSelector:@selector(setSeparatorInset:)]) {
            [self setSeparatorInset:UIEdgeInsetsMake(0, 15, 0, 15)];
        }
        
        // Prevent the cell from inheriting the Table View's margin settings
        if ([self respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
            [self setPreservesSuperviewLayoutMargins:NO];
        }
        
        // Explictly set your cell's layout margins
        if ([self respondsToSelector:@selector(setLayoutMargins:)]) {
            [self setLayoutMargins:UIEdgeInsetsZero];
        }
        
        _icon = [[UIImageView alloc] init];
        [self.contentView addSubview:_icon];
        
        
        
        
        _nameLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
        _nameLabel.numberOfLines = 1;
        _nameLabel.linkAttributes = @{NSForegroundColorAttributeName: [UIColor colorWithRed:0/256.0 green:87/256.0 blue:168/256.0 alpha:1]};
        _nameLabel.activeLinkAttributes = @{NSForegroundColorAttributeName: [UIColor colorWithRed:140/256.0 green:87/256.0 blue:168/256.0 alpha:1]};
        [self.contentView addSubview:_nameLabel];
        
        _topicLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
        _topicLabel.numberOfLines = 0;
        _topicLabel.font = [UIFont systemFontOfSize:15];
        _toggoleButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [self.contentView addSubview:_topicLabel];
        
        _toggoleButton = [[UIButton alloc] init];
        _toggoleButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_toggoleButton setTitleColor:[UIColor colorWithRed:0/256.0 green:87/256.0 blue:168/256.0 alpha:1] forState:UIControlStateNormal];
        [_toggoleButton addTarget:self action:@selector(didToggoleButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_toggoleButton];
        
        _commentTableView = [[UITableView alloc] initWithFrame:CGRectZero];
        _commentTableView.delegate = self;
        _commentTableView.dataSource = self;
        _commentTableView.backgroundColor = [UIColor colorWithRed:236/256.0 green:236/256.0 blue:236/256.0 alpha:1];
        _commentTableView.bounces = NO;
        _commentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_commentTableView registerClass:[SQCommentTableViewCell class] forCellReuseIdentifier:@"comment"];
        [self.contentView addSubview:_commentTableView];
        
    }
    
    return self;
}

- (void)didToggoleButtonClicked:(UIButton *)button
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(cellToggleExpentContent:)]) {
        [self.delegate cellToggleExpentContent:self];
    }
}

- (void)cell:(SQCommentTableViewCell *)cell didUserInfoClicked:(NSString *)username
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(cell:didUserClicked:)]) {
        [self.delegate cell:self didUserClicked:username];
    }
}


- (void)setTopicViewModel:(SQTopicCellViewModel *)topicViewModel
{
    _topicViewModel = topicViewModel;
    
    self.icon.image = [UIImage imageNamed:topicViewModel.topicModel.icon];
    self.icon.frame = topicViewModel.iconF;
    
    
    
    
    
    self.nameLabel.frame = topicViewModel.nameLabelF;
    self.nameLabel.text = topicViewModel.topicModel.userame;
    TTTAttributedLabelLink *nameLink = [self.nameLabel addLinkToPhoneNumber:topicViewModel.topicModel.userame
                               withRange:NSMakeRange(0, topicViewModel.topicModel.userame.length)];

    
    nameLink.linkTapBlock = ^(TTTAttributedLabel *label, TTTAttributedLabelLink *link)
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(cell:didUserClicked:)]) {
            [self.delegate cell:self didUserClicked:topicViewModel.topicModel.userame];
        }
    };

    
    self.topicLabel.text = topicViewModel.topicModel.content;
    self.topicLabel.frame = topicViewModel.contentF;
    
    self.toggoleButton.frame = topicViewModel.toggoleButtonF;
    if (topicViewModel.topicModel.isExpanded) {
        [self.toggoleButton setTitle:@"收起" forState:UIControlStateNormal];
        
    }
    else
    {
        [self.toggoleButton setTitle:@"全文" forState:UIControlStateNormal];
    }
    
    
    self.toggoleButton.frame = topicViewModel.toggoleButtonF;
    self.toggoleButton.hidden = topicViewModel.toggoleButtonF.size.height == 0;
    
    
    self.commentTableView.frame = topicViewModel.tableviewF;
    [self.commentTableView reloadData];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    SQCommentCellViewModel *topicViewModel = self.topicViewModel.commentCellViewModels[indexPath.row];
    
    return topicViewModel.cellHeight;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(cell:didReplyClicked:)]) {
        [self.delegate cell:self didReplyClicked:((SQCommentCellViewModel *)self.topicViewModel.commentCellViewModels[indexPath.row]).commentModel];
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.topicViewModel.commentCellViewModels.count;;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SQCommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"comment"];
    
    cell.commentCellVM = self.topicViewModel.commentCellViewModels[indexPath.row];
    cell.delegate = self;
    return cell;
}

@end
