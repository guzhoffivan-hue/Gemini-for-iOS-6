#import "GMChatSession.h"

@implementation GMChatSession

+ (instancetype)newSession {
    GMChatSession *session = [[GMChatSession alloc] init];
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    CFStringRef strRef = CFUUIDCreateString(NULL, uuidRef);
    session.uuid = (__bridge_transfer NSString *)strRef;
    CFRelease(uuidRef);
    
    session.title = @"Новый чат";
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"dd.MM.yy HH:mm"];
    session.dateString = [df stringFromDate:[NSDate date]];
    session.messages = [NSMutableArray array];
    return session;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.uuid forKey:@"uuid"];
    [coder encodeObject:self.title forKey:@"title"];
    [coder encodeObject:self.dateString forKey:@"dateString"];
    [coder encodeObject:self.messages forKey:@"messages"];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.uuid = [coder decodeObjectForKey:@"uuid"];
        self.title = [coder decodeObjectForKey:@"title"];
        self.dateString = [coder decodeObjectForKey:@"dateString"];
        self.messages = [coder decodeObjectForKey:@"messages"];
    }
    return self;
}

@end
