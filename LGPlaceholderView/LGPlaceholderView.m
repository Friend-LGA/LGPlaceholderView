//
//  LGPlaceholderView.m
//  LGPlaceholderView
//
//
//  The MIT License (MIT)
//
//  Copyright (c) 2015 Grigory Lutkov <Friend.LGA@gmail.com>
//  (https://github.com/Friend-LGA/LGPlaceholderView)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import "LGPlaceholderView.h"

static NSString *kProgressTextDefault = @"0 %";
static CGFloat const  kDistantBetweenComponents   = 10.f;

@interface LGPlaceholderView ()

typedef NS_ENUM(NSUInteger, LGPlaceholderViewType)
{
    LGPlaceholderViewTypeText                     = 0,
    LGPlaceholderViewTypeActivityIndicator        = 1,
    LGPlaceholderViewTypeActivityIndicatorAndText = 2,
    LGPlaceholderViewTypeProgressView             = 3,
    LGPlaceholderViewTypeProgressViewAndText      = 4,
    LGPlaceholderViewTypeInnerView                = 5
};

@property (assign, nonatomic, getter=isObserversAdded)  BOOL observersAdded;

@property (assign, nonatomic, getter=isParentViewShowsHorizontalScrollIndicator)    BOOL parentViewShowsHorizontalScrollIndicator;
@property (assign, nonatomic, getter=isParentViewShowsVerticalScrollIndicator)      BOOL parentViewShowsVerticalScrollIndicator;
@property (assign, nonatomic, getter=isParentViewUserInteractionEnabled)            BOOL parentViewUserInteractionEnabled;

@property (assign, nonatomic) UITableViewCellSeparatorStyle parentViewSeparatorStyle;

@property (assign, nonatomic) LGPlaceholderViewType type;

@property (assign, nonatomic) UIView        *parentView;
@property (strong, nonatomic) UIView        *backgroundView;
@property (strong, nonatomic) UIView        *wrapperView;
@property (strong, nonatomic) UIImageView   *savedWrapperView;

@property (strong, nonatomic) UIActivityIndicatorView   *activityIndicator;
@property (strong, nonatomic) UIProgressView            *progressView;
@property (strong, nonatomic) UILabel                   *progressLabel;
@property (strong, nonatomic) UILabel                   *textLabel;
@property (assign, nonatomic) UIView                    *innerView;

@end

@implementation LGPlaceholderView

- (instancetype)initWithView:(UIView *)view
{
    self = [super init];
    if (self)
    {
        _parentView = view;

        _tintColor = [UIColor colorWithRed:0.f green:0.5 blue:1.f alpha:1.f];
        _font = [UIFont systemFontOfSize:18.f];
        _textAlignment = NSTextAlignmentCenter;
        _progressText = kProgressTextDefault;
        _contentInset = UIEdgeInsetsMake(20.f, 20.f, 20.f, 20.f);

        [super setBackgroundColor:[UIColor clearColor]];

        self.clipsToBounds = NO;
        self.layer.zPosition = FLT_MAX;

        _backgroundView = [UIView new];
        _backgroundView.alpha = 0.f;

        if (![_parentView.backgroundColor isEqual:[UIColor clearColor]])
            _backgroundView.backgroundColor = [_parentView.backgroundColor colorWithAlphaComponent:1.f];
        else
            _backgroundView.backgroundColor = [UIColor whiteColor];

        [self addSubview:_backgroundView];
    }
    return self;
}

+ (instancetype)placeholderViewWithView:(UIView *)view
{
    return [[self alloc] initWithView:view];
}

#pragma mark - Dealloc

- (void)dealloc
{
#if DEBUG
    NSLog(@"%s [Line %d]", __PRETTY_FUNCTION__, __LINE__);
#endif
}

#pragma mark -

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];

    if (!newSuperview)
        [self removeObservers];
    else
        [self addObservers];
}

#pragma mark - Setters and Getters

- (void)setContentInset:(UIEdgeInsets)contentInset
{
    if (!UIEdgeInsetsEqualToEdgeInsets(_contentInset, contentInset))
    {
        _contentInset = contentInset;

        [self layoutInvalidate];
    }
}

- (void)setTintColor:(UIColor *)tintColor
{
    _tintColor = tintColor;

    if (_activityIndicator) _activityIndicator.color = _tintColor;
    if (_progressView) _progressView.tintColor = _tintColor;
    if (_progressLabel) _progressLabel.textColor = _tintColor;
    if (_textLabel) _textLabel.textColor = _tintColor;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    if (_backgroundView)
        _backgroundView.backgroundColor = backgroundColor;
}

- (void)setProgressValue:(float)progressValue animated:(BOOL)animated
{
    _progressValue = progressValue;

    if (_progressView) [_progressView setProgress:_progressValue animated:animated];
}

- (void)setProgressText:(NSString *)progressText animated:(BOOL)animated
{
    _progressText = progressText;

    if (_progressLabel)
    {
        _progressLabel.text = _progressText;

        CGSize progressLabelSize = [_progressLabel sizeThatFits:CGSizeMake(_wrapperView.frame.size.width, CGFLOAT_MAX)];

        CGFloat progressLabelOriginX = _wrapperView.frame.size.width/2-progressLabelSize.width/2;
        if (_progressLabel.textAlignment == NSTextAlignmentLeft) progressLabelOriginX = 0.f;
        else if (_progressLabel.textAlignment == NSTextAlignmentRight) progressLabelOriginX = _wrapperView.frame.size.width-progressLabelSize.width;

        CGRect progressLabelFrame = CGRectMake(progressLabelOriginX,
                                               _progressView.frame.origin.y+_progressView.frame.size.height+kDistantBetweenComponents,
                                               progressLabelSize.width,
                                               progressLabelSize.height);
        if ([UIScreen mainScreen].scale == 1.f) progressLabelFrame = CGRectIntegral(progressLabelFrame);
        _progressLabel.frame = progressLabelFrame;

        if (animated)
            [UIView transitionWithView:_progressLabel
                              duration:0.2
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:nil
                            completion:nil];
    }
}

- (void)setFont:(UIFont *)font
{
    _font = font;

    BOOL isChanged = NO;

    if (_textLabel)
    {
        _textLabel.font = _font;

        isChanged = YES;
    }

    if (_progressLabel)
    {
        _progressLabel.font = _font;

        isChanged = YES;
    }

    if (isChanged) [self layoutInvalidate];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment
{
    _textAlignment = textAlignment;

    BOOL isChanged = NO;

    if (_textLabel)
    {
        _textLabel.textAlignment = _textAlignment;

        isChanged = YES;
    }

    if (_progressLabel)
    {
        _progressLabel.textAlignment = _textAlignment;

        isChanged = YES;
    }

    if (isChanged) [self layoutInvalidate];
}

#pragma mark -

- (void)layoutInvalidate
{
    if (self.superview && self.isShowing)
    {
        UIEdgeInsets parentInset = UIEdgeInsetsZero;
        CGPoint selfOffset = CGPointZero;

        if ([_parentView isKindOfClass:[UIScrollView class]])
        {
            UIScrollView *parentScrollView = (UIScrollView *)_parentView;

            parentInset = parentScrollView.contentInset;
            CGPoint parentOffset = parentScrollView.contentOffset;

            if (parentOffset.y >= -parentInset.top) selfOffset.y = parentOffset.y+parentInset.top;

            if (parentOffset.x >= -parentInset.left) selfOffset.x = parentOffset.x+parentInset.left;

            if (parentScrollView.contentSize.height > parentScrollView.frame.size.height-parentInset.top-parentInset.bottom)
            {
                if (parentOffset.y > parentScrollView.contentSize.height-parentScrollView.frame.size.height+parentInset.bottom)
                    selfOffset.y = parentScrollView.contentSize.height-self.frame.size.height;
            }
            else selfOffset.y = 0.f;

            if (parentScrollView.contentSize.width > parentScrollView.frame.size.width-parentInset.left-parentInset.right)
            {
                if (parentOffset.x > parentScrollView.contentSize.width-parentScrollView.frame.size.width+parentInset.right)
                    selfOffset.x = parentScrollView.contentSize.width-self.frame.size.width;
            }
            else selfOffset.x = 0.f;
        }

        // -----

        CGRect selfFrame = CGRectMake(selfOffset.x, selfOffset.y, _parentView.frame.size.width-parentInset.left-parentInset.right, _parentView.frame.size.height-parentInset.top-parentInset.bottom);
        if ([UIScreen mainScreen].scale == 1.f) selfFrame = CGRectIntegral(selfFrame);
        self.frame = selfFrame;

        _backgroundView.frame = CGRectMake(0.f, 0.f, self.frame.size.width, self.frame.size.height);

        // -----

        CGSize wrapperSize = CGSizeMake(self.frame.size.width-_contentInset.left-_contentInset.right, self.frame.size.height-_contentInset.top-_contentInset.bottom);
        CGRect wrapperFrame = CGRectMake(_contentInset.left, _contentInset.top, wrapperSize.width, wrapperSize.height);
        if ([UIScreen mainScreen].scale == 1.f) wrapperFrame = CGRectIntegral(wrapperFrame);

        if (_savedWrapperView) _savedWrapperView.frame = wrapperFrame;

        _wrapperView.frame = wrapperFrame;

        // -----

        if (_type == LGPlaceholderViewTypeText)
        {
            CGSize textLabelSize = [_textLabel sizeThatFits:CGSizeMake(_wrapperView.frame.size.width, CGFLOAT_MAX)];

            CGFloat textLabelOriginX = _wrapperView.frame.size.width/2-textLabelSize.width/2;
            if (_textLabel.textAlignment == NSTextAlignmentLeft) textLabelOriginX = 0.f;
            else if (_textLabel.textAlignment == NSTextAlignmentRight) textLabelOriginX = _wrapperView.frame.size.width-textLabelSize.width;

            CGRect textLabelFrame = CGRectMake(textLabelOriginX,
                                               _wrapperView.frame.size.height/2-textLabelSize.height/2,
                                               textLabelSize.width,
                                               textLabelSize.height);
            if ([UIScreen mainScreen].scale == 1.f) textLabelFrame = CGRectIntegral(textLabelFrame);
            _textLabel.frame = textLabelFrame;
        }
        else if (_type == LGPlaceholderViewTypeActivityIndicator)
        {
            CGRect activityIndicatorFrame = CGRectMake(_wrapperView.frame.size.width/2-_activityIndicator.frame.size.width/2,
                                                       _wrapperView.frame.size.height/2-_activityIndicator.frame.size.height/2,
                                                       _activityIndicator.frame.size.width,
                                                       _activityIndicator.frame.size.height);
            if ([UIScreen mainScreen].scale == 1.f) activityIndicatorFrame = CGRectIntegral(activityIndicatorFrame);
            _activityIndicator.frame = activityIndicatorFrame;
        }
        else if (_type == LGPlaceholderViewTypeActivityIndicatorAndText)
        {
            CGSize textLabelSize = [_textLabel sizeThatFits:CGSizeMake(_wrapperView.frame.size.width, CGFLOAT_MAX)];

            CGFloat commonHeight = textLabelSize.height+kDistantBetweenComponents+_activityIndicator.frame.size.height;

            CGFloat textLabelOriginX = _wrapperView.frame.size.width/2-textLabelSize.width/2;
            if (_textLabel.textAlignment == NSTextAlignmentLeft) textLabelOriginX = 0.f;
            else if (_textLabel.textAlignment == NSTextAlignmentRight) textLabelOriginX = _wrapperView.frame.size.width-textLabelSize.width;

            CGRect textLabelFrame = CGRectMake(textLabelOriginX,
                                               _wrapperView.frame.size.height/2-commonHeight/2,
                                               textLabelSize.width,
                                               textLabelSize.height);
            if ([UIScreen mainScreen].scale == 1.f) textLabelFrame = CGRectIntegral(textLabelFrame);
            _textLabel.frame = textLabelFrame;

            CGRect activityIndicatorFrame = CGRectMake(_wrapperView.frame.size.width/2-_activityIndicator.frame.size.width/2,
                                                       _textLabel.frame.origin.y+_textLabel.frame.size.height+kDistantBetweenComponents,
                                                       _activityIndicator.frame.size.width,
                                                       _activityIndicator.frame.size.height);
            if ([UIScreen mainScreen].scale == 1.f) activityIndicatorFrame = CGRectIntegral(activityIndicatorFrame);
            _activityIndicator.frame = activityIndicatorFrame;
        }
        else if (_type == LGPlaceholderViewTypeProgressView)
        {
            CGSize progressLabelSize = [_progressLabel sizeThatFits:CGSizeMake(_wrapperView.frame.size.width, CGFLOAT_MAX)];

            CGFloat commonHeight = _progressView.frame.size.height+kDistantBetweenComponents+progressLabelSize.height;

            CGRect progressViewFrame = CGRectMake(0.f,
                                                  _wrapperView.frame.size.height/2-commonHeight/2,
                                                  _wrapperView.frame.size.width,
                                                  _progressView.frame.size.height);
            if ([UIScreen mainScreen].scale == 1.f) progressViewFrame = CGRectIntegral(progressViewFrame);
            _progressView.frame = progressViewFrame;

            CGFloat progressLabelOriginX = _wrapperView.frame.size.width/2-progressLabelSize.width/2;
            if (_progressLabel.textAlignment == NSTextAlignmentLeft) progressLabelOriginX = 0.f;
            else if (_progressLabel.textAlignment == NSTextAlignmentRight) progressLabelOriginX = _wrapperView.frame.size.width-progressLabelSize.width;

            CGRect progressLabelFrame = CGRectMake(progressLabelOriginX,
                                                   _progressView.frame.origin.y+_progressView.frame.size.height+kDistantBetweenComponents,
                                                   progressLabelSize.width,
                                                   progressLabelSize.height);
            if ([UIScreen mainScreen].scale == 1.f) progressLabelFrame = CGRectIntegral(progressLabelFrame);
            _progressLabel.frame = progressLabelFrame;
        }
        else if (_type == LGPlaceholderViewTypeProgressViewAndText)
        {
            CGSize textLabelSize = [_textLabel sizeThatFits:CGSizeMake(_wrapperView.frame.size.width, CGFLOAT_MAX)];
            CGSize progressLabelSize = [_progressLabel sizeThatFits:CGSizeMake(_wrapperView.frame.size.width, CGFLOAT_MAX)];

            CGFloat commonHeight = textLabelSize.height+kDistantBetweenComponents+_progressView.frame.size.height+kDistantBetweenComponents+progressLabelSize.height;

            CGFloat textLabelOriginX = _wrapperView.frame.size.width/2-textLabelSize.width/2;
            if (_textLabel.textAlignment == NSTextAlignmentLeft) textLabelOriginX = 0.f;
            else if (_textLabel.textAlignment == NSTextAlignmentRight) textLabelOriginX = _wrapperView.frame.size.width-textLabelSize.width;

            CGRect textLabelFrame = CGRectMake(textLabelOriginX,
                                               _wrapperView.frame.size.height/2-commonHeight/2,
                                               textLabelSize.width,
                                               textLabelSize.height);
            if ([UIScreen mainScreen].scale == 1.f) textLabelFrame = CGRectIntegral(textLabelFrame);
            _textLabel.frame = textLabelFrame;

            CGRect progressViewFrame = CGRectMake(0.f,
                                                  _textLabel.frame.origin.y+_textLabel.frame.size.height+kDistantBetweenComponents,
                                                  _wrapperView.frame.size.width,
                                                  _progressView.frame.size.height);
            if ([UIScreen mainScreen].scale == 1.f) progressViewFrame = CGRectIntegral(progressViewFrame);
            _progressView.frame = progressViewFrame;

            CGFloat progressLabelOriginX = _wrapperView.frame.size.width/2-progressLabelSize.width/2;
            if (_progressLabel.textAlignment == NSTextAlignmentLeft) progressLabelOriginX = 0.f;
            else if (_progressLabel.textAlignment == NSTextAlignmentRight) progressLabelOriginX = _wrapperView.frame.size.width-progressLabelSize.width;

            CGRect progressLabelFrame = CGRectMake(progressLabelOriginX,
                                                   _progressView.frame.origin.y+_progressView.frame.size.height+kDistantBetweenComponents,
                                                   progressLabelSize.width,
                                                   progressLabelSize.height);
            if ([UIScreen mainScreen].scale == 1.f) progressLabelFrame = CGRectIntegral(progressLabelFrame);
            _progressLabel.frame = progressLabelFrame;
        }
        else if (_type == LGPlaceholderViewTypeInnerView)
        {
            CGRect innerViewFrame = CGRectMake(_wrapperView.frame.size.width/2-_innerView.frame.size.width/2,
                                               _wrapperView.frame.size.height/2-_innerView.frame.size.height/2,
                                               _innerView.frame.size.width,
                                               _innerView.frame.size.height);
            if ([UIScreen mainScreen].scale == 1.f) innerViewFrame = CGRectIntegral(innerViewFrame);
            _innerView.frame = innerViewFrame;
        }
    }
}

- (void)updatePosition
{
    if (self.superview)
    {
        UIEdgeInsets parentInset = UIEdgeInsetsZero;
        CGPoint selfOffset = CGPointZero;

        if ([_parentView isKindOfClass:[UIScrollView class]])
        {
            UIScrollView *parentScrollView = (UIScrollView *)_parentView;

            parentInset = parentScrollView.contentInset;
            CGPoint parentOffset = parentScrollView.contentOffset;

            if (parentOffset.y >= -parentInset.top) selfOffset.y = parentOffset.y+parentInset.top;

            if (parentOffset.x >= -parentInset.left) selfOffset.x = parentOffset.x+parentInset.left;

            if (parentScrollView.contentSize.height > parentScrollView.frame.size.height-parentInset.top-parentInset.bottom)
            {
                if (parentOffset.y > parentScrollView.contentSize.height-parentScrollView.frame.size.height+parentInset.bottom)
                    selfOffset.y = parentScrollView.contentSize.height-self.frame.size.height;
            }
            else selfOffset.y = 0.f;

            if (parentScrollView.contentSize.width > parentScrollView.frame.size.width-parentInset.left-parentInset.right)
            {
                if (parentOffset.x > parentScrollView.contentSize.width-parentScrollView.frame.size.width+parentInset.right)
                    selfOffset.x = parentScrollView.contentSize.width-self.frame.size.width;
            }
            else selfOffset.x = 0.f;
        }

        // -----

        CGRect selfFrame = CGRectMake(selfOffset.x, selfOffset.y, _parentView.frame.size.width-parentInset.left-parentInset.right, _parentView.frame.size.height-parentInset.top-parentInset.bottom);
        if ([UIScreen mainScreen].scale == 1.f) selfFrame = CGRectIntegral(selfFrame);
        self.center = CGPointMake(selfFrame.origin.x+selfFrame.size.width/2, selfFrame.origin.y+selfFrame.size.height/2);
    }
}

- (void)saveWrapperViewImageIfNeeded
{
    if (_wrapperView)
    {
        UIImage *image = [LGPlaceholderView screenshotMakeOfView:_wrapperView inPixels:NO];

        _savedWrapperView = [[UIImageView alloc] initWithImage:image];
        _savedWrapperView.contentMode = UIViewContentModeCenter;
        [self addSubview:_savedWrapperView];
    }

    // -----

    [self removeSubviews];

    [self restoreDefaults];

    // -----

    _wrapperView = [UIView new];
    _wrapperView.alpha = 0.f;
    _wrapperView.backgroundColor = [UIColor clearColor];
    _wrapperView.clipsToBounds = NO;
    [self addSubview:_wrapperView];
}

- (void)removeSubviews
{
    if (_activityIndicator)
    {
        [_activityIndicator removeFromSuperview];
        self.activityIndicator = nil;
    }

    if (_progressView)
    {
        [_progressView removeFromSuperview];
        self.progressView = nil;
    }

    if (_progressLabel)
    {
        [_progressLabel removeFromSuperview];
        self.progressLabel = nil;
    }

    if (_textLabel)
    {
        [_textLabel removeFromSuperview];
        self.textLabel = nil;
    }

    if (_innerView)
    {
        [_innerView removeFromSuperview];
        self.innerView = nil;
    }

    [_wrapperView removeFromSuperview];
    self.wrapperView = nil;
}

- (void)restoreDefaults
{
    _progressValue = 0.f;
    _progressText = kProgressTextDefault;
}

- (UILabel *)makeLabelWithText:(NSString *)text
{
    UILabel *label = [UILabel new];
    label.text = text;
    label.font = _font;
    label.textColor = _tintColor;
    label.textAlignment = _textAlignment;
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.backgroundColor = [UIColor clearColor];

    return label;
}

#pragma mark -

- (void)showText:(NSString *)text animated:(BOOL)animated completionHandler:(void(^)())completionHandler
{
    [self saveWrapperViewImageIfNeeded];

    _textLabel = [self makeLabelWithText:text];
    [_wrapperView addSubview:_textLabel];

    _type = LGPlaceholderViewTypeText;

    [self showAnimated:animated completionHandler:completionHandler];
}

#pragma mark -

- (void)showActivityIndicatorWithText:(NSString *)text animated:(BOOL)animated completionHandler:(void(^)())completionHandler
{
    [self saveWrapperViewImageIfNeeded];

    if (text.length)
    {
        _textLabel = [self makeLabelWithText:text];
        [_wrapperView addSubview:_textLabel];
    }

    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _activityIndicator.backgroundColor = [UIColor clearColor];
    _activityIndicator.color = _tintColor;
    [_activityIndicator startAnimating];
    [_wrapperView addSubview:_activityIndicator];

    _type = (text.length ? LGPlaceholderViewTypeActivityIndicatorAndText : LGPlaceholderViewTypeActivityIndicator);

    [self showAnimated:animated completionHandler:completionHandler];
}

- (void)showActivityIndicatorAnimated:(BOOL)animated completionHandler:(void(^)())completionHandler
{
    [self showActivityIndicatorWithText:nil animated:animated completionHandler:completionHandler];
}

#pragma mark -

- (void)showProgressViewWithText:(NSString *)text animated:(BOOL)animated completionHandler:(void(^)())completionHandler
{
    [self saveWrapperViewImageIfNeeded];

    if (text.length)
    {
        _textLabel = [self makeLabelWithText:text];
        [_wrapperView addSubview:_textLabel];
    }

    _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    _progressView.backgroundColor = [UIColor clearColor];
    _progressView.progressTintColor = _tintColor;
    [_progressView setProgress:_progressValue animated:NO];
    [_wrapperView addSubview:_progressView];

    _progressLabel = [self makeLabelWithText:_progressText];
    [_wrapperView addSubview:_progressLabel];

    _type = (text.length ? LGPlaceholderViewTypeProgressViewAndText : LGPlaceholderViewTypeProgressView);

    [self showAnimated:animated completionHandler:completionHandler];
}

- (void)showProgressViewAnimated:(BOOL)animated completionHandler:(void(^)())completionHandler
{
    [self showProgressViewWithText:nil animated:animated completionHandler:completionHandler];
}

#pragma mark -

- (void)showView:(UIView *)view animated:(BOOL)animated completionHandler:(void(^)())completionHandler
{
    [self saveWrapperViewImageIfNeeded];

    _innerView = view;
    [_wrapperView addSubview:_innerView];

    _type = LGPlaceholderViewTypeInnerView;

    [self showAnimated:animated completionHandler:completionHandler];
}

#pragma mark -

- (void)showAnimated:(BOOL)animated completionHandler:(void(^)())completionHandler
{
    _showing = YES;

    // -----

    if (!self.superview)
    {
        _parentViewUserInteractionEnabled = _parentView.userInteractionEnabled;

        _parentView.userInteractionEnabled = !_parentViewUserInteractionDisabled;

        if ([_parentView isKindOfClass:[UIScrollView class]])
        {
            UIScrollView *parentScrollView = (UIScrollView *)_parentView;

            _parentViewShowsHorizontalScrollIndicator = parentScrollView.showsHorizontalScrollIndicator;
            _parentViewShowsVerticalScrollIndicator = parentScrollView.showsVerticalScrollIndicator;

            parentScrollView.showsHorizontalScrollIndicator = NO;
            parentScrollView.showsVerticalScrollIndicator = NO;

            if ([_parentView isKindOfClass:[UITableView class]])
            {
                UITableView *parentTableView = (UITableView *)_parentView;

                _parentViewSeparatorStyle = parentTableView.separatorStyle;

                parentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            }
        }

        [_parentView addSubview:self];
    }

    [self layoutInvalidate];

    // -----

    [[NSNotificationCenter defaultCenter] postNotificationName:kLGPlaceholderViewWillShowNotification object:self userInfo:nil];

    [self showDismiss:YES
             animated:animated
    completionHandler:^(void)
     {
         if (_savedWrapperView)
         {
             [_savedWrapperView removeFromSuperview];
             self.savedWrapperView = nil;
         }

         if (completionHandler) completionHandler();

         [[NSNotificationCenter defaultCenter] postNotificationName:kLGPlaceholderViewDidShowNotification object:self userInfo:nil];
     }];
}

- (void)dismissAnimated:(BOOL)animated completionHandler:(void(^)())completionHandler
{
    if (!self.isShowing) return;

    _showing = NO;

    _parentView.userInteractionEnabled = _parentViewUserInteractionEnabled;

    if ([_parentView isKindOfClass:[UIScrollView class]])
    {
        UIScrollView *parentScrollView = (UIScrollView *)_parentView;

        parentScrollView.showsHorizontalScrollIndicator = _parentViewShowsHorizontalScrollIndicator;
        parentScrollView.showsVerticalScrollIndicator = _parentViewShowsVerticalScrollIndicator;

        if ([_parentView isKindOfClass:[UITableView class]])
        {
            UITableView *parentTableView = (UITableView *)_parentView;

            parentTableView.separatorStyle = _parentViewSeparatorStyle;
        }
    }

    // -----

    [[NSNotificationCenter defaultCenter] postNotificationName:kLGPlaceholderViewWillDismissNotification object:self userInfo:nil];

    [self showDismiss:NO animated:animated completionHandler:^(void)
     {
         [self removeSubviews];
         [self removeFromSuperview];

         if (completionHandler) completionHandler();

         [[NSNotificationCenter defaultCenter] postNotificationName:kLGPlaceholderViewDidDismissNotification object:self userInfo:nil];
     }];
}

- (void)showDismiss:(BOOL)show animated:(BOOL)animated completionHandler:(void(^)())completionHandler
{
    if (animated)
    {
        [LGPlaceholderView animateStandardWithAnimations:^(void)
         {
             [self showDismissAnimations:show];
         }
                                              completion:^(BOOL finished)
         {
             if (completionHandler) completionHandler();
         }];
    }
    else
    {
        [self showDismissAnimations:show];

        if (completionHandler) completionHandler();
    }
}

- (void)showDismissAnimations:(BOOL)show
{
    CGFloat value = (show ? 1.f : 0.f);

    _wrapperView.alpha = value;
    _backgroundView.alpha = value;

    if (show && _savedWrapperView)
        _savedWrapperView.alpha = 0.f;
}

#pragma mark - Observers

- (void)addObservers
{
    if (!self.isObserversAdded && _parentView)
    {
        _observersAdded = YES;

        [_parentView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];

        if ([_parentView isKindOfClass:[UIScrollView class]])
        {
            [_parentView addObserver:self forKeyPath:@"contentInset" options:NSKeyValueObservingOptionNew context:nil];
            [_parentView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
        }
    }
}

- (void)removeObservers
{
    if (self.isObserversAdded && _parentView)
    {
        _observersAdded = NO;

        [_parentView removeObserver:self forKeyPath:@"frame"];

        if ([_parentView isKindOfClass:[UIScrollView class]])
        {
            [_parentView removeObserver:self forKeyPath:@"contentInset"];
            [_parentView removeObserver:self forKeyPath:@"contentOffset"];
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"frame"])
        [self layoutInvalidate];
    else if ([keyPath isEqualToString:@"contentInset"])
        [self layoutInvalidate];
    else if ([keyPath isEqualToString:@"contentOffset"])
        [self updatePosition];
    else
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

#pragma mark - Support

+ (void)animateStandardWithAnimations:(void(^)())animations completion:(void(^)(BOOL finished))completion
{
    if ([UIDevice currentDevice].systemVersion.floatValue >= 7.0)
    {
        [UIView animateWithDuration:0.5
                              delay:0.0
             usingSpringWithDamping:1.f
              initialSpringVelocity:0.5
                            options:0
                         animations:animations
                         completion:completion];
    }
    else
    {
        [UIView animateWithDuration:0.5*0.66
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:animations
                         completion:completion];
    }
}

+ (UIImage *)screenshotMakeOfView:(UIView *)view inPixels:(BOOL)inPixels
{
    UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, (inPixels ? 1.f : 0.f));

    CGContextRef context = UIGraphicsGetCurrentContext();

    [view.layer renderInContext:context];

    UIImage *capturedImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return capturedImage;
}

@end
