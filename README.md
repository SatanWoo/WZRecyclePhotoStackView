WZRecyclePhotoStackView
=======================

### 想法 ###
大家想象一下，自己当捧着一堆照片的时候，我们是如何去放置我们的照片的？
可能我们会挑选出我们喜欢的照片放到相册中珍藏，也有可能我们把不喜欢的扔掉。
同时我们还会存在犹豫不觉的情况，觉得，哎，我先放到后面去，一会再看吧。
当然，也有可能，您会考虑，哎，我之前一张是什么图来着，我忘记了，我拿回来看看。

WZRecyclePhotoStackView就是模拟这种生活中的情形而产生的。
在上滑，下滑的部分，借鉴了<a href = "https://github.com/cwRichardKim/TinderSimpleSwipeCards">TinderSimpleSwipeCards</a>

### 这个StackView的优势是什么？ ###
- 采用了内存池的设计方式，对于非图片开销，只生成了两个(可配置个数)的容器循环复用
- 避免了一次性加载数据的内存开销和时间损耗，通过可配置的方式将大量的数据通过多次小部分添加加载进内存中。
同时通过预取的方式将这些新的数据自动补充进需要显示的位置。（在预取过程中您完全可以按照需要修改为异步回调形式）
- 支持左滑、右滑操作。右滑跳过当前照片，将照片置为底部，最后查看。左滑将底部照片拉回顶部，设置为当前查看。
- 高度定制化

### 使用 ###
        typedef NS_ENUM(NSUInteger, WZPhotoStackStatus)
        {
            WZPhotoStackStatusLike = 0,    //上滑 作为喜欢
            WZPhotoStackStatusSkip = 1,    //右滑 作为将照片置于底部
            WZPhotoStackStatusPullBack = 2,//左滑 作为将底部照片取回
            WZPhotoStackStatusHate = 3     //下滑 作为讨厌
        };
        
        @protocol WZPhotoStackViewDataSource <NSObject>
        @required
        - (UIImage *)photoForSkipQueueInStack:(WZPhotoStackView *)stackView;
        - (UIImage *)photoForRatingQueueInStack:(WZPhotoStackView *)stackView;
        - (NSUInteger)numberOfRatingPhotosInStack:(WZPhotoStackView *)stackView;
        - (NSUInteger)numberOfSkipPhotosInStack:(WZPhotoStackView *)stackView;
        - (BOOL)canFetchMoreDataInStack:(WZPhotoStackView *)stackView;
        - (void)fetchMoreDataFromCoreDataInStack:(WZPhotoStackView *)stackView;
        - (void)fetchSkipPhotosInStack:(WZPhotoStackView *)stackView;
        
        @end
        
        @protocol WZPhotoStackViewDelegate <NSObject>
        @optional
        - (void)didSkipPhoto:(UIImage *)photo       inStackView:(WZPhotoStackView *)stackView;
        - (void)didBringBackPhoto:(UIImage *)photo  inStackView:(WZPhotoStackView *)stackView;
        - (void)didRatePhotoAsLike:(UIImage *)photo inStackView:(WZPhotoStackView *)stackView;
        - (void)didRatePhotoAsHate:(UIImage *)photo inStackView:(WZPhotoStackView *)stackView;
        - (void)didFinishRateAllPhotosInStackView:(WZPhotoStackView *)stackView;
        @end

只要在您的viewcontroller中添加如下代码即可

    self.stackView = [[WZPhotoStackView alloc] initWithFrame:CGRectMake(0,
                                                                    0,
                                                                    CGRectGetWidth(self.view.frame),
                                                                    CGRectGetHeight(self.view.frame))];
    
    [self.view addSubview:self.stackView];
    
    self.stackView.delegate = self;
    self.stackView.dataSource = self;

### 效果 ###
<img src = "http://xuntaimage.qiniudn.com/WZPhotoStackView.gif" />
