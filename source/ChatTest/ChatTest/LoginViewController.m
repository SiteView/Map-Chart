//
//  LoginViewController.m
//  ChatTest
//
//  Created by siteview_mac on 13-7-10.
//  Copyright (c) 2013年 siteview_mac. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"

@implementation LoginViewController {
    UITextField                     * accountTextField_;
    UITextField                     * passwordTextField_;
    UISwitch                        * rememberMeSwitcher_;
    UITextField                     * serverTextField_;
    UITextField                     * serverNameTextField_;
    UIControl                       * view_;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Get the stored data before the view loads
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *account = [defaults objectForKey:@"account"];
    NSString *password = [defaults objectForKey:@"password"];
    NSString *serverName = [defaults objectForKey:@"serverName"];
    NSString *serverAddress = [defaults objectForKey:@"serverAddress"];
    
    self.title = @"Login";

    view_ = [[UIControl alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    [view_ addTarget:self action:@selector(backgroundTap:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:view_];

    self.view.backgroundColor =
    [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.8];

    CGPoint ptAccount;
    CGSize sizeAccount;
    
    float passwordWidth = 180;
    float serverWidth = 180;
    float serverNameWidth = 180;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        ptAccount.x = 120;
        ptAccount.y = 16;
        sizeAccount.width = 180;
        sizeAccount.height = 29;
    } else {
        ptAccount.x = 120;
        ptAccount.y = 16;
        sizeAccount.width = 400;
        sizeAccount.height = 29;
        
        passwordWidth = 400;
        serverWidth = 400;
        serverNameWidth = 400;
    }
    // Account label.
    UILabel *accountLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 16, 200, 29)];
    accountLabel.text = @"Account";
    accountLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    accountLabel.textAlignment = NSTextAlignmentLeft;
    accountLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:accountLabel];

    accountTextField_ = [[UITextField alloc] initWithFrame:CGRectMake(130, 16, sizeAccount.width, 30)];
    accountTextField_.borderStyle = UITextBorderStyleRoundedRect;
    accountTextField_.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    accountTextField_.delegate = self;
    accountTextField_.returnKeyType = UIReturnKeyJoin;
    accountTextField_.clearButtonMode = UITextFieldViewModeWhileEditing;
    accountTextField_.autocapitalizationType = UITextAutocapitalizationTypeNone;
    accountTextField_.keyboardType = UIKeyboardTypeEmailAddress;
    accountTextField_.text = account;
    
    [self.view addSubview:accountTextField_];
    
    // Password label.
    UILabel *passwordLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 64, 200, 29)];
    passwordLabel.text = @"Password";
    passwordLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    passwordLabel.textAlignment = NSTextAlignmentLeft;
    passwordLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:passwordLabel];
    
    passwordTextField_ = [[UITextField alloc] initWithFrame:CGRectMake(130, 64, passwordWidth, 30)];
    passwordTextField_.borderStyle = UITextBorderStyleRoundedRect;
    passwordTextField_.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    passwordTextField_.delegate = self;
    passwordTextField_.returnKeyType = UIReturnKeyJoin;
    passwordTextField_.clearButtonMode = UITextFieldViewModeWhileEditing;
    passwordTextField_.autocapitalizationType = UITextAutocapitalizationTypeNone;
    passwordTextField_.secureTextEntry = YES;
    passwordTextField_.text = password;
    [self.view addSubview:passwordTextField_];
    
    // Server label.
    UILabel *serverLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 112, 200, 29)];
    serverLabel.text = @"Server";
    serverLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    serverLabel.textAlignment = NSTextAlignmentLeft;
    serverLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:serverLabel];
    
    serverTextField_ = [[UITextField alloc] initWithFrame:CGRectMake(130, 112, serverWidth, 30)];
    serverTextField_.borderStyle = UITextBorderStyleRoundedRect;
    serverTextField_.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    serverTextField_.delegate = self;
    serverTextField_.returnKeyType = UIReturnKeyJoin;
    serverTextField_.clearButtonMode = UITextFieldViewModeWhileEditing;
    serverTextField_.autocapitalizationType = UITextAutocapitalizationTypeNone;
    serverTextField_.keyboardType = UIKeyboardTypeEmailAddress;
    serverTextField_.text = serverAddress;
    [self.view addSubview:serverTextField_];
    
    // Server label.
    UILabel *serverNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 160, 200, 29)];
    serverNameLabel.text = @"Server Name";
    serverNameLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    serverNameLabel.textAlignment = NSTextAlignmentLeft;
    serverNameLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:serverNameLabel];
    
    serverNameTextField_ = [[UITextField alloc] initWithFrame:CGRectMake(130, 160, serverNameWidth, 30)];
    serverNameTextField_.borderStyle = UITextBorderStyleRoundedRect;
    serverNameTextField_.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    serverNameTextField_.delegate = self;
    serverNameTextField_.returnKeyType = UIReturnKeyJoin;
    serverNameTextField_.clearButtonMode = UITextFieldViewModeWhileEditing;
    serverNameTextField_.autocapitalizationType = UITextAutocapitalizationTypeNone;
    serverNameTextField_.keyboardType = UIKeyboardTypeEmailAddress;
    serverNameTextField_.text = serverName;
    [self.view addSubview:serverNameTextField_];

    // Remember Me label.
    UILabel *rememberMeLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 208, 200, 29)];
    rememberMeLabel.text = @"Remember Me";
    rememberMeLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    rememberMeLabel.textAlignment = NSTextAlignmentLeft;
    rememberMeLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:rememberMeLabel];
    
    // Remember Me switch.
    rememberMeSwitcher_ = [[UISwitch alloc] initWithFrame:CGRectMake(170, 208, 0, 0)];
    rememberMeSwitcher_.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [rememberMeSwitcher_ addTarget:self action:@selector(didChangeZoomSwitch)
          forControlEvents:UIControlEventValueChanged];
    rememberMeSwitcher_.on = YES;
    [self.view addSubview:rememberMeSwitcher_];
    
    UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    loginBtn.frame = CGRectMake(16, 256, 90, 30);
    loginBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    [loginBtn setTitle:@"Login" forState:UIControlStateNormal];
    loginBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    [loginBtn addTarget:self
                 action:@selector(loginBtnPress)
       forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginBtn];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    cancelBtn.frame = CGRectMake(148, 256, 90, 30);
    [cancelBtn setTitle:@"Cancel" forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    cancelBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    [cancelBtn addTarget:self
                 action:@selector(cancelBtnPress)
       forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelBtn];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)didChangeZoomSwitch {
    
}

- (void) loginBtnPress
{
    [self callbackKyeBoard];
    [self login];
}

- (void) cancelBtnPress
{
    [self callbackKyeBoard];
}

- (void)backgroundTap:(id)sender {
    [accountTextField_ resignFirstResponder];
    [passwordTextField_ resignFirstResponder];
    [serverTextField_ resignFirstResponder];
    [serverNameTextField_ resignFirstResponder];
}

#pragma mark -
- (void) callbackKyeBoard
{
    [accountTextField_ resignFirstResponder];
    [passwordTextField_ resignFirstResponder];
    [serverTextField_ resignFirstResponder];
    [serverNameTextField_ resignFirstResponder];
}

- (void) login {
    NSString *account = accountTextField_.text;
    NSString *password = passwordTextField_.text;
    NSString *serverName = serverNameTextField_.text;
    NSString *serverAddress = serverTextField_.text;

    if (rememberMeSwitcher_.on == YES) {
        // Store the data
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:account forKey:@"account"];
        [defaults setObject:password forKey:@"password"];
        [defaults setObject:serverName forKey:@"serverName"];
        [defaults setObject:serverAddress forKey:@"serverAddress"];
        [defaults synchronize];
    } else {
        // Store the data
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@"" forKey:@"account"];
        [defaults setObject:@"" forKey:@"password"];
        [defaults setObject:@"" forKey:@"serverName"];
        [defaults setObject:@"" forKey:@"serverAddress"];
        [defaults synchronize];
    }
    
    AppDelegate *app = [self appDelegate];
    app.authenticateDelegate = self;
    
    [[self appDelegate] connect:account password:password serverName:serverName server:serverAddress];
    
}


- (void) setLoginFinish:(id)target callback:(SEL)selector
{
    m_target_login = target;
    m_selector_login = selector;
}

//取得当前程序的委托
-(AppDelegate *)appDelegate{
    
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
}

//取得当前的XMPPStream
-(XMPPStream *)xmppStream{
    
    return [[self appDelegate] xmppStream];
}

- (void)didAuthenticate:(XMPPStream *)sender {
//    [self.navigationController popViewControllerAnimated:YES];
    [m_target_login performSelector:m_selector_login withObject:sender];
  
}

- (void)didNotAuthenticate:(NSXMLElement *)authResponse {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:[authResponse description]
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
    [alert show];

}

@end
