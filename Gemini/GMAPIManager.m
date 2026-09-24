#import "GMAPIManager.h"

@implementation GMAPIManager

+ (instancetype)sharedManager {
    static GMAPIManager *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[GMAPIManager alloc] init];
    });
    return shared;
}

- (NSString *)apiKey {
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"apiKey"] ?: @"";
}

- (NSString *)currentModel {
    NSString *model = [[NSUserDefaults standardUserDefaults] stringForKey:@"selectedModel"];
    if (!model || model.length == 0) {
        return @"gemini-3.8-flash";
    }
    return model;
}

- (void)sendMessage:(NSString *)text history:(NSArray *)history completion:(void (^)(NSString *reply, NSError *error))completion {
    NSString *key = [self apiKey];
    NSString *model = [self currentModel];
    
    NSString *urlString = [NSString stringWithFormat:@"https://generativelanguage.googleapis.com/v1beta/models/%@:generateContent?key=%@", model, key];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setTimeoutInterval:60.0];
    
    // Формируем чистую историю без системных ошибок
    NSMutableArray *contentsArray = [NSMutableArray array];
    
    for (id msgObj in history) {
        NSString *role = @"user";
        NSInteger type = [[msgObj valueForKey:@"type"] integerValue];
        NSString *msgContent = [msgObj valueForKey:@"content"];
        
        // Пропускаем служебные плашки с ошибками
        if ([msgContent hasPrefix:@"["] && [msgContent hasSuffix:@"]"]) {
            continue;
        }
        
        if (type == 2) {
            role = @"model";
        }
        
        if (msgContent.length > 0) {
            NSDictionary *part = @{@"text": msgContent};
            [contentsArray addObject:@{
                                       @"role": role,
                                       @"parts": @[part]
                                       }];
        }
    }
    
    // Если история пуста (первый запрос) — добавляем текущий текст
    if (contentsArray.count == 0 && text.length > 0) {
        [contentsArray addObject:@{
                                   @"role": @"user",
                                   @"parts": @[@{@"text": text}]
                                   }];
    }
    
    NSDictionary *body = @{@"contents": contentsArray};
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:body options:0 error:nil];
    [request setHTTPBody:bodyData];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *res, NSData *data, NSError *err) {
                               [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                               if (err || data.length == 0) {
                                   if (completion) completion(nil, err);
                                   return;
                               }
                               
                               NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                               NSArray *candidates = json[@"candidates"];
                               if (candidates.count > 0) {
                                   NSDictionary *cand = candidates[0];
                                   NSArray *parts = cand[@"content"][@"parts"];
                                   if (parts.count > 0) {
                                       NSString *answer = parts[0][@"text"];
                                       if (completion) completion(answer, nil);
                                       return;
                                   }
                               }
                               
                               // Обработка возможной ошибки ответа от Google API
                               NSDictionary *errorDict = json[@"error"];
                               if (errorDict) {
                                   NSString *msg = errorDict[@"message"] ?: @"API Error";
                                   if (completion) completion(nil, [NSError errorWithDomain:@"GMAPI" code:500 userInfo:@{NSLocalizedDescriptionKey: msg}]);
                                   return;
                               }
                               
                               if (completion) {
                                   completion(nil, [NSError errorWithDomain:@"GMAPI" code:500 userInfo:@{NSLocalizedDescriptionKey: @"Invalid response structure"}]);
                               }
                           }];
}

- (void)fetchAvailableModelsWithCompletion:(void (^)(NSArray *models, NSError *error))completion {
    NSString *key = [[NSUserDefaults standardUserDefaults] stringForKey:@"apiKey"];
    if (!key || key.length == 0) {
        if (completion) {
            completion(nil, [NSError errorWithDomain:@"GMError" code:401 userInfo:@{NSLocalizedDescriptionKey: @"API Key missing"}]);
        }
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"https://generativelanguage.googleapis.com/v1beta/models?key=%@", key];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setTimeoutInterval:15.0];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if (connectionError) {
                                   if (completion) completion(nil, connectionError);
                                   return;
                               }
                               
                               if (!data || data.length == 0) {
                                   if (completion) completion(nil, [NSError errorWithDomain:@"GMError" code:500 userInfo:@{NSLocalizedDescriptionKey: @"Empty response"}]);
                                   return;
                               }
                               
                               NSError *jsonErr = nil;
                               id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonErr];
                               if (jsonErr || ![json isKindOfClass:[NSDictionary class]]) {
                                   if (completion) completion(nil, [NSError errorWithDomain:@"GMError" code:500 userInfo:@{NSLocalizedDescriptionKey: @"Invalid JSON structure"}]);
                                   return;
                               }
                               
                               NSArray *rawModels = [json objectForKey:@"models"];
                               if (!rawModels || ![rawModels isKindOfClass:[NSArray class]]) {
                                   if (completion) completion(nil, [NSError errorWithDomain:@"GMError" code:500 userInfo:@{NSLocalizedDescriptionKey: @"No models array"}]);
                                   return;
                               }
                               
                               NSMutableArray *chatModels = [NSMutableArray array];
                               for (id m in rawModels) {
                                   if (![m isKindOfClass:[NSDictionary class]]) continue;
                                   NSArray *methods = [m objectForKey:@"supportedGenerationMethods"];
                                   if ([methods isKindOfClass:[NSArray class]] && [methods containsObject:@"generateContent"]) {
                                       NSString *rawName = [m objectForKey:@"name"];
                                       if ([rawName isKindOfClass:[NSString class]]) {
                                           NSString *cleanName = [rawName stringByReplacingOccurrencesOfString:@"models/" withString:@""];
                                           if ([cleanName hasPrefix:@"gemini"]) {
                                               [chatModels addObject:cleanName];
                                           }
                                       }
                                   }
                               }
                               
                               if (completion) {
                                   completion(chatModels, nil);
                               }
                           }];
}

@end
