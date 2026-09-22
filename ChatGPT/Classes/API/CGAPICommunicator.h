//
//  CGAPICommunicator.h
//  Gemini
//
//  Created by XML on 1/13/25.
//  Copyright (c) 2025 XML. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CGMessage.h"
#import "CGAPIHelper.h"

@interface CGAPICommunicator : NSObject

@property (nonatomic, strong) NSMutableArray *activeConnections;

+ (void)createChatCompletionwithContent:(NSMutableArray *)content;
+ (void)createImageGenerationWithContent:(NSString *)content;

// Загружает актуальный список моделей с сервера Google.
// В случае ошибки возвращает fallback-список, error != nil.
+ (void)fetchAvailableModelsWithCompletion:(void (^)(NSArray *models, NSError *error))completion;

// Резервный список актуальных моделей (если API недоступен)
+ (NSArray *)fallbackModels;

// Дефолтная модель для новых пользователей
+ (NSString *)defaultModelName;

@end