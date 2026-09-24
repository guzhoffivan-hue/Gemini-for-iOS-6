#import "GMMessage.h"

@implementation GMMessage

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.author forKey:@"author"];
    [coder encodeObject:self.role forKey:@"role"];
    [coder encodeObject:self.content forKey:@"content"];
    [coder encodeInteger:self.type forKey:@"type"];
    [coder encodeFloat:self.contentHeight forKey:@"contentHeight"];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.author = [coder decodeObjectForKey:@"author"];
        self.role = [coder decodeObjectForKey:@"role"];
        self.content = [coder decodeObjectForKey:@"content"];
        self.type = [coder decodeIntegerForKey:@"type"];
        self.contentHeight = [coder decodeFloatForKey:@"contentHeight"];
    }
    return self;
}

@end

