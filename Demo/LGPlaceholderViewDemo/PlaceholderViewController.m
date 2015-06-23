//
//  PlaceholderScrollViewController.m
//  LGPlaceholderViewDemo
//
//  Created by Grigory Lutkov on 23.02.15.
//  Copyright (c) 2015 Grigory Lutkov. All rights reserved.
//

#import "PlaceholderViewController.h"
#import "LGPlaceholderView.h"

@interface PlaceholderViewController ()

@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UILabel *textLabel;
@property (strong, nonatomic) LGPlaceholderView *placeholderView;

@end

@implementation PlaceholderViewController

- (id)initWithTitle:(NSString *)title
{
    self = [super init];
    if (self)
    {
        self.title = title;
        
        // -----
        
        _contentView = [UIView new];
        _contentView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_contentView];
        
        _textLabel = [UILabel new];
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.text = @"UIView";
        [_contentView addSubview:_textLabel];
        
        _placeholderView = [[LGPlaceholderView alloc] initWithView:_contentView];
        [_placeholderView showText:@"LGPlaceholderView" animated:NO completionHandler:nil];
    }
    return self;
}

#pragma mark - Dealloc

- (void)dealloc
{
    NSLog(@"%s [Line %d]", __PRETTY_FUNCTION__, __LINE__);
}

#pragma mark - Appearing

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void)
                   {
                       [self showPlaceholderType2];
                   });
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGFloat topInset = 0.f;
    if ([UIDevice currentDevice].systemVersion.floatValue >= 7.0)
    {
        topInset += (self.navigationController.navigationBarHidden ? 0.f : MIN(self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height));
        topInset += ([UIApplication sharedApplication].statusBarHidden ? 0.f : MIN([UIApplication sharedApplication].statusBarFrame.size.width, [UIApplication sharedApplication].statusBarFrame.size.height));
    }
    
    _contentView.frame = CGRectMake(0.f, topInset, self.view.frame.size.width, self.view.frame.size.height-topInset);
    
    [_textLabel sizeToFit];
    _textLabel.center = CGPointMake(_contentView.frame.size.width/2, 20.f+_textLabel.frame.size.height/2);
    _textLabel.frame = CGRectIntegral(_textLabel.frame);
}

#pragma mark -

- (void)showPlaceholderType2
{
    [_placeholderView showActivityIndicatorAnimated:YES completionHandler:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void)
                   {
                       [self showPlaceholderType3];
                   });
}

- (void)showPlaceholderType3
{
    [_placeholderView showActivityIndicatorWithText:@"LGPlaceholderView" animated:YES completionHandler:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void)
                   {
                       [self showPlaceholderType4];
                   });
}

- (void)showPlaceholderType4
{
    [_placeholderView showProgressViewAnimated:YES completionHandler:nil];
    
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timer:) userInfo:@{ @"type" : @1 } repeats:YES];
}

- (void)showPlaceholderType5
{
    [_placeholderView showProgressViewWithText:@"LGPlaceholderView" animated:YES completionHandler:nil];
    
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timer:) userInfo:@{ @"type" : @2 } repeats:YES];
}

- (void)timer:(NSTimer *)timer
{
    CGFloat progress = _placeholderView.progressValue+0.05;
    
    if (progress > 1.f) progress = 1.f;
    
    [_placeholderView setProgressValue:progress animated:YES];
    
    CGFloat percentage = progress*100.f;
    
    [_placeholderView setProgressText:[NSString stringWithFormat:@"%i %%", (int)percentage] animated:YES];
    
    if (progress == 1.f)
    {
        NSUInteger type = [timer.userInfo[@"type"] integerValue];
        
        [timer invalidate];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void)
                       {
                           if (type == 1) [self showPlaceholderType5];
                           else if (type == 2) [self showPlaceholderType6];
                       });
    }
}

- (void)showPlaceholderType6
{
    UIView *innerView = [UIView new];
    innerView.backgroundColor = [UIColor colorWithRed:0.f green:0.5 blue:1.f alpha:1.f];
    innerView.frame = CGRectMake(0.f, 0.f, 128.f, 128.f);
    
    UILabel *label = [UILabel new];
    label.backgroundColor = [UIColor clearColor];
    label.text = @"Some UIView";
    label.textColor = [UIColor whiteColor];
    [label sizeToFit];
    label.center = CGPointMake(innerView.frame.size.width/2, innerView.frame.size.height/2);
    label.frame = CGRectIntegral(label.frame);
    [innerView addSubview:label];
    
    [_placeholderView showView:innerView animated:YES completionHandler:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void)
                   {
                       [_placeholderView dismissAnimated:YES completionHandler:nil];
                   });
}

@end
