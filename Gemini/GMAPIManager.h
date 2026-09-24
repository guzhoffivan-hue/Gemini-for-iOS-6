#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface GMAPIManager : NSObject

+ (instancetype)sharedManager;

- (void)fetchAvailableModelsWithCompletion:(void (^)(NSArray *models, NSError *error))completion;
- (void)sendMessage:(NSString *)text history:(NSArray *)history completion:(void (^)(NSString *reply, NSError *error))completion;
- (void)fetchAvailableModelsWithCompletion:(void (^)(NSArray *models, NSError *error))completion;

@end
