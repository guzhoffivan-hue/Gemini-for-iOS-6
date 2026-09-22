//
//  CGWelcomeController.m
//  Gemini
//
//  Created by XML on 27/02/25.
//  Copyright (c) 2025 XML. All rights reserved.
//

#import "CGWelcomeController.h"

@interface CGWelcomeController () <UITextFieldDelegate>

@end

@implementation CGWelcomeController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (VERSION_MIN(@"7.0")) {
        
    } else {
        NSDictionary *titleTextAttributes = @{
                                              UITextAttributeTextColor: [UIColor colorWithRed:26/255.0 green:115/255.0 blue:232/255.0 alpha:1.0],
                                              UITextAttributeTextShadowOffset: [NSValue valueWithUIOffset:UIOffsetMake(0, 1)],
                                              UITextAttributeTextShadowColor: [UIColor whiteColor]
                                              };
        [self.navigationController.navigationBar setTitleTextAttributes:titleTextAttributes];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (VERSION_MIN(@"7.0")) {
        self.tableView.backgroundColor = [UIColor colorWithWhite:0.98 alpha:1.0];
        self.mainView.backgroundColor = [UIColor colorWithWhite:0.98 alpha:1.0];
        
        self.secondaryView1.backgroundColor = [UIColor colorWithWhite:0.98 alpha:1.0];
        self.secondaryView2.backgroundColor = [UIColor colorWithWhite:0.98 alpha:1.0];
        self.secondaryView3.backgroundColor = [UIColor colorWithWhite:0.98 alpha:1.0];
        
        self.separator1.hidden = YES;
        self.separator3.hidden = YES;
        self.separator2.hidden = YES;
        self.separator4.hidden = YES;
        
        self.head1.shadowColor = nil;
        self.head2.shadowColor = nil;
        self.head3.shadowColor = nil;
        self.head4.shadowColor = nil;
        self.realWELSlideLabel.shadowColor = nil;
        
        self.inputFieldBackground.image = [UIImage imageNamed:@"iOS7KIF"];
        self.SCTImage.image = [UIImage imageNamed:@"iOS7SCT"];
        self.realWELSlideIcon.image = [UIImage imageNamed:@"iOS7WEL"];
    } else {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"bar-BG"] forBarMetrics:UIBarMetricsDefault];
        self.i7sep1.hidden = YES;
        self.i7sep2.hidden = YES;
        self.i7sep3.hidden = YES;
        self.i7sep4.hidden = YES;
    }
    
    self.authenticated = NO;
    self.WLBoxView.alpha = 0.0;
    
    // Безопасное подключение текстового поля
    if (self.KeyInputField) {
        self.KeyInputField.delegate = self;
        self.KeyInputField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.KeyInputField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.KeyInputField.returnKeyType = UIReturnKeyDone;
        
        // На случай если в XIB привязан action на editingChanged
        [self.KeyInputField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(endOOBE:) name:@"LOG-IN VALID" object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(abruptFailure:) name:@"LOG-IN FAILURE" object:nil];
}

- (void)dismissKeyboard {
    if (self.KeyInputField && [self.KeyInputField isFirstResponder]) {
        [self.KeyInputField resignFirstResponder];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self bringIntroductionInShape];
}

- (void)bringIntroductionInShape {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CGRect SiCurrentFrame = self.slideicon.frame;
        CGRect SiFinalFrame = CGRectOffset(SiCurrentFrame, -60, 0);
        
        CGRect SLCurrentFrame = self.slideLabel.frame;
        CGRect SLFinalFrame = CGRectOffset(SLCurrentFrame, 130, 0);
        [UIView animateWithDuration:0.75 animations:^{
            self.WLBoxView.alpha = 1.0;
            self.slideicon.frame = SiFinalFrame;
            self.slideLabel.frame = SLFinalFrame;
        }];
    });
    
    CABasicAnimation *rocking = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rocking.fromValue = @(-M_PI / 16);
    rocking.toValue = @(M_PI / 16);
    rocking.duration = 1.5;
    rocking.autoreverses = YES;
    rocking.repeatCount = INFINITY;
    rocking.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    [self.SCThumbnailView.layer addAnimation:rocking forKey:@"rockingAnimation"];
    [self.CONVThumbnailView.layer addAnimation:rocking forKey:@"rockingAnimation"];
    [self.pickThumbnailView.layer addAnimation:rocking forKey:@"rockingAnimation"];
}

#pragma mark - Защитные методы UITextField

- (void)textFieldDidChange:(UITextField *)textField {
    // Заглушка для предотвращения краша
}

- (IBAction)editingDidBegin:(id)sender {
    // Заглушка если в IB привязан Action
}

- (IBAction)editingChanged:(id)sender {
    // Заглушка если в IB привязан Action
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self dismissKeyboard];
    
    NSString *enteredKey = [self.KeyInputField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (enteredKey.length == 0) {
        return YES;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:enteredKey forKey:@"apiKey"];
    [[NSUserDefaults standardUserDefaults] setObject:@"Gemini User" forKey:@"username"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [SVProgressHUD showWithStatus:@"Connecting to Gemini..." maskType:SVProgressHUDMaskTypeGradient];
    
    [NSNotificationCenter.defaultCenter postNotificationName:@"LOG-IN VALID" object:nil];
    return YES;
}

#pragma mark - Handlers

- (void)endOOBE:(NSNotification *)notification {
    [SVProgressHUD dismiss];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstLaunch"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self dismissModalViewControllerAnimated:YES];
        [SVProgressHUD showSuccessWithStatus:@"Ready!"];
    });
}

- (void)abruptFailure:(NSNotification *)notification {
    [SVProgressHUD dismiss];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [SVProgressHUD showErrorWithStatus:@"Error. Retry."];
    });
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

@end