#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface GMMessage : NSObject <NSCoding>

@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSString *role;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, assign) NSInteger type; // 1 = User, 2 = AI
@property (nonatomic, assign) CGFloat contentHeight;

@end
