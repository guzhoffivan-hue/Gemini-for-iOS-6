#import "ViewController.h"
#import "GMAPIManager.h"
#import "GMMessage.h"
#import "GMBubbleCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    if ([self respondsToSelector:@selector(setAutomaticallyAdjustsScrollViewInsets:)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.92 alpha:1.0];
    
    [self loadSessionsFromDisk];
    
    [self setupNavigationBar];
    [self setupTableView];
    [self setupInputToolbar];
    [self setupDrawerHistoryView];
    
    // Кнопка списка (гамбургер) слева
    UIBarButtonItem *listBtn = [[UIBarButtonItem alloc] initWithTitle:@"≡"
                                                                style:UIBarButtonItemStyleBordered
                                                               target:self
                                                               action:@selector(toggleDrawer)];
    NSDictionary *btnAttrs = @{
                               UITextAttributeFont: [UIFont boldSystemFontOfSize:18.0],
                               UITextAttributeTextColor: [UIColor colorWithWhite:0.2 alpha:1.0],
                               UITextAttributeTextShadowColor: [UIColor clearColor]
                               };
    [listBtn setTitleTextAttributes:btnAttrs forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = listBtn;
    
    // Кнопка создания нового чата справа (блокнот iOS 6)
    UIBarButtonItem *composeBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                                target:self
                                                                                action:@selector(createNewChatAction)];
    self.navigationItem.rightBarButtonItem = composeBtn;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveCurrentSession) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    NSString *key = [[NSUserDefaults standardUserDefaults] stringForKey:@"apiKey"];
    if (!key || key.length == 0) {
        [self promptForAPIKey];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Session Management

- (NSString *)sessionsFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [[paths objectAtIndex:0] stringByAppendingPathComponent:@"chat_sessions.dat"];
}

- (void)loadSessionsFromDisk {
    NSString *path = [self sessionsFilePath];
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (data) {
        self.allSessions = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    if (!self.allSessions) {
        self.allSessions = [NSMutableArray array];
    }
    
    if (self.allSessions.count > 0) {
        self.currentSession = [self.allSessions objectAtIndex:0];
    } else {
        self.currentSession = [GMChatSession newSession];
        [self.allSessions addObject:self.currentSession];
        [self saveSessionsToDisk];
    }
}

- (void)saveSessionsToDisk {
    NSMutableArray *validSessions = [NSMutableArray array];
    for (GMChatSession *s in self.allSessions) {
        if (s.messages.count > 0) {
            [validSessions addObject:s];
        }
    }
    self.allSessions = validSessions;
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.allSessions];
    [data writeToFile:[self sessionsFilePath] atomically:YES];
}

- (void)saveCurrentSession {
    [self saveSessionsToDisk];
}

#pragma mark - UI Setup

- (void)setupNavigationBar {
    UIView *titleContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, 200, 18)];
    titleLabel.text = @"Gemini";
    titleLabel.font = [UIFont boldSystemFontOfSize:14];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor colorWithWhite:0.15 alpha:1.0];
    titleLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.8];
    titleLabel.shadowOffset = CGSizeMake(0, 1);
    [titleContainer addSubview:titleLabel];
    
    self.modelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.modelButton.frame = CGRectMake(0, 20, 200, 20);
    NSString *currModel = [[NSUserDefaults standardUserDefaults] stringForKey:@"selectedModel"] ?: @"gemini-3.8-flash";
    [self.modelButton setTitle:[NSString stringWithFormat:@"%@ ▾", currModel] forState:UIControlStateNormal];
    [self.modelButton.titleLabel setFont:[UIFont systemFontOfSize:11]];
    [self.modelButton setTitleColor:[UIColor colorWithWhite:0.25 alpha:1.0] forState:UIControlStateNormal];
    self.modelButton.titleLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.8];
    self.modelButton.titleLabel.shadowOffset = CGSizeMake(0, 1);
    [self.modelButton addTarget:self action:@selector(modelSelectorTapped) forControlEvents:UIControlEventTouchUpInside];
    [titleContainer addSubview:self.modelButton];
    
    self.navigationItem.titleView = titleContainer;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"bar-BG.png"] forBarMetrics:UIBarMetricsDefault];
    
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setShadowImage:)]) {
        [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    }
}

- (void)setupTableView {
    CGFloat toolbarHeight = 44.0;
    CGFloat w = self.view.bounds.size.width;
    CGFloat h = self.view.bounds.size.height;
    
    self.chatTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, w, h - toolbarHeight) style:UITableViewStylePlain];
    self.chatTableView.delegate = self;
    self.chatTableView.dataSource = self;
    self.chatTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.chatTableView.backgroundColor = [UIColor clearColor];
    
    self.chatTableView.tableHeaderView = nil;
    self.chatTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // Нулевой отступ сверху таблицы
    self.chatTableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 6.0, 0.0);
    
    [self.view addSubview:self.chatTableView];
}

- (void)setupInputToolbar {
    CGFloat toolbarHeight = 44.0;
    self.inputToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - toolbarHeight, self.view.bounds.size.width, toolbarHeight)];
    self.inputToolbar.barStyle = UIBarStyleDefault;
    self.inputToolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [self.inputToolbar setBackgroundImage:[UIImage imageNamed:@"bar-BG.png"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    
    BOOL isRU = [self isRussianLanguage];
    CGFloat fieldWidth = self.view.bounds.size.width - 95;
    
    self.inputTextField = [[UITextField alloc] initWithFrame:CGRectMake(6, 7, fieldWidth, 30)];
    self.inputTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.inputTextField.placeholder = isRU ? @"Сообщение..." : @"Message...";
    self.inputTextField.font = [UIFont systemFontOfSize:14.0];
    self.inputTextField.delegate = self;
    
    // Выравниваем текст и плейсхолдер строго по центру высоты поля
    self.inputTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
    UIBarButtonItem *inputItem = [[UIBarButtonItem alloc] initWithCustomView:self.inputTextField];
    
    NSString *sendTitle = isRU ? @"Отпр." : @"Send";
    self.sendButton = [[UIBarButtonItem alloc] initWithTitle:sendTitle
                                                       style:UIBarButtonItemStyleBordered
                                                      target:self
                                                      action:@selector(sendButtonTapped)];
    
    NSDictionary *sendAttrs = @{
                                UITextAttributeTextColor: [UIColor colorWithWhite:0.2 alpha:1.0],
                                UITextAttributeTextShadowColor: [UIColor clearColor],
                                UITextAttributeTextShadowOffset: [NSValue valueWithUIOffset:UIOffsetZero]
                                };
    [self.sendButton setTitleTextAttributes:sendAttrs forState:UIControlStateNormal];
    [self.sendButton setTitleTextAttributes:sendAttrs forState:UIControlStateHighlighted];
    
    self.inputToolbar.items = @[inputItem, self.sendButton];
    [self.view addSubview:self.inputToolbar];
}

#pragma mark - Drawer Setup

- (void)setupDrawerHistoryView {
    CGFloat w = self.view.bounds.size.width;
    CGFloat h = self.view.bounds.size.height;
    CGFloat bottomBarHeight = 44.0;
    
    self.drawerContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, -(h + 60.0), w, h + 60.0)];
    self.drawerContainerView.backgroundColor = [UIColor colorWithWhite:0.16 alpha:0.98];
    self.drawerContainerView.clipsToBounds = YES;
    
    self.drawerContainerView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.drawerContainerView.layer.shadowOpacity = 0.8;
    self.drawerContainerView.layer.shadowRadius = 8.0;
    self.drawerContainerView.layer.shadowOffset = CGSizeMake(0, 4);
    
    self.historyTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, w, h - bottomBarHeight) style:UITableViewStylePlain];
    self.historyTableView.delegate = self;
    self.historyTableView.dataSource = self;
    self.historyTableView.backgroundColor = [UIColor clearColor];
    self.historyTableView.separatorColor = [UIColor colorWithWhite:0.25 alpha:1.0];
    self.historyTableView.contentInset = UIEdgeInsetsMake(4, 0, 8, 0);
    self.historyTableView.tableHeaderView = nil;
    [self.drawerContainerView addSubview:self.historyTableView];
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(0, h - bottomBarHeight, w, bottomBarHeight);
    closeBtn.backgroundColor = [UIColor colorWithWhite:0.12 alpha:1.0];
    [closeBtn setTitle:@"▲  Свернуть" forState:UIControlStateNormal];
    [closeBtn setTitleColor:[UIColor colorWithWhite:0.6 alpha:1.0] forState:UIControlStateNormal];
    [closeBtn.titleLabel setFont:[UIFont systemFontOfSize:12.0]];
    [closeBtn addTarget:self action:@selector(toggleDrawer) forControlEvents:UIControlEventTouchUpInside];
    [self.drawerContainerView addSubview:closeBtn];
    
    [self.view addSubview:self.drawerContainerView];
}

- (void)toggleDrawer {
    [self.view endEditing:YES];
    
    CGFloat closedY = -self.drawerContainerView.frame.size.height;
    CGFloat targetY = self.isDrawerOpen ? closedY : 0;
    self.isDrawerOpen = !self.isDrawerOpen;
    
    if (self.isDrawerOpen) {
        [self.historyTableView reloadData];
        [self.historyTableView setContentOffset:CGPointMake(0, -self.historyTableView.contentInset.top) animated:NO];
    }
    
    [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGRect f = self.drawerContainerView.frame;
        f.origin.y = targetY;
        self.drawerContainerView.frame = f;
    } completion:nil];
}

- (void)createNewChatAction {
    [self.view endEditing:YES];
    
    if (self.currentSession && self.currentSession.messages.count > 0) {
        [self saveCurrentSession];
    }
    
    if (self.currentSession && self.currentSession.messages.count == 0) {
        self.inputTextField.text = @"";
        [self.inputTextField resignFirstResponder];
        if (self.isDrawerOpen) {
            [self toggleDrawer];
        }
        return;
    }
    
    self.currentSession = [GMChatSession newSession];
    self.inputTextField.text = @"";
    [self.inputTextField resignFirstResponder];
    
    if (self.isDrawerOpen) {
        [self toggleDrawer];
    }
    
    [UIView transitionWithView:self.chatTableView
                      duration:0.65
                       options:UIViewAnimationOptionTransitionCurlUp
                    animations:^{
                        [self.chatTableView reloadData];
                    }
                    completion:nil];
}

#pragma mark - Chat Actions

- (void)sendButtonTapped {
    NSString *text = [self.inputTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (text.length == 0) return;
    
    if (!self.currentSession) {
        self.currentSession = [GMChatSession newSession];
    }
    
    if (![self.allSessions containsObject:self.currentSession]) {
        [self.allSessions insertObject:self.currentSession atIndex:0];
    }
    
    BOOL isRU = [self isRussianLanguage];
    
    if (self.currentSession.messages.count == 0) {
        self.currentSession.title = text.length > 20 ? [[text substringToIndex:20] stringByAppendingString:@"..."] : text;
    }
    
    GMMessage *userMsg = [[GMMessage alloc] init];
    userMsg.author = isRU ? @"Вы" : @"You";
    userMsg.content = text;
    userMsg.type = 1;
    [self.currentSession.messages addObject:userMsg];
    [self saveCurrentSession];
    
    self.inputTextField.text = @"";
    [self.chatTableView reloadData];
    [self scrollToBottom];
    
    [[GMAPIManager sharedManager] sendMessage:text history:self.currentSession.messages completion:^(NSString *reply, NSError *error) {
        GMMessage *aiMsg = [[GMMessage alloc] init];
        aiMsg.author = @"Gemini";
        aiMsg.type = 2;
        aiMsg.content = error ? [NSString stringWithFormat:@"[Ошибка: %@]", error.localizedDescription] : reply;
        
        [self.currentSession.messages addObject:aiMsg];
        [self saveCurrentSession];
        [self.chatTableView reloadData];
        [self scrollToBottom];
    }];
}

- (void)scrollToBottom {
    if (self.currentSession.messages.count > 0) {
        NSIndexPath *lastPath = [NSIndexPath indexPathForRow:self.currentSession.messages.count - 1 inSection:0];
        [self.chatTableView scrollToRowAtIndexPath:lastPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (void)appDidBecomeActive {
    [self.view endEditing:YES];
    CGFloat toolbarHeight = 44.0;
    CGRect tbFrame = self.inputToolbar.frame;
    tbFrame.origin.y = self.view.bounds.size.height - toolbarHeight;
    self.inputToolbar.frame = tbFrame;
    
    CGRect tblFrame = self.chatTableView.frame;
    tblFrame.size.height = tbFrame.origin.y;
    self.chatTableView.frame = tblFrame;
}

#pragma mark - Table View (Chat & History)

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.historyTableView) {
        return self.allSessions.count;
    }
    return self.currentSession.messages.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.historyTableView) {
        return 54.0;
    }
    return [GMBubbleCell heightForMessage:self.currentSession.messages[indexPath.row]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.historyTableView) {
        static NSString *histID = @"HistoryCellID";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:histID];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:histID];
            cell.backgroundColor = [UIColor clearColor];
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.textLabel.font = [UIFont boldSystemFontOfSize:15.0];
            cell.detailTextLabel.textColor = [UIColor colorWithRed:120/255.0 green:190/255.0 blue:255/255.0 alpha:1.0];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:11.0];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
        GMChatSession *s = self.allSessions[indexPath.row];
        cell.textLabel.text = s.title;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ • сообщений: %lu", s.dateString, (unsigned long)s.messages.count];
        return cell;
    }
    
    static NSString *cellID = @"GMBubbleCell";
    GMBubbleCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[GMBubbleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    [cell configureWithMessage:self.currentSession.messages[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.historyTableView) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self saveCurrentSession];
        self.currentSession = self.allSessions[indexPath.row];
        [self.chatTableView reloadData];
        [self toggleDrawer];
        [self scrollToBottom];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return (tableView == self.historyTableView);
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.historyTableView && editingStyle == UITableViewCellEditingStyleDelete) {
        GMChatSession *toDelete = self.allSessions[indexPath.row];
        [self.allSessions removeObjectAtIndex:indexPath.row];
        
        if (toDelete == self.currentSession) {
            if (self.allSessions.count > 0) {
                self.currentSession = self.allSessions[0];
            } else {
                self.currentSession = [GMChatSession newSession];
                [self.allSessions addObject:self.currentSession];
            }
            [self.chatTableView reloadData];
        }
        
        [self saveSessionsToDisk];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - Keyboard Notifications

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGRect kbFrame = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    CGRect tbFrame = self.inputToolbar.frame;
    tbFrame.origin.y = self.view.bounds.size.height - kbFrame.size.height - tbFrame.size.height;
    
    CGRect tblFrame = self.chatTableView.frame;
    tblFrame.size.height = tbFrame.origin.y;
    
    [UIView animateWithDuration:duration animations:^{
        self.inputToolbar.frame = tbFrame;
        self.chatTableView.frame = tblFrame;
    } completion:^(BOOL finished) {
        [self scrollToBottom];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSTimeInterval duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    CGRect tbFrame = self.inputToolbar.frame;
    tbFrame.origin.y = self.view.bounds.size.height - tbFrame.size.height;
    
    CGRect tblFrame = self.chatTableView.frame;
    tblFrame.size.height = tbFrame.origin.y;
    
    [UIView animateWithDuration:duration animations:^{
        self.inputToolbar.frame = tbFrame;
        self.chatTableView.frame = tblFrame;
    }];
}

#pragma mark - Helpers

- (BOOL)isRussianLanguage {
    NSString *lang = [[NSLocale preferredLanguages] objectAtIndex:0];
    return [lang hasPrefix:@"ru"];
}

- (NSString *)systemCancelString {
    return [[NSBundle bundleWithIdentifier:@"com.apple.UIKit"] localizedStringForKey:@"Cancel" value:@"Cancel" table:nil];
}

- (void)promptForAPIKey {
    BOOL isRU = [self isRussianLanguage];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Google Gemini API"
                                                    message:isRU ? @"Введите API-ключ:" : @"Enter API Key:"
                                                   delegate:self
                                          cancelButtonTitle:[self systemCancelString]
                                          otherButtonTitles:isRU ? @"Сохранить" : @"Save", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.tag = 100;
    [alert show];
}

- (void)modelSelectorTapped {
    [self.view endEditing:YES];
    NSArray *cached = [[NSUserDefaults standardUserDefaults] arrayForKey:@"cachedModelList"];
    self.availableModels = (cached && cached.count > 0) ? cached : @[@"gemini-3.8-flash", @"gemini-3.5-flash", @"gemini-2.5-flash"];
    
    BOOL isRU = [self isRussianLanguage];
    NSString *sheetTitle = isRU ? @"Настройки диалога" : @"Dialog Settings";
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:sheetTitle
                                                       delegate:self
                                              cancelButtonTitle:nil
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:nil];
    
    for (NSString *m in self.availableModels) {
        [sheet addButtonWithTitle:m];
    }
    
    NSString *refreshTitle = isRU ? @"🔄 Обновить список из сети" : @"🔄 Refresh models from web";
    NSString *manualModelTitle = isRU ? @"✏️ Ввести модель вручную..." : @"✏️ Enter model manually...";
    NSString *changeKeyTitle = isRU ? @"🔑 Сменить API-ключ..." : @"🔑 Change API Key...";
    
    [sheet addButtonWithTitle:refreshTitle];
    [sheet addButtonWithTitle:manualModelTitle];
    [sheet addButtonWithTitle:changeKeyTitle];
    [sheet addButtonWithTitle:[self systemCancelString]];
    
    sheet.cancelButtonIndex = sheet.numberOfButtons - 1;
    [sheet showInView:[[UIApplication sharedApplication] keyWindow] ?: self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) return;
    
    BOOL isRU = [self isRussianLanguage];
    NSInteger cancelIdx = actionSheet.cancelButtonIndex;
    
    if (buttonIndex == cancelIdx - 1) {
        NSString *currentKey = [[NSUserDefaults standardUserDefaults] stringForKey:@"apiKey"] ?: @"";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Google Gemini API"
                                                        message:isRU ? @"Введите новый API-ключ:" : @"Enter new API Key:"
                                                       delegate:self
                                              cancelButtonTitle:[self systemCancelString]
                                              otherButtonTitles:isRU ? @"Сохранить" : @"Save", nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        alert.tag = 100;
        UITextField *tf = [alert textFieldAtIndex:0];
        tf.text = currentKey;
        [alert show];
        return;
    }
    
    if (buttonIndex == cancelIdx - 2) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:isRU ? @"Имя модели" : @"Model ID"
                                                        message:isRU ? @"Введите ID модели:" : @"Enter Model ID:"
                                                       delegate:self
                                              cancelButtonTitle:[self systemCancelString]
                                              otherButtonTitles:isRU ? @"Выбрать" : @"Select", nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        alert.tag = 200;
        UITextField *tf = [alert textFieldAtIndex:0];
        tf.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"selectedModel"] ?: @"";
        [alert show];
        return;
    }
    
    if (buttonIndex == cancelIdx - 3) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        [[GMAPIManager sharedManager] fetchAvailableModelsWithCompletion:^(NSArray *models, NSError *error) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            
            if (error || models.count == 0) {
                NSString *errText = error ? error.localizedDescription : (isRU ? @"Список пуст или не получен" : @"List empty");
                UIAlertView *errAlert = [[UIAlertView alloc] initWithTitle:isRU ? @"Ошибка" : @"Error"
                                                                   message:errText
                                                                  delegate:nil
                                                         cancelButtonTitle:@"OK"
                                                         otherButtonTitles:nil];
                [errAlert show];
                return;
            }
            
            self.availableModels = models;
            [[NSUserDefaults standardUserDefaults] setObject:models forKey:@"cachedModelList"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            NSString *okMsg = isRU ? [NSString stringWithFormat:@"Получено моделей: %lu", (unsigned long)models.count]
            : [NSString stringWithFormat:@"Loaded %lu models", (unsigned long)models.count];
            UIAlertView *okAlert = [[UIAlertView alloc] initWithTitle:isRU ? @"Готово" : @"Success"
                                                              message:okMsg
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
            [okAlert show];
        }];
        return;
    }
    
    if (buttonIndex < self.availableModels.count) {
        NSString *chosen = self.availableModels[buttonIndex];
        [[NSUserDefaults standardUserDefaults] setObject:chosen forKey:@"selectedModel"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.modelButton setTitle:[NSString stringWithFormat:@"%@ ▾", chosen] forState:UIControlStateNormal];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        UITextField *tf = [alertView textFieldAtIndex:0];
        NSString *val = [tf.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (val.length > 0) {
            if (alertView.tag == 100) {
                [[NSUserDefaults standardUserDefaults] setObject:val forKey:@"apiKey"];
            } else if (alertView.tag == 200) {
                [[NSUserDefaults standardUserDefaults] setObject:val forKey:@"selectedModel"];
                [self.modelButton setTitle:[NSString stringWithFormat:@"%@ ▾", val] forState:UIControlStateNormal];
            }
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

@end
