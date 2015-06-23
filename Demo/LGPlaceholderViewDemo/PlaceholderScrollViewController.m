//
//  PlaceholderScrollViewController.m
//  LGPlaceholderViewDemo
//
//  Created by Grigory Lutkov on 23.02.15.
//  Copyright (c) 2015 Grigory Lutkov. All rights reserved.
//

#import "PlaceholderScrollViewController.h"
#import "LGPlaceholderView.h"

@interface PlaceholderScrollViewController ()

@property (strong, nonatomic) UIScrollView      *scrollView;
@property (strong, nonatomic) UILabel           *textLabel;
@property (strong, nonatomic) LGPlaceholderView *placeholderView;

@end

@implementation PlaceholderScrollViewController

- (id)initWithTitle:(NSString *)title
{
    self = [super init];
    if (self)
    {
        self.title = title;
        
        // -----
        
        _scrollView = [UIScrollView new];
        _scrollView.backgroundColor = [UIColor whiteColor];
        _scrollView.alwaysBounceVertical = YES;
        [self.view addSubview:_scrollView];
        
        _textLabel = [UILabel new];
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.text = @"UIScrollView";
        [_scrollView addSubview:_textLabel];
        
        _placeholderView = [[LGPlaceholderView alloc] initWithView:_scrollView];
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
    
    _scrollView.frame = CGRectMake(0.f, 0.f, self.view.frame.size.width, self.view.frame.size.height);
    
    [_textLabel sizeToFit];
    _textLabel.center = CGPointMake(_scrollView.frame.size.width/2, 20.f+_textLabel.frame.size.height/2);
    _textLabel.frame = CGRectIntegral(_textLabel.frame);
    
    _scrollView.contentSize = CGSizeMake(self.view.frame.size.width, _textLabel.frame.origin.y+_textLabel.frame.size.height+20.f);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void)
                   {
                       [_placeholderView dismissAnimated:YES completionHandler:nil];
                   });
}

@end
