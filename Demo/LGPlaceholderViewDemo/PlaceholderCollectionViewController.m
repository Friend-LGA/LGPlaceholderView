//
//  PlaceholderCollectionViewController.m
//  LGPlaceholderViewDemo
//
//  Created by Grigory Lutkov on 25.02.15.
//  Copyright (c) 2015 Grigory Lutkov. All rights reserved.
//

#import "PlaceholderCollectionViewController.h"
#import "LGPlaceholderView.h"

@interface PlaceholderCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) UILabel   *textLabel;
@property (strong, nonatomic) UIView    *separatorView;

@end

@implementation PlaceholderCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _textLabel = [UILabel new];
        _textLabel.font = [UIFont systemFontOfSize:16.f];
        [self addSubview:_textLabel];
        
        _separatorView = [UIView new];
        _separatorView.backgroundColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.f];
        [self addSubview:_separatorView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [_textLabel sizeToFit];
    _textLabel.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    _textLabel.frame = CGRectIntegral(_textLabel.frame);
    
    _separatorView.frame = CGRectMake(15.f, self.frame.size.height-1.f, self.frame.size.width-30.f, 1.f);
}

@end

#pragma mark -

@interface PlaceholderCollectionViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) UICollectionView  *collectionView;
@property (strong, nonatomic) NSArray           *textsArray;
@property (strong, nonatomic) LGPlaceholderView *placeholderView;

@end

@implementation PlaceholderCollectionViewController

- (id)initWithTitle:(NSString *)title
{
    self = [super init];
    if (self)
    {
        self.title = title;
        
        // -----
        
        UICollectionViewFlowLayout *collectionViewLayout = [UICollectionViewFlowLayout new];
        collectionViewLayout.sectionInset = UIEdgeInsetsZero;
        collectionViewLayout.minimumLineSpacing = 0.f;
        collectionViewLayout.minimumInteritemSpacing = 0.f;
        collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:collectionViewLayout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.alwaysBounceVertical = YES;
        _collectionView.allowsSelection = NO;
        [_collectionView registerClass:[PlaceholderCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
        [self.view addSubview:_collectionView];
        
        _textsArray = @[@"UICollectionViewCell 1",
                        @"UICollectionViewCell 2",
                        @"UICollectionViewCell 3",
                        @"UICollectionViewCell 4",
                        @"UICollectionViewCell 5"];
        
        _placeholderView = [[LGPlaceholderView alloc] initWithView:_collectionView];
        [_placeholderView showActivityIndicatorAnimated:NO completionHandler:nil];
    }
    return self;
}

#pragma mark - Dealloc

- (void)dealloc
{
    NSLog(@"%s [Line %d]", __PRETTY_FUNCTION__, __LINE__);
}

#pragma mark - Appearing

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    [_collectionView.collectionViewLayout invalidateLayout];
    
    _collectionView.frame = CGRectMake(0.f, 0.f, self.view.frame.size.width, self.view.frame.size.height);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void)
                   {
                       [_placeholderView dismissAnimated:YES completionHandler:nil];
                   });
}

#pragma mark - UICollectionView DataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _textsArray.count;
}

#pragma mark - UICollectionView Delegate

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PlaceholderCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.textLabel.text = _textsArray[indexPath.item];
    
    [cell setNeedsLayout];
    
    return cell;
}

#pragma mark - UICollectionViewLayout Delegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.view.frame.size.width, 44.f);
}

@end
