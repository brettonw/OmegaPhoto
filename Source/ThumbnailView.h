@interface ThumbnailView : UIImageView <UIGestureRecognizerDelegate>

STATIC_DECL(CGSize, imageSize, ImageSize);
STATIC_DECL_READONLY (CGFloat, iconSpacing);

PROPERTY_OBJECT_DECL(PHAsset, asset);

- (id) initWithFrame:(CGRect)frame andAsset:(PHAsset*)asset;
- (BOOL) show;
- (void) hide;

@end

