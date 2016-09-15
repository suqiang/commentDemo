//
//  SQCommentModel.m
//  CommentDemo
//
//  Created by suqianghotel on 16/8/21.
//  Copyright © 2016年 suqianghotel. All rights reserved.
//

#import "SQCommentModel.h"

@implementation SQCommentModel

- (NSString *)all
{
    if (_all == nil) {
        
        if (self.to && self.to.length > 0) {
            _all = [NSString stringWithFormat:@"%@回复%@: %@", self.from, self.to, self.content];

        }
        else
        {
            _all = [NSString stringWithFormat:@"%@: %@", self.from, self.content];

        }
        
    }
    return _all;
}

@end
