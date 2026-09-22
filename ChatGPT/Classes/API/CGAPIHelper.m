//
//  CGAPIHelper.m
//  Gemini
//
//  Created by XML on 1/13/25.
//  Copyright (c) 2025 XML. All rights reserved.
//

#import "CGAPIHelper.h"

@implementation CGAPIHelper

+ (void)checkForAppUpdate {
    if (updateChecks == YES) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSURL *randomEndpoint = [NSURL URLWithString:[NSString stringWithFormat:@"%@/update?v=%@", UDCheckServer, appVersion]];
            NSURLResponse *response;
            NSError *error;
            
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            [request setURL:randomEndpoint];
            [request setHTTPMethod:@"GET"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            
            NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            
            if (data) {
                NSDictionary *resp = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                NSNumber *update = resp[@"outdated"];
                NSString *message = resp[@"message"];
                
                if ([update intValue] == 1) {
                    [CGAPIHelper alert:@"Good news!" withMessage:message];
                }
            }
        });
    }
}

+ (void)checkForAPIKeyValidity {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *randomEndpoint = [NSURL URLWithString:[NSString stringWithFormat:@"%@/v1/models", domain]];
        NSURLResponse *response;
        NSError *error;
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:randomEndpoint];
        [request setHTTPMethod:@"GET"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        // Авторизация по API-ключу
        [request setValue:apiKey forHTTPHeaderField:@"x-goog-api-key"];
        [request setValue:[NSString stringWithFormat:@"Bearer %@", apiKey] forHTTPHeaderField:@"Authorization"];
        
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        if (data) {
            id parsedResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            if ([parsedResponse isKindOfClass:[NSDictionary class]]) {
                NSDictionary *errorDict = [parsedResponse objectForKey:@"error"];
                if (errorDict) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [CGAPIHelper alert:@"Warning" withMessage:[NSString stringWithFormat:@"%@", [errorDict objectForKey:@"message"]]];
                    });
                    return;
                }
            }
        } else if (!data) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error) {
                    [CGAPIHelper alert:@"Connection Error" withMessage:@"Please check your internet connection."];
                } else {
                    [CGAPIHelper alert:@"Error" withMessage:@"An unknown error has occurred."];
                }
            });
        }
    });
}

+ (void)logInUserwithKey:(NSString *)key {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *randomEndpoint = [NSURL URLWithString:[NSString stringWithFormat:@"%@/v1/me", domain]];
        NSURLResponse *response;
        NSError *error;
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:randomEndpoint];
        [request setHTTPMethod:@"GET"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:key forHTTPHeaderField:@"x-goog-api-key"];
        [request setValue:[NSString stringWithFormat:@"Bearer %@", key] forHTTPHeaderField:@"Authorization"];
        
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        if (data) {
            id parsedResponseObj = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            if ([parsedResponseObj isKindOfClass:[NSDictionary class]]) {
                NSDictionary *parsedResponse = (NSDictionary *)parsedResponseObj;
                NSDictionary *errorDict = [parsedResponse objectForKey:@"error"];
                if (errorDict) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [CGAPIHelper alert:@"Warning" withMessage:[NSString stringWithFormat:@"%@", [errorDict objectForKey:@"message"]]];
                        [NSNotificationCenter.defaultCenter postNotificationName:@"LOG-IN FAILURE" object:nil];
                    });
                    return;
                }
                
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasLoggedInUser"];
                [[NSUserDefaults standardUserDefaults] setObject:parsedResponse[@"email"] forKey:@"email"];
                [[NSUserDefaults standardUserDefaults] setObject:parsedResponse[@"name"] forKey:@"username"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                id pictureValue = parsedResponse[@"picture"];
                if (pictureValue && pictureValue != [NSNull null]) {
                    NSURL *imageURL = [NSURL URLWithString:pictureValue];
                    if (imageURL) {
                        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
                        if (imageData) {
                            NSString *tmpDirectory = NSTemporaryDirectory();
                            NSString *filePath = [tmpDirectory stringByAppendingPathComponent:@"avatar.png"];
                            [imageData writeToFile:filePath options:NSDataWritingAtomic error:&error];
                        }
                    }
                }
            }
            
            [[NSUserDefaults standardUserDefaults] setObject:key forKey:@"apiKey"];
            [NSNotificationCenter.defaultCenter postNotificationName:@"LOG-IN VALID" object:nil];
        } else {
            [NSNotificationCenter.defaultCenter postNotificationName:@"LOG-IN FAILURE" object:nil];
        }
    });
}

+ (void)saveConversationWithArray:(NSMutableArray *)conversationArray withID:(NSString *)uuid withTitle:(NSString *)title {
    NSMutableArray *messagesArray = [NSMutableArray array];
    for (CGMessage *message in conversationArray) {
        NSMutableDictionary *messageDict = [@{
                                              @"name": message.author ?: @"You",
                                              @"role": message.role ?: @"user",
                                              @"type": @(message.type),
                                              @"message": message.content ?: @""
                                              } mutableCopy];
        
        if (message.imageHash) {
            messageDict[@"image"] = @{@"url": [NSString stringWithFormat:@"data:image/jpeg;base64,%@", message.imageHash]};
        }
        
        [messagesArray addObject:messageDict];
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    
    NSString *convTitle = title;
    if ([title isEqualToString:@"Chat"]) {
        convTitle = [NSString stringWithFormat:@"Chat, at %@", dateString];
    }
    
    NSDictionary *conversationDict = @{
                                       @"conversationID": uuid ?: @"",
                                       @"title": convTitle ?: @"Chat",
                                       @"createdAt": dateString,
                                       @"messages": messagesArray
                                       };
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:conversationDict options:NSJSONWritingPrettyPrinted error:nil];
    NSURL *fileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.json", uuid]]];
    [jsonData writeToURL:fileURL options:NSDataWritingAtomic error:nil];
}

+ (NSMutableArray *)loadConversations {
    NSMutableArray *conversations = [NSMutableArray array];
    NSString *directoryPath = NSTemporaryDirectory();
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryPath error:nil];
    
    for (NSString *fileName in files) {
        if (![fileName hasSuffix:@".json"]) continue;
        NSString *filePath = [directoryPath stringByAppendingPathComponent:fileName];
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        NSDictionary *conversationDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        CGConversation *conversation = CGConversation.new;
        conversation.uuid = conversationDict[@"conversationID"];
        conversation.title = conversationDict[@"title"];
        conversation.creationDate = conversationDict[@"createdAt"];
        conversation.messages = [NSMutableArray array];
        
        NSArray *messagesArray = conversationDict[@"messages"];
        conversation.messageCount = (int)messagesArray.count;
        
        for (NSDictionary *messageDict in messagesArray) {
            CGMessage *message = CGMessage.new;
            message.role = messageDict[@"role"];
            message.type = [messageDict[@"type"] intValue];
            message.content = messageDict[@"message"];
            
            float contentWidth = UIScreen.mainScreen.bounds.size.width - 63;
            CGSize textSize = [message.content sizeWithFont:[UIFont systemFontOfSize:15]
                                          constrainedToSize:CGSizeMake(contentWidth, MAXFLOAT)
                                              lineBreakMode:NSLineBreakByWordWrapping];
            message.contentHeight = textSize.height + 50;
            message.author = messageDict[@"name"];
            
            if (message.type == 1) {
                NSString *avatarPath = [directoryPath stringByAppendingPathComponent:@"avatar.png"];
                UIImage *image = [UIImage imageWithContentsOfFile:avatarPath];
                message.avatar = image ?: [UIImage imageNamed:@"defaultUserAvatar"];
            } else if (message.type == 2) {
                message.avatar = [UIImage imageNamed:@"defaultAssistantAvatar"];
            }
            
            if (messageDict[@"image"] && [messageDict[@"image"] isKindOfClass:[NSDictionary class]]) {
                NSString *imageURL = messageDict[@"image"][@"url"];
                if ([imageURL hasPrefix:@"data:image/jpeg;base64,"]) {
                    NSString *base64String = [imageURL stringByReplacingOccurrencesOfString:@"data:image/jpeg;base64," withString:@""];
                    NSData *imageData = [NSData dataWithBase64EncodedString:base64String];
                    message.imageAttachment = [UIImage imageWithData:imageData];
                }
            }
            [conversation.messages addObject:message];
        }
        [conversations addObject:conversation];
    }
    return conversations;
}

+ (BOOL)deleteConversationWithUUID:(NSString *)uuid {
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.json", uuid]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:filePath]) {
        return [fileManager removeItemAtPath:filePath error:nil];
    }
    return NO;
}

+ (BOOL)deleteAllConversations {
    NSString *tempDirectory = NSTemporaryDirectory();
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    
    NSArray *files = [fileManager contentsOfDirectoryAtPath:tempDirectory error:&error];
    BOOL allDeleted = YES;
    
    for (NSString *file in files) {
        if ([file.pathExtension isEqualToString:@"json"]) {
            NSString *filePath = [tempDirectory stringByAppendingPathComponent:file];
            if (![fileManager removeItemAtPath:filePath error:&error]) {
                allDeleted = NO;
            }
        }
    }
    return allDeleted;
}

#pragma mark - Универсальный парсер ответов Gemini

+ (CGMessage *)convertTextCompletionResponse:(id)jsonResponse {
    NSLog(@"!!! GEMINI DEBUG RAW RESPONSE !!!: %@", jsonResponse);
    
    CGMessage *msg = CGMessage.new;
    msg.author = @"Gemini";
    msg.role = @"assistant";
    msg.type = 2;
    msg.indestructible = YES;
    
    if (VERSION_MIN(@"7.0")) {
        msg.avatar = [UIImage imageNamed:@"iOS7AssistantAvatar"];
    } else {
        msg.avatar = [UIImage imageNamed:@"defaultAssistantAvatar"];
    }
    
    NSDictionary *targetDict = nil;
    if ([jsonResponse isKindOfClass:[NSArray class]]) {
        NSArray *arr = (NSArray *)jsonResponse;
        if (arr.count > 0 && [arr[0] isKindOfClass:[NSDictionary class]]) {
            targetDict = arr[0];
        }
    } else if ([jsonResponse isKindOfClass:[NSDictionary class]]) {
        targetDict = (NSDictionary *)jsonResponse;
    }
    
    // 1. Проверяем, не вернул ли сервер объект ошибки
    if (targetDict && targetDict[@"error"]) {
        id err = targetDict[@"error"];
        NSString *errMsg = [err isKindOfClass:[NSDictionary class]] ? err[@"message"] : [err description];
        msg.content = [NSString stringWithFormat:@"[API Error: %@]", errMsg ?: @"Unknown"];
        
        float contentWidth = UIScreen.mainScreen.bounds.size.width - 63;
        CGSize textSize = [msg.content sizeWithFont:[UIFont systemFontOfSize:15]
                                  constrainedToSize:CGSizeMake(contentWidth, MAXFLOAT)
                                      lineBreakMode:NSLineBreakByWordWrapping];
        msg.contentHeight = textSize.height + 50;
        return msg;
    }
    
    NSString *textContent = @"";
    
    // 2. Формат OpenAI: choices -> message -> content
    if (targetDict && targetDict[@"choices"]) {
        NSArray *choices = targetDict[@"choices"];
        if ([choices isKindOfClass:[NSArray class]] && choices.count > 0) {
            NSDictionary *firstChoice = choices[0];
            NSDictionary *messageDict = firstChoice[@"message"];
            if ([messageDict isKindOfClass:[NSDictionary class]]) {
                textContent = messageDict[@"content"] ?: @"";
                if (messageDict[@"role"]) {
                    msg.role = messageDict[@"role"];
                }
            }
        }
    }
    
    // 3. Нативный формат Gemini: candidates -> content -> parts -> text
    if (textContent.length == 0 && targetDict && targetDict[@"candidates"]) {
        NSArray *candidates = targetDict[@"candidates"];
        if ([candidates isKindOfClass:[NSArray class]] && candidates.count > 0) {
            NSDictionary *cand = candidates[0];
            NSDictionary *content = cand[@"content"];
            if ([content isKindOfClass:[NSDictionary class]]) {
                NSArray *parts = content[@"parts"];
                if ([parts isKindOfClass:[NSArray class]] && parts.count > 0) {
                    NSDictionary *firstPart = parts[0];
                    textContent = firstPart[@"text"] ?: @"";
                }
            }
        }
    }
    
    if (textContent.length == 0) {
        textContent = @"[Error: Could not parse Gemini response structure]";
    }
    
    msg.content = textContent;
    
    float contentWidth = UIScreen.mainScreen.bounds.size.width - 63;
    CGSize textSize = [msg.content sizeWithFont:[UIFont systemFontOfSize:15]
                              constrainedToSize:CGSizeMake(contentWidth, MAXFLOAT)
                                  lineBreakMode:NSLineBreakByWordWrapping];
    msg.contentHeight = textSize.height + 50;
    
    return msg;
}

+ (CGMessage *)convertImageGenerationResponse:(id)jsonMessage {
    CGMessage *msg = CGMessage.new;
    msg.author = @"Gemini";
    msg.role = @"assistant";
    msg.type = 2;
    msg.indestructible = YES;
    
    if (VERSION_MIN(@"7.0")) {
        msg.avatar = [UIImage imageNamed:@"iOS7AssistantAvatar"];
    } else {
        msg.avatar = [UIImage imageNamed:@"defaultAssistantAvatar"];
    }
    
    NSDictionary *targetDict = nil;
    if ([jsonMessage isKindOfClass:[NSArray class]]) {
        NSArray *arr = (NSArray *)jsonMessage;
        if (arr.count > 0 && [arr[0] isKindOfClass:[NSDictionary class]]) {
            targetDict = arr[0];
        }
    } else if ([jsonMessage isKindOfClass:[NSDictionary class]]) {
        targetDict = (NSDictionary *)jsonMessage;
    }
    
    if (targetDict && targetDict[@"data"]) {
        NSArray *dataArray = targetDict[@"data"];
        if ([dataArray isKindOfClass:[NSArray class]] && dataArray.count > 0) {
            NSDictionary *firstData = dataArray[0];
            msg.content = firstData[@"revised_prompt"] ?: @"Generated Image";
            msg.imageHash = firstData[@"b64_json"];
            
            if (firstData[@"b64_json"]) {
                NSData *imageData = [NSData dataWithBase64EncodedString:firstData[@"b64_json"]];
                msg.imageAttachment = [UIImage imageWithData:imageData];
            }
        }
    }
    
    if (!msg.content) {
        msg.content = @"[Image Generation Completed]";
    }
    
    float contentWidth = UIScreen.mainScreen.bounds.size.width - 63;
    CGSize textSize = [msg.content sizeWithFont:[UIFont systemFontOfSize:15]
                              constrainedToSize:CGSizeMake(contentWidth, MAXFLOAT)
                                  lineBreakMode:NSLineBreakByWordWrapping];
    msg.contentHeight = textSize.height + 50;
    
    return msg;
}

+ (CGMessage *)loopErrorBack:(NSString *)errorMessage {
    CGMessage *newError = CGMessage.new;
    newError.author = @"Gemini";
    newError.content = errorMessage;
    newError.type = 2;
    newError.indestructible = YES;
    
    if (VERSION_MIN(@"7.0")) {
        newError.avatar = [UIImage imageNamed:@"iOS7AssistantAvatar"];
    } else {
        newError.avatar = [UIImage imageNamed:@"defaultAssistantAvatar"];
    }
    
    float contentWidth = UIScreen.mainScreen.bounds.size.width - 63;
    CGSize textSize = [newError.content sizeWithFont:[UIFont systemFontOfSize:15]
                                   constrainedToSize:CGSizeMake(contentWidth, MAXFLOAT)
                                       lineBreakMode:NSLineBreakByWordWrapping];
    newError.contentHeight = textSize.height + 50;
    return newError;
}

+ (void)alert:(NSString *)title withMessage:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    });
}

@end