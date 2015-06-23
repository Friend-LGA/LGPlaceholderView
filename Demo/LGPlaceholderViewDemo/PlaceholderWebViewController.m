//
//  PlaceholderWebViewController.m
//  LGPlaceholderViewDemo
//
//  Created by Grigory Lutkov on 25.02.15.
//  Copyright (c) 2015 Grigory Lutkov. All rights reserved.
//

#import "PlaceholderWebViewController.h"
#import "LGPlaceholderView.h"

@interface PlaceholderWebViewController () <UIWebViewDelegate>

@property (strong, nonatomic) UIWebView         *webView;
@property (strong, nonatomic) LGPlaceholderView *placeholderView;

@end

@implementation PlaceholderWebViewController

- (id)initWithTitle:(NSString *)title
{
    self = [super init];
    if (self)
    {
        self.title = title;
        
        // -----
        
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://google.com"]];
        
        _webView = [UIWebView new];
        _webView.delegate = self;
        _webView.backgroundColor = [UIColor whiteColor];
        _webView.clipsToBounds = NO;
        _webView.scrollView.clipsToBounds = NO;
        [_webView loadRequest:request];
        [self.view addSubview:_webView];
        
        _placeholderView = [[LGPlaceholderView alloc] initWithView:_webView.scrollView];
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
    
    _webView.frame = CGRectMake(0.f, 0.f, self.view.frame.size.width, self.view.frame.size.height);
}

#pragma mark - UIWebView Delegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [_placeholderView dismissAnimated:YES completionHandler:nil];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [_placeholderView showText:@"Sorry, error occured while loading :(" animated:YES completionHandler:nil];
}

@end
