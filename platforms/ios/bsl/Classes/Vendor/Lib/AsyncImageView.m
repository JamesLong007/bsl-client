//

#import "AsyncImageView.h"
#import "HTTPRequest.h"
#import "Logging.h"
#import "UIImage+Resize.h"
#import "Cache.h"

@interface AsyncImageView()

@end


@implementation AsyncImageView

@synthesize request = _request;
@synthesize loadedImageData = _loadedImageData;
@synthesize delegate;

#pragma mark -
#pragma mark initializers

- (void)setup
{
    indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.hidesWhenStopped = YES;
    [self addSubview:indicator];
    
    //初始化
    _userInfo = [[NSMutableDictionary alloc] init];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if((self = [super initWithCoder:aDecoder]))
    {
        // Initialization code
        [self setup];
    }
    return self;
}

- (id)initWithImage:(UIImage *)anImage highlightedImage:(UIImage *)aHighlightedImage
{
    if((self = [super initWithImage:anImage 
                   highlightedImage:aHighlightedImage]))
    {
        // Initialization code
        [self setup];
    }
    return self;
}

- (id)initWithImage:(UIImage *)anImage
{
    if((self = [super initWithImage:anImage]))
    {
        // Initialization code
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)aFrame
{
    if((self = [super initWithFrame:aFrame]))
    {
        // Initialization code
        [self setup];
    }
    return self;
}

- (void)dealloc {
    [self cleanupRequest];
    
    
    
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    
}

#pragma mark - View Lifecycle

- (void)layoutSubviews {
    [super layoutSubviews];
    
    indicator.frame = CGRectMake(CGRectGetWidth(self.frame)/2 - CGRectGetWidth(indicator.frame)/2, 
                                 CGRectGetHeight(self.frame)/2 - CGRectGetHeight(indicator.frame)/2, 
                                 CGRectGetWidth(indicator.frame), 
                                 CGRectGetHeight(indicator.frame));
}

- (void)cleanupRequest {
    if (_request != nil) {
        [_request clearDelegatesAndCancel];
        _request = nil;
    }
}

#pragma - 图片处理


#pragma mark -
#pragma mark functions for loading images

//
//如果从本地读取图片，不显示淡入动画
//
- (void)loadImageFromData:(NSData*)data animated:(BOOL)animated{
    
    self.loadedImageData = data;
    
    if (data != nil) {
        
   
    
        if (CGSizeEqualToSize(self.frame.size, CGSizeZero)) {
            NSLog(@"size: %@", NSStringFromCGSize(self.frame.size));
        }
    
    if (!CGSizeEqualToSize(self.frame.size, CGSizeZero) && self.loadedImageData && self.image == nil) {
        
        @autoreleasepool {
        
            UIImage *rawImage = [[UIImage alloc] initWithData:data];
            
            NSString *osVersion = [[UIDevice currentDevice] systemVersion];
            
            UIImage *image;
            
            if ([osVersion isEqualToString:@"5.0"]) {
                image = rawImage;
            }else{
                image = [rawImage resizedImageWithContentMode:UIViewContentModeScaleAspectFill
                                                       bounds:self.frame.size
                                         interpolationQuality:kCGInterpolationHigh];
            }
            
            
            if (animated) {
                self.alpha = 0.0;
                
                self.image = image;
                _loaded = YES;
                
                [UIView animateWithDuration:0.5 animations:^{
                    self.alpha = 1.0; 
                }];
            } else {
                self.image = image;
            }
            
        
        }
        
        if (delegate) {
            [delegate asyncImageView:self didLoadImageFormURL:[_request originalURL]];
        }

    }
    }
}

- (void)loadImageWithURLString:(NSString*)urlString
{
    if (![urlString isKindOfClass:[NSString class]]) {
//        DebugLog(@"空URL");
        [self broken];
        return;
    }
    NSURL *url = [NSURL URLWithString:urlString];
    if (nil == url) {
//        DebugLog(@"空URL");
        [self broken];
        return;
    }
    
    self.image = nil;
    
    //本地文件
    if ([@"file" isEqualToString:url.scheme]) {
        NSError *error = nil;
        NSData *data = [NSData dataWithContentsOfURL:url options:NSDataReadingMappedAlways error:&error];
        if (!data || error) {
            [self broken];
        } else {
            [self loadImageFromData:data animated:NO];
        }
        return;
    }
    
    NSData *cacheData = [[Cache instance] dataForKey:urlString];
    if (cacheData) {
//        DebugLog(@"读取缓存:%@", urlString);
        [self loadImageFromData:cacheData animated:NO];
        return;
    }
    
    [self cleanupRequest];
    
    HTTPRequest *request = [[HTTPRequest alloc] initWithURL:url];
    __block HTTPRequest*  __request=request;

    [request setTimeOutSeconds:20];

    [request setStartedBlock:^{
    
        self.image = nil;
        [self startLoading];

    }];
    [request setCompletionBlock:^{
        if ([__request responseStatusCode] / 100 != 2) {
            NSLog(@"图片下载失败，响应码：%d",[__request responseStatusCode]);
            [self stopLoading];
            [self broken];
            
            [self cleanupRequest];
            return;
        }
        
        [[Cache instance] setData:[__request responseData] forKey:[[__request originalURL] absoluteString]];
        
        [self stopLoading];
        [self loadImageFromData:[__request responseData] animated:YES];
        
        [self cleanupRequest];

    }];
    [request setFailedBlock:^{
        [self stopLoading];
        [self broken];
        
        [self cleanupRequest];

    }];
    
    [request startAsynchronous];
    
    self.request = request;
}


#pragma mark - Indicator works

- (void)startLoading
{
    [indicator startAnimating];
}

- (void)stopLoading
{
    [indicator stopAnimating];
}

- (void)broken
{
    [self stopLoading];
    self.image = [UIImage imageNamed:@"default notload.png"];
}

@end
