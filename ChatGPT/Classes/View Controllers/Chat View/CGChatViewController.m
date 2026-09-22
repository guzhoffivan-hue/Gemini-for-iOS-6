//
//  CGChatViewController.m
//  Gemini
//
//  Created by XML on 1/13/25.
//  Copyright (c) 2025 XML. All rights reserved.
//

#import "CGChatViewController.h"

@interface CGChatViewController () <UIActionSheetDelegate, UIAlertViewDelegate, UITextViewDelegate>

@property (nonatomic, strong) UIButton *modelButton;
@property (nonatomic, strong) UILabel *chatTitleLabel;
@property (nonatomic, strong) NSString *selectedModel;
@property (nonatomic, strong) NSArray *availableModels;

@end

@implementation CGChatViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (VERSION_MIN(@"7.0")) {
        
    } else {
        NSDictionary *titleTextAttributes = @{
                                              UITextAttributeTextColor: [UIColor colorWithWhite:0.15 alpha:1.0],
                                              UITextAttributeTextShadowOffset: [NSValue valueWithUIOffset:UIOffsetMake(0, 1)],
                                              UITextAttributeTextShadowColor: [UIColor colorWithWhite:1.0 alpha:0.8]
                                              };
        [self.navigationController.navigationBar setTitleTextAttributes:titleTextAttributes];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(handleAIResponse:) name:@"AI RESPONSE" object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(saveCurrentChat:) name:@"SAVE CHAT" object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(retrieveUserThings:) name:@"KEY IS VALID" object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(cancelLoad) name:@"CANCEL LOAD" object:nil];
    
    self.slideMenuController.bouncing = YES;
    self.slideMenuController.gestureSupport = APLSlideMenuGestureSupportDrag;
    self.slideMenuController.separatorColor = [UIColor grayColor];
    
    self.chatTableView.delegate = self;
    self.chatTableView.dataSource = self;
    self.messages = [NSMutableArray array];
    
    BOOL firstLaunch = [[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"];
    if (firstLaunch == NO) {
        [self prepareFirstLaunch];
    } else {
        [CGAPIHelper checkForAPIKeyValidity];
    }
    
    self.attachmentView.hidden = YES;
    self.attachmentImage.image = nil;
    self.attachmentImage.layer.cornerRadius = self.attachmentImage.frame.size.width / 8.0;
    self.attachmentImage.layer.masksToBounds = YES;
    
    if (self.currentConversationID == nil) {
        [self setCurrentConversationUniqueID:nil];
    }
    
    self.welcomeView.alpha = 0.0;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"aFL"] == YES) {
        [self displayWelcomeLaunchView];
    }
    
    [CGAPIHelper checkForAppUpdate];
    [self.inputField setDelegate:self];
    [[self.inputView layer] setMasksToBounds:YES];
    
    if (VERSION_MIN(@"7.0")) {
        self.chatTableView.backgroundColor = [UIColor colorWithWhite:0.98 alpha:1.0];
        [[self.inputView layer] setCornerRadius:7.25f];
        self.IVOverlayImage.image = [UIImage imageNamed:@"iOS7InputOverlay"];
        self.inputFieldPlaceholder.textColor = [UIColor colorWithRed:174/255.0 green:174/255.0 blue:174/255.0 alpha:1.0];
        self.inputField.textColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0];
        [self.sendButton setImage:nil];
        [self.hamburgerButton setImage:[[UIImage imageNamed:@"hamburgerButton"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        [self.sendButton setTitle:@"Send"];
        [self.sendButton setTitleTextAttributes:@{ UITextAttributeTextColor: [UIColor colorWithRed:26/255.0 green:115/255.0 blue:232/255.0 alpha:1.0] } forState:UIControlStateNormal];
        self.attachmentMask.image = [UIImage imageNamed:@"iOS7ImageViewOL"];
        self.WelcomeImage.image = [UIImage imageNamed:@"iOS7icon"];
        self.LThinkLabel.shadowColor = nil;
        self.LUserLabel.shadowColor = nil;
        self.LAvatar.image = [UIImage imageNamed:@"iOS7AssistantAvatar"];
        self.WelcomeHead.shadowColor = nil;
        self.WelcomeHead.textColor = [UIColor colorWithRed:26/255.0 green:115/255.0 blue:232/255.0 alpha:1.0];
    } else {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"bar-BG"] forBarMetrics:UIBarMetricsDefault];
        
        // Кнопка Send в стиле iOS 6 для UIBarButtonItem
        [self.sendButton setBackgroundImage:[UIImage imageNamed:@"SendBarButton"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [self.sendButton setBackgroundImage:[UIImage imageNamed:@"SendBarButtonPressed"] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
        
        NSDictionary *sendTextAttributes = @{
                                             UITextAttributeTextColor: [UIColor whiteColor],
                                             UITextAttributeTextShadowColor: [UIColor colorWithWhite:0.0 alpha:0.6],
                                             UITextAttributeTextShadowOffset: [NSValue valueWithUIOffset:UIOffsetMake(0, -1)]
                                             };
        [self.sendButton setTitleTextAttributes:sendTextAttributes forState:UIControlStateNormal];
        [self.sendButton setTitleTextAttributes:sendTextAttributes forState:UIControlStateHighlighted];
        
        // Боковые кнопки и тулбар
        [self.hamburgerButton setBackgroundImage:[UIImage imageNamed:@"BarButton"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [self.hamburgerButton setBackgroundImage:[UIImage imageNamed:@"BarButtonPressed"] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
        
        [self.topRightButton setBackgroundImage:[UIImage imageNamed:@"BarButton"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [self.topRightButton setBackgroundImage:[UIImage imageNamed:@"BarButtonPressed"] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
        
        [self.photoButton setBackgroundImage:[UIImage imageNamed:@"BarButton"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [self.photoButton setBackgroundImage:[UIImage imageNamed:@"BarButtonPressed"] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
        
        [self.toolbar setBackgroundImage:[UIImage imageNamed:@"bar-BG"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
        [[self.inputView layer] setCornerRadius:14.5f];
        
        // Приветствие "Welcome to Gemini" в синем цвете
        self.WelcomeHead.textColor = [UIColor colorWithRed:26/255.0 green:115/255.0 blue:232/255.0 alpha:1.0];
        self.WelcomeHead.shadowColor = [UIColor whiteColor];
        self.WelcomeHead.shadowOffset = CGSizeMake(0, 1);
    }
    
    self.inputFieldPlaceholder.hidden = (self.inputField.text.length > 0);
    
    // Модель по умолчанию — gemini-3.8-flash
    NSString *savedModel = [[NSUserDefaults standardUserDefaults] objectForKey:@"selectedModel"];
    if (!savedModel || savedModel.length == 0 || [savedModel hasPrefix:@"gemini-2.5"] || [savedModel isEqualToString:@"gemini-flash-latest"]) {
        savedModel = @"gemini-3.8-flash";
        [[NSUserDefaults standardUserDefaults] setObject:savedModel forKey:@"selectedModel"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    self.selectedModel = savedModel;
    
    [self setupModelSelector];
}

#pragma mark - Keyboard Notifications

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGRect keyboardFrame = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    // Сдвигаем тулбар вверх над клавиатурой
    CGRect toolbarFrame = self.toolbar.frame;
    toolbarFrame.origin.y = self.view.bounds.size.height - keyboardFrame.size.height - toolbarFrame.size.height;
    
    // Подгоняем размер таблицы
    CGRect tableFrame = self.chatTableView.frame;
    tableFrame.size.height = toolbarFrame.origin.y;
    
    [UIView animateWithDuration:duration delay:0.0 options:(curve << 16) animations:^{
        self.toolbar.frame = toolbarFrame;
        self.chatTableView.frame = tableFrame;
    } completion:^(BOOL finished) {
        if (self.messages.count > 0) {
            NSIndexPath *lastPath = [NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0];
            [self.chatTableView scrollToRowAtIndexPath:lastPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    NSTimeInterval duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    // Возвращаем тулбар ровно к нижней границе экрана
    CGRect toolbarFrame = self.toolbar.frame;
    toolbarFrame.origin.y = self.view.bounds.size.height - toolbarFrame.size.height;
    
    CGRect tableFrame = self.chatTableView.frame;
    tableFrame.size.height = toolbarFrame.origin.y;
    
    [UIView animateWithDuration:duration delay:0.0 options:(curve << 16) animations:^{
        self.toolbar.frame = toolbarFrame;
        self.chatTableView.frame = tableFrame;
    } completion:nil];
}
#pragma mark - UITextViewDelegate (Скрытие плейсхолдера при наборе)

- (void)textViewDidChange:(UITextView *)textView {
    self.inputFieldPlaceholder.hidden = (textView.text.length > 0);
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSString *newText = [textView.text stringByReplacingCharactersInRange:range withString:text];
    self.inputFieldPlaceholder.hidden = (newText.length > 0);
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    self.inputFieldPlaceholder.hidden = (textView.text.length > 0);
}

#pragma mark - Model Selector (iOS 6 & 7 Header)

- (void)setupModelSelector {
    UIView *titleContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    titleContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    titleContainer.backgroundColor = [UIColor clearColor];
    
    // Имя чата (верхняя строка)
    self.chatTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, 200, 18)];
    self.chatTitleLabel.text = self.navigationItem.title ?: @"Gemini";
    self.chatTitleLabel.font = [UIFont boldSystemFontOfSize:14];
    self.chatTitleLabel.textAlignment = NSTextAlignmentCenter;
    self.chatTitleLabel.backgroundColor = [UIColor clearColor];
    self.chatTitleLabel.tag = 9001;
    
    if (VERSION_MIN(@"7.0")) {
        self.chatTitleLabel.textColor = [UIColor blackColor];
    } else {
        // Черный текст со светлой нижней тенью (эффект гравировки iOS 6)
        self.chatTitleLabel.textColor = [UIColor colorWithWhite:0.15 alpha:1.0];
        self.chatTitleLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.8];
        self.chatTitleLabel.shadowOffset = CGSizeMake(0, 1);
    }
    [titleContainer addSubview:self.chatTitleLabel];
    
    // Название модели (нижняя кликабельная строка)
    self.modelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.modelButton.frame = CGRectMake(0, 20, 200, 22);
    
    [self.modelButton setTitle:[NSString stringWithFormat:@"%@  ▾", self.selectedModel] forState:UIControlStateNormal];
    [self.modelButton.titleLabel setFont:[UIFont systemFontOfSize:11]];
    self.modelButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.modelButton.titleLabel.minimumScaleFactor = 0.7;
    
    if (VERSION_MIN(@"7.0")) {
        [self.modelButton setTitleColor:[UIColor colorWithRed:26/255.0 green:115/255.0 blue:232/255.0 alpha:1.0] forState:UIControlStateNormal];
    } else {
        // Темно-серый / почти черный текст со светлой тенью
        [self.modelButton setTitleColor:[UIColor colorWithWhite:0.25 alpha:1.0] forState:UIControlStateNormal];
        self.modelButton.titleLabel.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.8];
        self.modelButton.titleLabel.shadowOffset = CGSizeMake(0, 1);
    }
    
    [self.modelButton addTarget:self action:@selector(modelButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [titleContainer addSubview:self.modelButton];
    
    self.navigationItem.titleView = titleContainer;
}

- (void)modelButtonTapped:(UIButton *)sender {
    [self fetchAvailableModels];
}

#pragma mark - Fetch Models via NSURLConnection (iOS 6 Safe)

- (void)fetchAvailableModels {
    NSString *key = [[NSUserDefaults standardUserDefaults] objectForKey:@"apiKey"] ?: apiKey;
    if (key.length == 0) {
        [self showModelActionSheetWithList:nil];
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"https://generativelanguage.googleapis.com/v1beta/models?key=%@", key];
    NSURL *url = [NSURL URLWithString:urlString];
    if (!url) {
        [self showModelActionSheetWithList:nil];
        return;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setTimeoutInterval:15.0];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (error || data.length == 0) {
                                   [self showModelActionSheetWithList:nil];
                                   return;
                               }
                               
                               NSError *jsonError = nil;
                               NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                               if (jsonError || ![json isKindOfClass:[NSDictionary class]]) {
                                   [self showModelActionSheetWithList:nil];
                                   return;
                               }
                               
                               NSArray *modelsArray = json[@"models"];
                               NSMutableArray *fetched = [NSMutableArray array];
                               
                               for (NSDictionary *m in modelsArray) {
                                   if (![m isKindOfClass:[NSDictionary class]]) continue;
                                   NSArray *methods = m[@"supportedGenerationMethods"];
                                   if ([methods isKindOfClass:[NSArray class]] && [methods containsObject:@"generateContent"]) {
                                       NSString *name = m[@"name"];
                                       if (name.length > 0) {
                                           NSString *cleanId = [name stringByReplacingOccurrencesOfString:@"models/" withString:@""];
                                           if ([cleanId hasPrefix:@"gemini"]) {
                                               [fetched addObject:cleanId];
                                           }
                                       }
                                   }
                               }
                               
                               [self showModelActionSheetWithList:fetched];
                           }];
}

#pragma mark - Меню моделей с системной локализацией

- (void)showModelActionSheetWithList:(NSArray *)models {
    if (models && models.count > 0) {
        self.availableModels = models;
    } else {
        self.availableModels = @[@"gemini-3.8-flash", @"gemini-3.5-flash", @"gemini-2.0-flash", @"gemini-2.0-flash-lite"];
    }
    
    NSString *currentLang = [[NSLocale preferredLanguages] objectAtIndex:0];
    BOOL isRussian = [currentLang hasPrefix:@"ru"];
    
    NSString *sheetTitle = isRussian ? @"Выберите модель Gemini" : @"Select Gemini Model";
    NSString *manualOptionTitle = isRussian ? @"✏️ Ввести имя вручную..." : @"✏️ Enter model manually...";
    NSString *systemCancel = [[NSBundle bundleWithIdentifier:@"com.apple.UIKit"] localizedStringForKey:@"Cancel" value:@"Cancel" table:nil];
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:sheetTitle
                                                       delegate:self
                                              cancelButtonTitle:nil
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:nil];
    sheet.tag = 100;
    
    [sheet addButtonWithTitle:manualOptionTitle];
    
    for (NSString *modelId in self.availableModels) {
        NSString *mark = [modelId isEqualToString:self.selectedModel] ? @"✓ " : @"";
        [sheet addButtonWithTitle:[NSString stringWithFormat:@"%@%@", mark, modelId]];
    }
    
    sheet.cancelButtonIndex = [sheet addButtonWithTitle:systemCancel];
    [sheet showInView:self.view];
}

- (void)saveAndApplyModel:(NSString *)newModel {
    self.selectedModel = newModel;
    [[NSUserDefaults standardUserDefaults] setObject:newModel forKey:@"selectedModel"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.modelButton setTitle:[NSString stringWithFormat:@"%@  ▾", newModel] forState:UIControlStateNormal];
}

#pragma mark - ActionSheet & AlertView Delegates

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (popup.tag == 100) {
        if (buttonIndex == popup.cancelButtonIndex) return;
        
        if (buttonIndex == 0) {
            NSString *currentLang = [[NSLocale preferredLanguages] objectAtIndex:0];
            BOOL isRussian = [currentLang hasPrefix:@"ru"];
            
            NSString *alertTitle = isRussian ? @"Своя модель" : @"Custom Model";
            NSString *alertMsg = isRussian ? @"Введите точный ID модели (например: gemini-3.8-flash)" : @"Enter exact model ID (e.g. gemini-3.8-flash)";
            NSString *saveBtn = isRussian ? @"Сохранить" : @"Save";
            NSString *cancelBtn = [[NSBundle bundleWithIdentifier:@"com.apple.UIKit"] localizedStringForKey:@"Cancel" value:@"Cancel" table:nil];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle
                                                            message:alertMsg
                                                           delegate:self
                                                  cancelButtonTitle:cancelBtn
                                                  otherButtonTitles:saveBtn, nil];
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            alert.tag = 200;
            
            UITextField *field = [alert textFieldAtIndex:0];
            field.text = self.selectedModel;
            field.autocapitalizationType = UITextAutocapitalizationTypeNone;
            field.autocorrectionType = UITextAutocorrectionTypeNo;
            [alert show];
            return;
        }
        
        NSInteger modelIdx = buttonIndex - 1;
        if (modelIdx >= 0 && modelIdx < (NSInteger)self.availableModels.count) {
            [self saveAndApplyModel:self.availableModels[modelIdx]];
        }
        return;
    }
    
    if (popup.tag == 1) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = (id)self;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        if (buttonIndex == 0) {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            } else {
                return;
            }
        } else if (buttonIndex == 1) {
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        } else {
            return;
        }
        
        [self presentViewController:picker animated:YES completion:nil];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 200) {
        if (buttonIndex == 1) {
            UITextField *field = [alertView textFieldAtIndex:0];
            NSString *custom = [field.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if (custom.length > 0) {
                [self saveAndApplyModel:custom];
            }
        }
        return;
    }
    
    if (alertView.tag == 1) {
        if (buttonIndex == alertView.firstOtherButtonIndex) {
            NSString *enteredText = [alertView textFieldAtIndex:0].text;
            self.navigationItem.title = enteredText;
            
            UIView *container = self.navigationItem.titleView;
            UILabel *titleLabel = (UILabel *)[container viewWithTag:9001];
            if ([titleLabel isKindOfClass:[UILabel class]]) {
                titleLabel.text = enteredText;
            }
            
            self.notTheAlert = NO;
            [self saveCurrentChat:nil];
            [NSNotificationCenter.defaultCenter postNotificationName:@"RE-CHECK CONVOS" object:nil];
        } else if (buttonIndex == alertView.cancelButtonIndex) {
            self.notTheAlert = NO;
        }
    }
}

#pragma mark - Chat & Message Handlers

- (void)handleAIResponse:(NSNotification *)notification {
    CGMessage *Response = notification.object;
    [self slideUpTypeView];
    [self.messages addObject:Response];
    [self.chatTableView reloadData];
    if (self.viewingPresentTime) {
        [self.chatTableView setContentOffset:CGPointMake(0, self.chatTableView.contentSize.height - self.chatTableView.frame.size.height) animated:YES];
    }
    
    if (self.messages.count >= 5 && self.messages.count <= 17) {
        if (self.done == NO) {
            [self invokeTitleChange];
        }
    }
}

- (void)retrieveUserThings:(NSNotification *)notification {
}

- (void)saveCurrentChat:(NSNotification *)notification {
    if (self.messages.count > 0) {
        [CGAPIHelper saveConversationWithArray:self.messages withID:self.currentConversationID withTitle:self.navigationItem.title];
    }
}

- (void)cancelLoad {
    [self slideUpTypeView];
}

- (void)prepareFirstLaunch {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self performSegueWithIdentifier:@"welcome" sender:self];
    });
}

- (void)loadChat:(NSMutableArray *)messages withUUID:(NSString *)uuid {
    self.messages = messages;
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"aFL"];
    self.welcomeView.alpha = 0.0;
    self.welcomeView = nil;
    
    if (messages.count < 6) {
        self.done = NO;
    }
    [self setCurrentConversationUniqueID:uuid];
    [self.chatTableView reloadData];
}

- (void)tappedImage:(UITapGestureRecognizer *)gesture {
    UIView *tappedView = gesture.view;
    UIView *cellView = VERSION_MIN(@"7.0") ? tappedView.superview.superview.superview : tappedView.superview.superview;
    CGImageAttachment *cell = (CGImageAttachment *)cellView;
    UIImage *selectedImage = cell.thumbnail.image;
    if (selectedImage) {
        self.selectedImage = selectedImage;
        [self performSegueWithIdentifier:@"to Viewer" sender:self];
    }
}

- (void)startNewConversation {
    [self.inputField resignFirstResponder];
    self.inputField.text = @"";
    self.inputFieldPlaceholder.hidden = NO;
    
    if (self.typeView.frame.origin.y == 30) {
        [self slideUpTypeView];
    }
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"aFL"];
    self.welcomeView.alpha = 0.0;
    self.welcomeView = nil;
    
    [self setCurrentConversationUniqueID:nil];
    self.messages = NSMutableArray.new;
    [self.chatTableView reloadData];
    self.done = NO;
}

- (void)displayWelcomeLaunchView {
    [UIView animateWithDuration:0.33 animations:^{
        self.welcomeView.alpha = 1.0;
    }];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    self.inputFieldPlaceholder.hidden = (textView.text.length > 0);
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"aFL"] == YES) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"aFL"];
        [UIView animateWithDuration:0.33 animations:^{
            self.welcomeView.alpha = 0.0;
        } completion:^(BOOL finished) {
            if (finished) {
                self.welcomeView = nil;
            }
        }];
    }
}

- (IBAction)send:(id)sender {
    NSString *trimmedText = [self.inputField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\b(draw|illustrate|generate an image|generate an|generate me an image|image of|create a picture of|show me an image of)\\b"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];
    NSRange range = NSMakeRange(0, [trimmedText length]);
    NSUInteger matches = [regex numberOfMatchesInString:trimmedText options:0 range:range];
    
    if (trimmedText.length == 0) {
        [self.inputField resignFirstResponder];
        return;
    }
    
    if (trimmedText.length < 3) {
        [CGAPIHelper alert:@"Too short" withMessage:@"For the sake of preserving your API Credit, you should ask the AI questions that are longer than three characters."];
        return;
    }
    
    CGMessage *ownMessage = CGMessage.new;
    
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
    NSString *tmpDirectory = NSTemporaryDirectory();
    NSString *filePath = [tmpDirectory stringByAppendingPathComponent:@"avatar.png"];
    UIImage *image = [UIImage imageWithContentsOfFile:filePath];
    
    ownMessage.author = (username.length >= 3) ? username : @"You";
    if (VERSION_MIN(@"7.0")) {
        ownMessage.avatar = image ?: [UIImage imageNamed:@"iOS7DefaultUserAvatar"];
    } else {
        ownMessage.avatar = image ?: [UIImage imageNamed:@"defaultUserAvatar"];
    }
    ownMessage.role = @"user";
    ownMessage.content = trimmedText;
    ownMessage.type = 1;
    ownMessage.imageHash = nil;
    ownMessage.imageAttachment = nil;
    
    if (self.attachmentImage.image != nil) {
        NSData *imageData = UIImagePNGRepresentation(self.attachmentImage.image);
        if (imageData) {
            ownMessage.imageAttachment = self.attachmentImage.image;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSString *encodedImage = [imageData base64EncodedString];
                dispatch_async(dispatch_get_main_queue(), ^{
                    ownMessage.imageHash = encodedImage;
                });
            });
        }
    }
    
    float contentWidth = UIScreen.mainScreen.bounds.size.width - 63;
    CGSize textSize = [ownMessage.content sizeWithFont:[UIFont systemFontOfSize:15]
                                     constrainedToSize:CGSizeMake(contentWidth, MAXFLOAT)
                                         lineBreakMode:NSLineBreakByWordWrapping];
    ownMessage.contentHeight = textSize.height + 50;
    
    // Добавляем текущее сообщение на экран
    [self.messages addObject:ownMessage];
    [self.chatTableView reloadData];
    
    // -------------------------------------------------------------
    // ЧИСТКА ИСТОРИИ (чтобы не падало со 2-го сообщения):
    // Выкидываем из истории системные ошибки и ограничиваем длину контекста
    NSMutableArray *cleanHistory = [NSMutableArray array];
    for (CGMessage *msg in self.messages) {
        if ([msg.content hasPrefix:@"[API Error:"] || [msg.content hasPrefix:@"[Error:"]) {
            continue; // Пропускаем ошибку, не шлем её серверу
        }
        [cleanHistory addObject:msg];
    }
    
    if (cleanHistory.count > 6) {
        NSRange range = NSMakeRange(cleanHistory.count - 6, 6);
        cleanHistory = [[cleanHistory subarrayWithRange:range] mutableCopy];
    }
    // -------------------------------------------------------------
    
    if (matches > 0) {
        [CGAPICommunicator createImageGenerationWithContent:trimmedText];
    } else {
        // Отправляем очищенную историю вместо всего подряд
        [CGAPICommunicator createChatCompletionwithContent:cleanHistory];
    }
    
    self.inputField.text = @"";
    self.inputFieldPlaceholder.hidden = NO;
    [self removeAttachment];
    [self slideDownTypeView];
    self.attachmentImage.image = nil;
    
    if (self.viewingPresentTime) {
        [self.chatTableView setContentOffset:CGPointMake(0, self.chatTableView.contentSize.height - self.chatTableView.frame.size.height) animated:YES];
    }
}

- (IBAction)camera:(id)sender {
    [self.inputField resignFirstResponder];
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            UIImagePickerController *picker = UIImagePickerController.new;
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            picker.delegate = (id)self;
            
            UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:picker];
            self.imagePopoverController = popoverController;
            
            if ([sender isKindOfClass:[UIBarButtonItem class]]) {
                UIBarButtonItem *barButtonItem = (UIBarButtonItem *)sender;
                [popoverController presentPopoverFromBarButtonItem:barButtonItem
                                          permittedArrowDirections:UIPopoverArrowDirectionAny
                                                          animated:YES];
            }
        }
    } else {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIActionSheet *imageSourceActionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                                delegate:self
                                                                       cancelButtonTitle:@"Cancel"
                                                                  destructiveButtonTitle:nil
                                                                       otherButtonTitles:@"Take Photo or Video", @"Choose Existing", nil];
            [imageSourceActionSheet setTag:1];
            [imageSourceActionSheet showInView:self.view];
        } else {
            UIImagePickerController *picker = UIImagePickerController.new;
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            picker.delegate = (id)self;
            [self presentViewController:picker animated:YES completion:nil];
        }
    }
}

- (IBAction)showSidebar:(id)sender {
    [self.slideMenuController showLeftMenu:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissModalViewControllerAnimated:YES];
    [self.imagePopoverController dismissPopoverAnimated:YES];
    self.imagePopoverController = nil;
    
    UIImage *originalImage = [info objectForKey:UIImagePickerControllerEditedImage];
    if (!originalImage) originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    if (!originalImage) originalImage = [info objectForKey:UIImagePickerControllerCropRect];
    
    self.attachmentImage.image = originalImage;
    self.attachmentView.hidden = NO;
    [UIView animateWithDuration:0.33 animations:^{
        self.attachmentView.alpha = 1.0;
    } completion:nil];
}

- (IBAction)didTapAttachment:(id)sender {
    [self.attachmentView becomeFirstResponder];
    
    UIMenuItem *option1 = [[UIMenuItem alloc] initWithTitle:@"View" action:@selector(viewAttachment)];
    UIMenuItem *option2 = [[UIMenuItem alloc] initWithTitle:@"Remove" action:@selector(removeAttachment)];
    
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    [menuController setMenuItems:@[option1, option2]];
    
    UIView *senderView = self.attachmentView;
    if (senderView.superview) {
        [menuController setTargetRect:senderView.frame inView:senderView.superview];
        [menuController setMenuVisible:YES animated:YES];
    }
}

- (void)viewAttachment {
    if (self.attachmentImage.image != nil) {
        [self performSegueWithIdentifier:@"to Viewer" sender:self];
    }
}

- (void)removeAttachment {
    [UIView animateWithDuration:0.33 animations:^{
        self.attachmentView.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            self.attachmentView.hidden = YES;
            self.attachmentImage.image = nil;
        }
    }];
}

- (void)setCurrentConversationUniqueID:(NSString *)ConversationID {
    if (ConversationID != nil) {
        self.currentConversationID = ConversationID;
    } else {
        self.currentConversationID = [[NSUUID UUID] UUIDString];
    }
}

#pragma mark - Animations

- (void)slideDownTypeView {
    CGRect currentFrame = self.typeView.frame;
    CGRect finalFrame = CGRectOffset(currentFrame, 0, 30);
    [UIView animateWithDuration:0.25 animations:^{
        self.typeView.frame = finalFrame;
    }];
}

- (void)slideUpTypeView {
    CGRect currentFrame = self.typeView.frame;
    CGRect finalFrame = CGRectOffset(currentFrame, 0, -30);
    [UIView animateWithDuration:0.25 animations:^{
        self.typeView.frame = finalFrame;
    }];
}

- (void)invokeTitleChange {
    if (self.notTheAlert) {
        return;
    }
    self.done = YES;
    int randomDelay = arc4random_uniform(16) + 15;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(randomDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.notTheAlert = YES;
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Already have an idea?" message:@"Give your conversation a fitting name." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Done", nil];
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alertView setTag:1];
        [alertView show];
        [self.inputField resignFirstResponder];
    });
}

#pragma mark - UITableView DataSource & Delegate

- (int)countOfMessages {
    return (int)self.messages.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rowCount = 0;
    for (CGMessage *message in self.messages) {
        rowCount++;
        if (message.imageAttachment != nil) {
            rowCount++;
        }
    }
    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger messageIndex = 0;
    
    for (NSInteger i = 0; i < self.messages.count; i++) {
        CGMessage *message = self.messages[i];
        
        if (indexPath.row == messageIndex) {
            if (message.type == 2) {
                [tableView registerNib:[UINib nibWithNibName:@"CGChatTableCell" bundle:nil] forCellReuseIdentifier:@"Message Cell"];
                CGChatTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Message Cell"];
                
                [cell.authorLabel setText:message.author];
                
                if (VERSION_MIN(@"6.0")) {
                    [cell configureWithMessage:message.content];
                    cell.iOS7Separator.hidden = YES;
                } else {
                    [cell.contentTextView setText:message.content];
                }
                
                if (VERSION_MIN(@"7.0")) {
                    [cell.contentView setBackgroundColor:[UIColor colorWithWhite:0.96 alpha:1.0]];
                    [cell.authorLabel setTextColor:[UIColor colorWithRed:26/255.0 green:115/255.0 blue:232/255.0 alpha:1.0]];
                } else {
                    cell.iOS7Separator.hidden = YES;
                    cell.separator.hidden = NO;
                    [cell.authorLabel setTextColor:[UIColor colorWithRed:26/255.0 green:115/255.0 blue:232/255.0 alpha:1.0]];
                }
                [cell.avatar setImage:message.avatar];
                return cell;
            } else {
                [tableView registerNib:[UINib nibWithNibName:@"CGAuthorChatTableCell" bundle:nil] forCellReuseIdentifier:@"Author Cell"];
                CGAuthorTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Author Cell"];
                
                [cell.authorLabel setText:message.author];
                [cell.contentTextView setText:message.content];
                [cell.avatar setImage:message.avatar];
                return cell;
            }
        }
        
        messageIndex++;
        
        if (message.imageAttachment != nil) {
            if (indexPath.row == messageIndex) {
                if (message.type == 2) {
                    [tableView registerNib:[UINib nibWithNibName:@"CGAImageAttachment" bundle:nil] forCellReuseIdentifier:@"A Image Cell"];
                    CGAImageAttachment *cell = [tableView dequeueReusableCellWithIdentifier:@"A Image Cell"];
                    [cell.thumbnail setImage:message.imageAttachment];
                    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedImage:)];
                    [cell.totalThumbView addGestureRecognizer:tap];
                    return cell;
                } else {
                    [tableView registerNib:[UINib nibWithNibName:@"CGImageAttachment" bundle:nil] forCellReuseIdentifier:@"Image Cell"];
                    CGImageAttachment *cell = [tableView dequeueReusableCellWithIdentifier:@"Image Cell"];
                    [cell.thumbnail setImage:message.imageAttachment];
                    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedImage:)];
                    [cell.totalThumbView addGestureRecognizer:tap];
                    return cell;
                }
            }
            messageIndex++;
        }
    }
    
    return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DefaultCell"];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger messageIndex = 0;
    
    for (NSInteger i = 0; i < self.messages.count; i++) {
        CGMessage *message = self.messages[i];
        
        if (indexPath.row == messageIndex) {
            return message.contentHeight;
        }
        
        messageIndex++;
        
        if (message.imageAttachment != nil) {
            if (indexPath.row == messageIndex) {
                return 150.0;
            }
            messageIndex++;
        }
    }
    return 44.0;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

@end