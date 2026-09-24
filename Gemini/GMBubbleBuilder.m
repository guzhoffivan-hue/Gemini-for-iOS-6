#import "GMBubbleBuilder.h"

@implementation GMBubbleBuilder

+ (UIImage *)blueUserBubbleImage {
    static UIImage *cached = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGSize size = CGSizeMake(56.0, 36.0);
        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        
        CGFloat w = size.width;
        CGFloat h = size.height;
        CGFloat r = 14.0;
        CGFloat bw = w - 10.0;
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(r + 1.0, 1.0)];
        [path addLineToPoint:CGPointMake(bw - r, 1.0)];
        [path addArcWithCenter:CGPointMake(bw - r, r + 1.0) radius:r startAngle:-M_PI_2 endAngle:0 clockwise:YES];
        
        [path addLineToPoint:CGPointMake(bw, h - 14.0)];
        [path addCurveToPoint:CGPointMake(w - 1.0, h - 1.0)
                controlPoint1:CGPointMake(bw + 2.0, h - 8.0)
                controlPoint2:CGPointMake(w - 3.0, h - 3.0)];
        
        [path addCurveToPoint:CGPointMake(bw - 3.0, h - 1.0)
                controlPoint1:CGPointMake(w - 5.0, h - 1.0)
                controlPoint2:CGPointMake(bw - 1.0, h - 1.0)];
        
        [path addLineToPoint:CGPointMake(r + 1.0, h - 1.0)];
        [path addArcWithCenter:CGPointMake(r + 1.0, h - r - 1.0) radius:r startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
        
        [path addLineToPoint:CGPointMake(1.0, r + 1.0)];
        [path addArcWithCenter:CGPointMake(r + 1.0, r + 1.0) radius:r startAngle:M_PI endAngle:-M_PI_2 clockwise:YES];
        [path closePath];
        
        CGContextSaveGState(ctx);
        [path addClip];
        
        CGColorSpaceRef cs = CGColorSpaceCreateDeviceRGB();
        CGFloat colors[] = {
            105/255.0, 175/255.0, 248/255.0, 1.0,
            24/255.0,  110/255.0, 230/255.0, 1.0
        };
        CGGradientRef bgGrad = CGGradientCreateWithColorComponents(cs, colors, NULL, 2);
        CGContextDrawLinearGradient(ctx, bgGrad, CGPointMake(0, 0), CGPointMake(0, h), 0);
        CGGradientRelease(bgGrad);
        
        UIBezierPath *gloss = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(2.0, 1.5, bw - 4.0, (h / 2.0) - 1.0)
                                                    byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight
                                                          cornerRadii:CGSizeMake(r - 1.0, r - 1.0)];
        CGFloat glossColors[] = {
            1.0, 1.0, 1.0, 0.50,
            1.0, 1.0, 1.0, 0.08
        };
        CGGradientRef glossGrad = CGGradientCreateWithColorComponents(cs, glossColors, NULL, 2);
        CGContextSaveGState(ctx);
        [gloss addClip];
        CGContextDrawLinearGradient(ctx, glossGrad, CGPointMake(0, 1.5), CGPointMake(0, h / 2.0), 0);
        CGContextRestoreGState(ctx);
        CGGradientRelease(glossGrad);
        CGColorSpaceRelease(cs);
        
        CGContextRestoreGState(ctx);
        
        [[UIColor colorWithRed:14/255.0 green:78/255.0 blue:175/255.0 alpha:0.95] setStroke];
        path.lineWidth = 1.0;
        [path stroke];
        
        UIImage *raw = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        // Безопасный вызов для iOS 6 без сбоев
        cached = [raw resizableImageWithCapInsets:UIEdgeInsetsMake(16, 18, 16, 24)];
    });
    return cached;
}

+ (UIImage *)grayAssistantBubbleImage {
    static UIImage *cached = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGSize size = CGSizeMake(56.0, 36.0);
        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        
        CGFloat w = size.width;
        CGFloat h = size.height;
        CGFloat r = 14.0;
        CGFloat bx = 10.0;
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(bx + r, 1.0)];
        [path addLineToPoint:CGPointMake(w - r - 1.0, 1.0)];
        [path addArcWithCenter:CGPointMake(w - r - 1.0, r + 1.0) radius:r startAngle:-M_PI_2 endAngle:0 clockwise:YES];
        
        [path addLineToPoint:CGPointMake(w - 1.0, h - r - 1.0)];
        [path addArcWithCenter:CGPointMake(w - r - 1.0, h - r - 1.0) radius:r startAngle:0 endAngle:M_PI_2 clockwise:YES];
        
        [path addLineToPoint:CGPointMake(bx + 3.0, h - 1.0)];
        [path addCurveToPoint:CGPointMake(1.0, h - 1.0)
                controlPoint1:CGPointMake(bx + 1.0, h - 1.0)
                controlPoint2:CGPointMake(5.0, h - 1.0)];
        
        [path addCurveToPoint:CGPointMake(bx, h - 14.0)
                controlPoint1:CGPointMake(3.0, h - 3.0)
                controlPoint2:CGPointMake(bx - 2.0, h - 8.0)];
        
        [path addLineToPoint:CGPointMake(bx, r + 1.0)];
        [path addArcWithCenter:CGPointMake(bx + r, r + 1.0) radius:r startAngle:M_PI endAngle:-M_PI_2 clockwise:YES];
        [path closePath];
        
        CGContextSaveGState(ctx);
        [path addClip];
        
        CGColorSpaceRef cs = CGColorSpaceCreateDeviceRGB();
        CGFloat colors[] = {
            250/255.0, 250/255.0, 252/255.0, 1.0,
            214/255.0, 216/255.0, 222/255.0, 1.0
        };
        CGGradientRef bgGrad = CGGradientCreateWithColorComponents(cs, colors, NULL, 2);
        CGContextDrawLinearGradient(ctx, bgGrad, CGPointMake(0, 0), CGPointMake(0, h), 0);
        CGGradientRelease(bgGrad);
        
        UIBezierPath *gloss = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(bx + 2.0, 1.5, w - bx - 4.0, (h / 2.0) - 1.0)
                                                    byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight
                                                          cornerRadii:CGSizeMake(r - 1.0, r - 1.0)];
        CGFloat glossColors[] = {
            1.0, 1.0, 1.0, 0.65,
            1.0, 1.0, 1.0, 0.12
        };
        CGGradientRef glossGrad = CGGradientCreateWithColorComponents(cs, glossColors, NULL, 2);
        CGContextSaveGState(ctx);
        [gloss addClip];
        CGContextDrawLinearGradient(ctx, glossGrad, CGPointMake(0, 1.5), CGPointMake(0, h / 2.0), 0);
        CGContextRestoreGState(ctx);
        CGGradientRelease(glossGrad);
        CGColorSpaceRelease(cs);
        
        CGContextRestoreGState(ctx);
        
        [[UIColor colorWithWhite:0.62 alpha:1.0] setStroke];
        path.lineWidth = 1.0;
        [path stroke];
        
        UIImage *raw = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        // Безопасный вызов для iOS 6 без сбоев
        cached = [raw resizableImageWithCapInsets:UIEdgeInsetsMake(16, 24, 16, 18)];
    });
    return cached;
}

@end
