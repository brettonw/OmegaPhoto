@interface LightBoxView : UIView

@property (nonatomic, strong) UIImageView* imageView;
@property (nonatomic, strong) PHAsset* asset;



@end

/*
 
 UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
 imageView.contentMode = UIViewContentModeScaleAspectFit;
 imageView.backgroundColor = [UIColor blackColor];
 PHImageRequestOptions* requestOptions = [PHImageRequestOptions new];
 requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
 requestOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
 requestOptions.networkAccessAllowed = YES;
 CGSize retinaSize = CGSizeMake (self.frame.size.width * 2, self.frame.size.height * 2);
 [IMAGE_MANAGER requestImageForAsset:thumbnailView.asset targetSize:retinaSize contentMode:PHImageContentModeAspectFit options:requestOptions resultHandler:^(UIImage* image, NSDictionary* result) {
 imageView.image = image;
 }];
 [VIEW_CONTROLLER pushView:imageView];

*/