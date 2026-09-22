//
//  CGSidebarController.m
//  Gemini
//
//  Created by XML on 1/13/25.
//  Copyright (c) 2025 XML. All rights reserved.
//

#import "CGSidebarController.h"
#import "CGAPIHelper.h"
#import "CGConversation.h"
#import "CGChatViewController.h"

@interface CGSidebarController ()

@property (nonatomic, strong) NSMutableArray *conversations;

@end

@implementation CGSidebarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(recheckConvos) name:@"RE-CHECK CONVOS" object:nil];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.11 alpha:1.0];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.opaque = NO;
    self.tableView.backgroundView = nil;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorColor = [UIColor colorWithWhite:0.0 alpha:0.4];
    
    if ([self respondsToSelector:@selector(userEmailLabel)]) {
        UILabel *emailLbl = [self valueForKey:@"userEmailLabel"];
        if ([emailLbl isKindOfClass:[UILabel class]]) {
            emailLbl.textColor = [UIColor colorWithRed:120/255.0 green:200/255.0 blue:230/255.0 alpha:1.0];
            emailLbl.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.8];
            emailLbl.shadowOffset = CGSizeMake(0, -1);
        }
    }
    
    if ([self respondsToSelector:@selector(versionLabel)]) {
        UILabel *verLbl = [self valueForKey:@"versionLabel"];
        if ([verLbl isKindOfClass:[UILabel class]]) {
            verLbl.textColor = [UIColor colorWithRed:120/255.0 green:200/255.0 blue:230/255.0 alpha:1.0];
            verLbl.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.8];
            verLbl.shadowOffset = CGSizeMake(0, -1);
        }
    }
    
    [self recheckConvos];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self recheckConvos];
}

- (void)recheckConvos {
    self.conversations = [CGAPIHelper loadConversations];
    [self.tableView reloadData];
}

#pragma mark - Table View Data Source & Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1; // Ровно 1 секция, согласованная со Storyboard
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // 1 строка под "New Chat" + количество сохраненных чатов
    return 1 + (self.conversations ? self.conversations.count : 0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 54.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Строка 0: Кнопка New Chat
    if (indexPath.row == 0) {
        static NSString *NewChatID = @"NewChatRowCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NewChatID];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NewChatID];
            cell.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.25];
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.textLabel.font = [UIFont boldSystemFontOfSize:15.0];
            cell.textLabel.shadowColor = [UIColor blackColor];
            cell.textLabel.shadowOffset = CGSizeMake(0, -1);
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
        
        cell.textLabel.text = @"New Chat";
        UIImage *thumb = [UIImage imageNamed:@"newConversationThumbnail"];
        if (!thumb) {
            thumb = [UIImage imageNamed:@"icon"];
        }
        cell.imageView.image = thumb;
        return cell;
    }
    
    // Строки 1+: Сохраненные чаты
    static NSString *CellIdentifier = @"CleanConvoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14.0];
        cell.textLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.85];
        cell.textLabel.shadowOffset = CGSizeMake(0, -1);
        
        cell.detailTextLabel.textColor = [UIColor colorWithRed:120/255.0 green:200/255.0 blue:230/255.0 alpha:1.0];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:11.0];
        cell.detailTextLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.85];
        cell.detailTextLabel.shadowOffset = CGSizeMake(0, -1);
    }
    
    NSInteger convoIndex = indexPath.row - 1;
    if (convoIndex < self.conversations.count) {
        CGConversation *convo = [self.conversations objectAtIndex:convoIndex];
        cell.textLabel.text = convo.title ?: @"Untitled";
        cell.detailTextLabel.text = convo.creationDate ?: @"";
        cell.imageView.image = [UIImage imageNamed:@"ConvHistory"];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UINavigationController *nav = (UINavigationController *)self.slideMenuController.contentViewController;
    CGChatViewController *chatVC = nil;
    if ([nav isKindOfClass:[UINavigationController class]] && [nav.topViewController isKindOfClass:[CGChatViewController class]]) {
        chatVC = (CGChatViewController *)nav.topViewController;
    }
    
    // Нажатие на "New Chat"
    if (indexPath.row == 0) {
        if (chatVC) {
            [chatVC startNewConversation];
        }
        [self.slideMenuController hideMenu:YES];
        return;
    }
    
    // Нажатие на сохраненный диалог
    NSInteger convoIndex = indexPath.row - 1;
    if (convoIndex < self.conversations.count) {
        CGConversation *convo = [self.conversations objectAtIndex:convoIndex];
        if (chatVC) {
            [chatVC loadChat:convo.messages withUUID:convo.uuid];
            chatVC.navigationItem.title = convo.title;
        }
        [self.slideMenuController hideMenu:YES];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Разрешаем удалять только строки с чатами (индекс > 0), строку "New Chat" удалять нельзя
    return (indexPath.row > 0);
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete && indexPath.row > 0) {
        NSInteger convoIndex = indexPath.row - 1;
        if (convoIndex < self.conversations.count) {
            CGConversation *convo = [self.conversations objectAtIndex:convoIndex];
            [CGAPIHelper deleteConversationWithUUID:convo.uuid];
            [self.conversations removeObjectAtIndex:convoIndex];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

@end