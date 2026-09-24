#import <UIKit/UIKit.h>
#import "GMMessage.h"

@interface GMBubbleCell : UITableViewCell

@property (nonatomic, strong) UIImageView *bubbleImageView;
@property (nonatomic, strong) UITextView *messageTextView;

- (void)configureWithMessage:(GMMessage *)message;
+ (CGFloat)heightForMessage:(GMMessage *)message;

@end
