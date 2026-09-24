#import <Foundation/Foundation.h>

@interface GMChatSession : NSObject <NSCoding>

@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *dateString;
@property (nonatomic, strong) NSMutableArray *messages;

+ (instancetype)newSession;

@end
