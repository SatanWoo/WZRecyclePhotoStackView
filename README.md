WZRecyclePhotoStackView
=======================

###想法###
大家想象一下，自己当捧着一堆照片的时候，我们是如何去放置我们的照片的？
可能我们会挑选出我们喜欢的照片放到相册中珍藏，也有可能我们把不喜欢的扔掉。
同时我们还会存在犹豫不觉的情况，觉得，哎，我先放到后面去，一会再看吧。

WZRecyclePhotoStackView就是模拟这种显示生活而产生的。
在上滑，下滑的部分，借鉴了<a href = "https://github.com/cwRichardKim/TinderSimpleSwipeCards">TinderSimpleSwipeCards</a>

###这个StackView的优势是什么？###
- 采用了内存池的设计方式，对于非图片开销，只生成了两个(可配置个数)的容器循环复用
- 避免了一次性加载数据的内存开销和时间损耗，通过可配置的方式将大量的数据通过多次添加加载进内存中。
同时通过预取的方式将这些新的数据自动补充进需要显示的位置。
- 支持左滑、右滑操作。右滑跳过当前照片，将照片置为底部，最后查看。左滑将底部照片拉回顶部，设置为当前查看。
- 高度定制化

###使用###
    @protocol WZPhotoStackViewDataSource <NSObject>
    @required
    - (UIImage *)photoForSkipStack:(WZPhotoStackView *)stackView;
    - (UIImage *)photoForRatingStack:(WZPhotoStackView *)stackView;
    - (NSUInteger)numberOfRatingPhotos;
    - (NSUInteger)numberOfSkipPhotos;
    - (BOOL)canFetchMoreData;
    - (void)fetchMoreDataFromCoreData;
    - (void)fetchSkipPhotos;
    
    @end
    
    typedef NS_ENUM(NSUInteger, WZPhotoStackStatus)
    {
        WZPhotoStackStatusLike = 0,
        WZPhotoStackStatusSkip = 1,
        WZPhotoStackStatusPullBack = 2,
        WZPhotoStackStatusAverage = 3
    };
    
    @protocol WZPhotoStackViewDelegate <NSObject>
    
    @optional
    - (void)didSkipPhoto:(UIImage *)photo;
    - (void)didBringBackPhoto:(UIImage *)photo;
    - (void)didRatePhotoAsLike:(UIImage *)photo;
    - (void)didRatePhotoAsHate:(UIImage *)photo;
    - (void)didFinishRateAllPhotos;
    @end

只要在您的viewcontroller中添加如下代码即可
    self.stackView = [[WZPhotoStackView alloc] initWithFrame:CGRectMake(0,
                                                                    0,
                                                                    CGRectGetWidth(self.view.frame),
                                                                    CGRectGetHeight(self.view.frame))];
    
    [self.view addSubview:self.stackView];
    
    self.stackView.delegate = self;
    self.stackView.dataSource = self;

###效果###
<img src = "http://xuntaimage.qiniudn.com/WZPhotoStackView.gif" />
