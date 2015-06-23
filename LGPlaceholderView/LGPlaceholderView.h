//
//  LGPlaceholderView.h
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

#import <UIKit/UIKit.h>

static NSString *const kLGPlaceholderViewWillShowNotification    = @"LGPlaceholderViewWillShowNotification";
static NSString *const kLGPlaceholderViewWillDismissNotification = @"LGPlaceholderViewWillDismissNotification";
static NSString *const kLGPlaceholderViewDidShowNotification     = @"LGPlaceholderViewDidShowNotification";
static NSString *const kLGPlaceholderViewDidDismissNotification  = @"LGPlaceholderViewDidDismissNotification";

@interface LGPlaceholderView : UIView

@property (strong, nonatomic) UIColor            *tintColor;
@property (strong, nonatomic) UIFont             *font;
@property (assign, nonatomic) NSTextAlignment    textAlignment;
@property (assign, nonatomic) UIEdgeInsets       contentInset;
@property (assign, nonatomic, readonly) float    progressValue;
@property (assign, nonatomic, readonly) NSString *progressText;

@property (assign, nonatomic, getter=isShowing) BOOL showing;

/** When LGPlaceholderView is showed, disable parentView.userInteractionEnabled or not (delault is NO) */
@property (assign, nonatomic, getter=isParentViewUserInteractionDisabled) BOOL parentViewUserInteractionDisabled;

- (instancetype)initWithView:(UIView *)view;
+ (instancetype)placeholderViewWithView:(UIView *)view;

- (void)setProgressValue:(float)progressValue animated:(BOOL)animated;
- (void)setProgressText:(NSString *)progressText animated:(BOOL)animated;

- (void)showActivityIndicatorAnimated:(BOOL)animated completionHandler:(void(^)())completionHandler;
- (void)showActivityIndicatorWithText:(NSString *)text animated:(BOOL)animated completionHandler:(void(^)())completionHandler;
- (void)showProgressViewAnimated:(BOOL)animated completionHandler:(void(^)())completionHandler;
- (void)showProgressViewWithText:(NSString *)text animated:(BOOL)animated completionHandler:(void(^)())completionHandler;
- (void)showText:(NSString *)text animated:(BOOL)animated completionHandler:(void(^)())completionHandler;
- (void)showView:(UIView *)view animated:(BOOL)animated completionHandler:(void(^)())completionHandler;

- (void)dismissAnimated:(BOOL)animated completionHandler:(void(^)())completionHandler;

#pragma mark -

/** Unavailable, use +placeholderViewWithView... instead */
+ (instancetype)new __attribute__((unavailable("use +placeholderViewWithView... instead")));
/** Unavailable, use -initWithView... instead */
- (instancetype)init __attribute__((unavailable("use -initWithView... instead")));
/** Unavailable, use -initWithView... instead */
- (instancetype)initWithFrame:(CGRect)frame __attribute__((unavailable("use -initWithView... instead")));

@end
