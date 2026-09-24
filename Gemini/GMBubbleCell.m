#import "GMBubbleCell.h"
#import "GMBubbleBuilder.h"
#import <QuartzCore/QuartzCore.h>

static const CGFloat kMaxTextW   = 210.0;
static const CGFloat kCellTop    = 3.0;
static const CGFloat kCellBottom = 3.0;

@implementation GMBubbleCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        
        self.bubbleImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.bubbleImageView];
        
        self.messageTextView = [[UITextView alloc] initWithFrame:CGRectZero];
        self.messageTextView.backgroundColor = [UIColor clearColor];
        self.messageTextView.editable = NO;
        self.messageTextView.scrollEnabled = NO;
        self.messageTextView.dataDetectorTypes = UIDataDetectorTypeAll;
        self.messageTextView.font = [UIFont systemFontOfSize:15.0];
        self.messageTextView.contentInset = UIEdgeInsetsZero;
        
        if ([self.messageTextView respondsToSelector:@selector(setTextContainerInset:)]) {
            self.messageTextView.textContainerInset = UIEdgeInsetsZero;
        }
        
        [self.contentView addSubview:self.messageTextView];
    }
    return self;
}

+ (CGSize)gm_textSize:(NSString *)text maxWidth:(CGFloat)maxWidth {
    if (text.length == 0) return CGSizeZero;
    UIFont *font = [UIFont systemFontOfSize:15.0];
    
    if ([text respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        CGRect r = [text boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX)
                                      options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                   attributes:@{NSFontAttributeName: font}
                                      context:nil];
        return CGSizeMake(ceilf(r.size.width), ceilf(r.size.height));
    } else {
        CGSize s = [text sizeWithFont:font
                    constrainedToSize:CGSizeMake(maxWidth, CGFLOAT_MAX)
                        lineBreakMode:NSLineBreakByWordWrapping];
        return CGSizeMake(ceilf(s.width), ceilf(s.height));
    }
}

+ (CGFloat)heightForMessage:(GMMessage *)message {
    CGSize ts = [self gm_textSize:message.content maxWidth:kMaxTextW];
    CGFloat bh = MAX(ts.height + 18.0, 36.0);
    return bh + kCellTop + kCellBottom;
}

- (void)configureWithMessage:(GMMessage *)message {
    CGSize ts = [[self class] gm_textSize:message.content maxWidth:kMaxTextW];
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    self.messageTextView.text = message.content;
    
    CGFloat textFrameW = ts.width + 18.0;
    CGFloat textFrameH = ts.height + 6.0;
    
    if (message.type == 1) { // Пользователь (синий, хвост справа 10 pt)
        CGFloat bubbleW = MAX(ts.width + 34.0, 64.0);
        CGFloat bubbleH = MAX(ts.height + 18.0, 36.0);
        CGFloat bubbleX = screenW - bubbleW - 8.0;
        CGFloat bubbleY = kCellTop;
        
        self.bubbleImageView.frame = CGRectMake(bubbleX, bubbleY, bubbleW, bubbleH);
        self.bubbleImageView.image = [GMBubbleBuilder blueUserBubbleImage];
        
        CGFloat textX = bubbleX + 6.0;
        // Текст поднят на 2 pt вверх для идеального центрирования
        CGFloat textY = bubbleY + roundf((bubbleH - textFrameH) / 2.0) - 6.0;
        
        self.messageTextView.frame = CGRectMake(roundf(textX), roundf(textY), textFrameW, textFrameH);
        self.messageTextView.textColor = [UIColor whiteColor];
        
    } else { // Ассистент (серый, хвост слева 10 pt)
        CGFloat bubbleW = MAX(ts.width + 34.0, 64.0);
        CGFloat bubbleH = MAX(ts.height + 18.0, 36.0);
        CGFloat bubbleX = 8.0;
        CGFloat bubbleY = kCellTop;
        
        self.bubbleImageView.frame = CGRectMake(bubbleX, bubbleY, bubbleW, bubbleH);
        self.bubbleImageView.image = [GMBubbleBuilder grayAssistantBubbleImage];
        
        CGFloat textX = bubbleX + 12.0;
        // Текст поднят на 2 pt вверх для идеального центрирования
        CGFloat textY = bubbleY + roundf((bubbleH - textFrameH) / 2.0) - 6.0;
        
        self.messageTextView.frame = CGRectMake(roundf(textX), roundf(textY), textFrameW, textFrameH);
        self.messageTextView.textColor = [UIColor blackColor];
    }
}

@end
