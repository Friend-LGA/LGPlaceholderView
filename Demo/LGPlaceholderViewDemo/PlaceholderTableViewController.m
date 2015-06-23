//
//  PlaceholderTableViewController.m
//  LGPlaceholderViewDemo
//
//  Created by Grigory Lutkov on 25.02.15.
//  Copyright (c) 2015 Grigory Lutkov. All rights reserved.
//

#import "PlaceholderTableViewController.h"
#import "LGPlaceholderView.h"

@interface PlaceholderTableViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView       *tableView;
@property (strong, nonatomic) NSArray           *textsArray;
@property (strong, nonatomic) LGPlaceholderView *placeholderView;

@end

@implementation PlaceholderTableViewController

- (id)initWithTitle:(NSString *)title
{
    self = [super init];
    if (self)
    {
        self.title = title;
        
        // -----
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.alwaysBounceVertical = YES;
        _tableView.allowsSelection = NO;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
        [self.view addSubview:_tableView];
        
        _textsArray = @[@"UITableViewCell 1",
                        @"UITableViewCell 2",
                        @"UITableViewCell 3",
                        @"UITableViewCell 4",
                        @"UITableViewCell 5"];
        
        _placeholderView = [[LGPlaceholderView alloc] initWithView:_tableView];
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
    
    _tableView.frame = CGRectMake(0.f, 0.f, self.view.frame.size.width, self.view.frame.size.height);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void)
                   {
                       [_placeholderView dismissAnimated:YES completionHandler:nil];
                   });
}

#pragma mark - UITableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _textsArray.count;
}

#pragma mark - UITableView Delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    cell.textLabel.font = [UIFont systemFontOfSize:16.f];
    cell.textLabel.text = _textsArray[indexPath.row];
    
    return cell;
}

@end
