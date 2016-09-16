# commentDemo
微信朋友圈消息流简单实现方案

# 界面展示
![微信Fed](http://o7obltx2h.bkt.clouddn.com/image/blog/weixin_fed.gif)

### 需求描述
* 列表页展现消息流
* 消息内容支持`全文`和`收起`功能
* 消息支持评论，评论条数`不限制`
* 用户信息`支持点击`进入用户中心

### 技术分析
* 列表页展现消息流

> * 消息流一般采用tableview实现
> * tableview实现又分为`自动布局`和`绝对布局`（即Frame布局）。
> * `自动布局`可以采用[UITableView-FDTemplateLayoutCell](https://github.com/forkingdog/UITableView-FDTemplateLayoutCell)分方案实施。这种方案可以自动计算cell高度，但笔者认为一下几种情况，不要使用`自动布局`。对于简单页面的屏幕适配，当然首推`自动布局`（masonry）
>   * cell交互要求较高
>   * cell布局复杂，view元素较多, 层级深
>   * 对性能要求较高
> * `Frame布局`
>   * 缺点：计算复杂（相对于`masonry`自动布局）
>   * 优点： 性能好，可控性强，易动画，扩展维护成本低

>> 两种布局方式不是本文的重点，这里不在多说，笔者偏好是Frame布局，本文案例也将采用这种方式

* 消息内容支持`全文`和`收起`功能
  * 需要计算文字行数，判断两种方式
* 消息支持评论，评论条数`不限制`
  * 对于一般社区类帖子评论，都会有个评论列表页，在原帖下方最多显示3条评论，然后查看更多，直接跳转到评论列表页；这种情况不用考虑性能和内存问题，直接用三个Label实现即可。
  * 对于消息评论不限条数，那么就要好好设计了，笔者这里采用的是cell里面放tableView的方式来承载无限评论条数
* 用户信息`支持点击`进入用户中心
  * 富文本链接支持点击，这里采用了一个轻量级的第三方框架[TTTAttributedLabel](https://github.com/TTTAttributedLabel/TTTAttributedLabel)
  * 如果要实现较为复杂的富文本可以采用[YYKit](https://github.com/ibireme/YYKit)或[TYAttributedLabel](https://github.com/12207480/TYAttributedLabel)

### 程序架构
***目录结构***

```
|____Controller
| |____SQTopicTableViewController.h
| |____SQTopicTableViewController.m
| |____SQUserCenterViewController.h
| |____SQUserCenterViewController.m
|____Model
| |____SQCommentModel.h
| |____SQCommentModel.m
| |____SQTopicModel.h
| |____SQTopicModel.m
|____View
| |____SQCommentTableViewCell.h
| |____SQCommentTableViewCell.m
| |____SQTopicTableViewCell.h
| |____SQTopicTableViewCell.m
|____ViewModel
| |____SQCommentCellViewModel.h
| |____SQCommentCellViewModel.m
| |____SQTopicCellViewModel.h
| |____SQTopicCellViewModel.m
|____Library
| |____TTTAttributedLabel
| | |____TTTAttributedLabel.h
| | |____TTTAttributedLabel.m

```

项目采用的是MVVM的分层结构
![MVVM](http://o7obltx2h.bkt.clouddn.com/image/blog/weixin_mvvm.png)

* 项目的ViewModel的作用

> - 实际项目中我们从服务器获取的数据，转换为模型（Model）后，对应的数据有些不能直接显示在视图（View）上，需要二次处理。  
> - 那么处理放在哪里里好？
>> - 笔者在一些项目里，直接把这些数据格式化直接放在了Model里，有的是在set/get方法直接格式化数据，有的是增加辅助属性，这就是传说中的`胖模型`吧.
>> - 后果是模型复用性降低;因为相同的模型，相同字段，在不同场景要被格式化的样式不一样。增加的辅助字段，越来越多，有时自己都回忆不起来这个辅助字段的实际意义。想一想还是保持模型的「纯真」吧，将复杂的数据处理，交给各自View对应的ViewModel;

* tableView结合viewModel的使用

> tableviewcell高度计算，是tableView使用以及优化的重点对象，最好的方式莫过于高度缓存。但如何计算，如何缓存，如何使用的？笔者分享一下此项目采用的方案：

* ViewModel模型，持有Model，并开放cell中各个子view布局属性，以及部分格式化后的模型字段,以及`cellHeight`缓存cell高度

```objc
@interface SQTopicCellViewModel : NSObject
// 持有原始数据模型
@property(nonatomic, strong) SQTopicModel *topicModel;
@property(nonatomic, strong) NSArray *commentCellViewModels;
// cell 各个子元素布局属性
@property(nonatomic, assign) CGRect iconF;
@property(nonatomic, assign) CGRect nameLabelF;
@property(nonatomic, assign) CGRect contentF;
@property(nonatomic, assign) CGRect toggoleButtonF;
@property(nonatomic, assign) CGRect tableviewF;
// 缓存cell高度
@property(nonatomic, assign) CGFloat cellHeight;
@end
```

* 重新ViewModel的set模型方法（即项目的`setTopicModel`方法），根据数据计算cell各个资源的布局，以及格式化数据

```objc
- (void)setTopicModel:(SQTopicModel *)topicModel
{
    _topicModel = topicModel;

    CGFloat margin = 15;
    CGFloat conentW = [UIScreen mainScreen].bounds.size.width - 2 * margin;

    CGFloat iconX = margin;
    CGFloat iconY = margin;
    CGFloat iconWH = 50;


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

    // 计算cell高度，坐标Y值
    。。。

}
```

* cell持有自身ViewModel模型, 在tableView的数据源给cell注入viewModel时，确定cell各元素布局以及数据

```objc
- (void)setTopicViewModel:(SQTopicCellViewModel *)topicViewModel
{
    _topicViewModel = topicViewModel;

    self.icon.image = [UIImage imageNamed:topicViewModel.topicModel.icon];
    self.icon.frame = topicViewModel.iconF;

    self.nameLabel.frame = topicViewModel.nameLabelF;
    self.nameLabel.text = topicViewModel.topicModel.userame;

    。。。
}
```


* viewModel高度（cellHeight）计算，某些cell的子元素，根据数据不一定显示，需要单独判端。笔者开始采用的是在计算完成一个元素后，就判断是否显示，并确定`y`值。但是如果后面元素的显示如果依赖于上一元素的位置，甚至是嵌套依赖，那么情况就会变得过于复杂，笔者把这部分放到了最后，只根据高度是否大于0来判读，各元素是否显示，在计算是通过赋值自身高度是否为零即可

```objc
- (void)setTopicModel:(SQTopicModel *)topicModel
{
    _topicModel = topicModel;
    // 计算各个子元素的大小
    。。。

    // 计算cell高度，各元素坐标Y值
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
    。。。。
    self.cellHeight += margin * 0.5;

}
```

* cell评论区实现
> cell持有一个tableview（专门给评论列表显示）， 把代理、数据源给自己。每一条评论也设计成tableviewcell, 有着自己的viewModel(SQCommentCellViewModel),实现逻辑上述相似，不在重复

```objc
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
        // 其他元素
        。。。

        // tableview
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

- (void)setTopicViewModel:(SQTopicCellViewModel *)topicViewModel
{
    _topicViewModel = topicViewModel;

    // 其他布局数据设值
    。。。。

    //tablevew布局，加载数据
    self.commentTableView.frame = topicViewModel.tableviewF; // 这里的tableviewF的计算在上层ViewModel中（即____SQTopicTableViewCell）
    [self.commentTableView reloadData];  // 数据源初始化以及组装也在SQTopicCellViewModel中commentCellViewModels

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
```

*评论的tableview高度是如何计算的?*  
在`SQTopicCellViewModel`中持有commentCellViewModels数组， 在将评论原始数据转化我ViewModel中时，能确定各个评论cell的高度，数组中所有高度加起来，就是评论tableview的高度

```objc
- (void)setTopicModel:(SQTopicModel *)topicModel
{
    _topicModel = topicModel;

    。。。

    CGFloat tableViewX = contentLabelX;
    CGFloat tableViewW = [UIScreen mainScreen].bounds.size.width - margin - tableViewX;
    CGFloat tableViewH = 0;

    NSArray *commentModels = topicModel.commentModels;

    NSMutableArray *mutableVMs = [NSMutableArray array];

    if (commentModels.count > 0) {
       for (int i = 0; i < commentModels.count; i++) {
           SQCommentCellViewModel *commmentVM = [[SQCommentCellViewModel alloc] init];
           commmentVM.maxW = tableViewW;        // 先要给出宽度，方便评论cell根据文字计算出自身高度
           commmentVM.commentModel = commentModels[i];

           tableViewH += commmentVM.cellHeight; // 所有高度加起来

           [mutableVMs addObject:commmentVM];   
       }
    }
    self.commentCellViewModels = mutableVMs.copy;// 构造数据源

    。。。

}
```


* 展开全文实现
> * 正文高度大于5行，显示全文按钮；点击全文按钮，展开全文，按钮变为收起；点击收起，折叠内容
> * 文字计算判断行数，笔者这里直接更具字体的lineHeight计算的，如果是AttribedString，带行距时，可能计算不准，这里没找到更好的方式，如有更好的方式，欢迎再评论区回复。
> * 在模型中增加了一个辅助属性isExpanded用来标识当前数据是否被展开。目的是防止：1.cell重用，导致布局混乱。2. 展开的数据在滑动后，被关闭

```objc
。。。

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

。。。

```

> 将 `收起/全文`事件代理给vc

```objc
- (void)cellToggleExpentContent:(SQTopicTableViewCell *)cell
{
    // 查询位置
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];

    SQTopicCellViewModel *viewModel = self.dataArray[indexPath.row];
    // 修改展开状态
    viewModel.topicModel.expanded = !viewModel.topicModel.isExpanded;

    // 更新布局
    SQTopicCellViewModel *newViewModel = [[SQTopicCellViewModel alloc] init];
    newViewModel.topicModel = viewModel.topicModel;

    // 替换数据
    [self.dataArray replaceObjectAtIndex:indexPath.row withObject:newViewModel];

    // 局部刷新表格
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];

}
```

* TTTAttributedLabel链接点击实现

```objc

// TTTAttributedLabel初始化
_contentLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
_contentLabel.numberOfLines = 0;
_contentLabel.textColor = [UIColor blackColor];
_contentLabel.font = [UIFont systemFontOfSize:14];
_contentLabel.linkAttributes = @{NSForegroundColorAttributeName: [UIColor colorWithRed:0/256.0 green:87/256.0 blue:168/256.0 alpha:1]};
_contentLabel.activeLinkAttributes = @{NSForegroundColorAttributeName: [UIColor colorWithRed:140/256.0 green:87/256.0 blue:168/256.0 alpha:1]};

// TTTAttributedLabel 添加事件
TTTAttributedLabelLink *fromLink = [self.contentLabel addLinkToPhoneNumber:commentCellVM.commentModel.from withRange:NSMakeRange(0, commentCellVM.commentModel.from.length)];

fromLink.linkTapBlock = ^(TTTAttributedLabel *label, TTTAttributedLabelLink *link)
{

    if (self.delegate && [self.delegate respondsToSelector:@selector(cell:didUserInfoClicked:)]) {
        [self.delegate cell:self didUserInfoClicked:commentCellVM.commentModel.from];
    }

};

```


* cell事件传递实现
>  事件传递三种方式`delegate`, `notification`, `block`。笔者项目采用的是代理`delegate`，将所有事件代理给viewcontroller

  **代理的事件**
  * 主帖用户信息点击
  * 展开全文点击
  * 评论用户信息点击
  * 评论cell点击

> 其中`评论用户信息点击`,`评论cell点击`采用的是代理嵌套代理的方式实现。应为这两个事件是在子tableview（评论taleview）的cell上，中间有个嵌套关系，暂时没有找到方法，可以减少这一层嵌套。个人认为，两层代理嵌套，是可接受的，并不会太混乱；，如有更好的方式，请在评论区回复。

```objc
@protocol SQTopicTableViewCellDelegate <NSObject>
@optional
- (void)cell:(SQTopicTableViewCell *)cell didUserClicked:(NSString *)username;
- (void)cell:(SQTopicTableViewCell *)cell didReplyClicked:(SQCommentModel *)commentModel;
- (void)cellToggleExpentContent:(SQTopicTableViewCell *)cell;
@end
```

### 详细说明
[仿微信朋友圈消息流简单实现](http://suqianghotel.com/2016/09/14/ios-tableview-weixin-comment-md/)
