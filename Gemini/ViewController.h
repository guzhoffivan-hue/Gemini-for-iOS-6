#import <UIKit/UIKit.h>
#import "GMChatSession.h"

@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIActionSheetDelegate, UIAlertViewDelegate>

// Основной чат
@property (nonatomic, strong) UITableView *chatTableView;
@property (nonatomic, strong) UIToolbar *inputToolbar;
@property (nonatomic, strong) UITextField *inputTextField;
@property (nonatomic, strong) UIBarButtonItem *sendButton;
@property (nonatomic, strong) UIButton *modelButton;

// Текущая сессия и список
@property (nonatomic, strong) GMChatSession *currentSession;
@property (nonatomic, strong) NSMutableArray *allSessions;
@property (nonatomic, strong) NSArray *availableModels;

// Выезжающая шторка истории (стиль «Напоминания»)
@property (nonatomic, strong) UIView *drawerContainerView;
@property (nonatomic, strong) UITableView *historyTableView;
@property (nonatomic, strong) UIButton *createChatButton;
@property (nonatomic, assign) BOOL isDrawerOpen;

@end