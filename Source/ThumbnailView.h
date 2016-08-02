@interface ThumbnailView : UIImageView <UIGestureRecognizerDelegate>

STATIC_DECL(CGSize, imageSize, ImageSize);
STATIC_DECL_READONLY (CGFloat, iconSpacing);

@property (nonatomic, assign) PHImageRequestID imageRequestId;
@property (nonatomic, assign) NSUInteger callbackCount;
@property (nonatomic, assign) BOOL showing;
@property (nonatomic, strong, readonly) PHAsset* asset;

- (id) initWithFrame:(CGRect)frame andAsset:(PHAsset*)asset;
- (BOOL) show;
- (void) hide;

@end

