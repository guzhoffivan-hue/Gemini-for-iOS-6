//
//  CGAPICommunicator.m
//  ChatGPT
//
//  Created by XML on 1/13/25.
//  Copyright (c) 2025 XML. All rights reserved.
//

#import "CGAPICommunicator.h"
#import "CGAPIHelper.h"

@implementation CGAPICommunicator

+ (void)createChatCompletionwithContent:(NSMutableArray *)contentArray {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [NSNotificationCenter.defaultCenter postNotificationName:@"THINK STATUS" object:nil];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        
        NSString *activeModel = [[NSUserDefaults standardUserDefaults] stringForKey:@"selectedModel"];
        // Если выбрана старая/пустая/недоступная модель, переключаемся на 3.8
        if (!activeModel || activeModel.length == 0 || [activeModel hasPrefix:@"gemini-2.5"] || [activeModel isEqualToString:@"gemini-flash-latest"]) {
            activeModel = @"gemini-3.8-flash";
        }
        
        NSMutableArray *preparedMessages = [NSMutableArray array];
        for (CGMessage *msg in contentArray) {
            NSString *role = (msg.type == 1) ? @"user" : @"assistant";
            [preparedMessages addObject:@{
                                          @"role": role,
                                          @"content": msg.content ?: @""
                                          }];
        }
        
        NSDictionary *payload = @{
                                  @"model": activeModel,
                                  @"messages": preparedMessages
                                  };
        
        NSError *jsonError = nil;
        NSData *postData = [NSJSONSerialization dataWithJSONObject:payload options:0 error:&jsonError];
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/chat/completions", domain]];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"Bearer %@", apiKey] forHTTPHeaderField:@"Authorization"];
        [request setHTTPBody:postData];
        [request setTimeoutInterval:60.0];
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                   [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                   
                                   if (connectionError) {
                                       [CGAPIHelper alert:@"Network Error" withMessage:connectionError.localizedDescription];
                                       [NSNotificationCenter.defaultCenter postNotificationName:@"CANCEL LOAD" object:nil];
                                       return;
                                   }
                                   
                                   if (data) {
                                       id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                       CGMessage *msg = [CGAPIHelper convertTextCompletionResponse:json];
                                       if (msg) {
                                           [NSNotificationCenter.defaultCenter postNotificationName:@"AI RESPONSE" object:msg];
                                       } else {
                                           [CGAPIHelper alert:@"Error" withMessage:@"Could not parse Gemini response structure"];
                                           [NSNotificationCenter.defaultCenter postNotificationName:@"CANCEL LOAD" object:nil];
                                       }
                                   }
                               }];
    });
}

+ (void)createImageGenerationWithContent:(NSString *)content {
}

- (void)fetchAvailableModelsWithCompletion:(void (^)(NSArray *models, NSError *error))completion {
    NSString *currentKey = [[NSUserDefaults standardUserDefaults] stringForKey:@"apiKey"] ?: apiKey;
    if (!currentKey || currentKey.length == 0) {
        if (completion) {
            completion(nil, [NSError errorWithDomain:@"GeminiApp" code:401 userInfo:@{NSLocalizedDescriptionKey: @"API Key is missing"}]);
        }
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"https://generativelanguage.googleapis.com/v1beta/models?key=%@", currentKey];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
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
                               
                               NSError *jsonErr = nil;
                               NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonErr];
                               if (jsonErr || ![json isKindOfClass:[NSDictionary class]]) {
                                   if (completion) completion(nil, jsonErr);
                                   return;
                               }
                               
                               NSArray *rawModels = [json objectForKey:@"models"];
                               NSMutableArray *supported = [NSMutableArray array];
                               
                               for (NSDictionary *m in rawModels) {
                                   NSArray *methods = [m objectForKey:@"supportedGenerationMethods"];
                                   if ([methods containsObject:@"generateContent"]) {
                                       NSString *rawName = [m objectForKey:@"name"];
                                       NSString *cleanName = [rawName stringByReplacingOccurrencesOfString:@"models/" withString:@""];
                                       if ([cleanName hasPrefix:@"gemini"]) {
                                           [supported addObject:cleanName];
                                       }
                                   }
                               }
                               
                               if (completion) {
                                   completion(supported, nil);
                               }
                           }];
}

@end