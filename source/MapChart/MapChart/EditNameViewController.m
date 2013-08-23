//
//  EditNameViewController.m
//  ChatTest
//
//  Created by siteview_mac on 13-8-6.
//  Copyright (c) 2013年 siteview_mac. All rights reserved.
//

#import "EditNameViewController.h"

@interface EditNameViewController ()

@end

@implementation EditNameViewController
{
    UITextField *text_;
}

@synthesize nickName;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    UIControl *view_ = [[UIControl alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    [view_ addTarget:self action:@selector(backgroundTap:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:view_];

    self.view.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    
    text_ = [[UITextField alloc] initWithFrame:CGRectMake(3, 3, self.view.bounds.size.width - 6, 30)];
    text_.borderStyle = UITextBorderStyleRoundedRect;
    text_.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    text_.delegate = self;
    text_.returnKeyType = UIReturnKeyDone;
    text_.clearButtonMode = UITextFieldViewModeWhileEditing;
    text_.autocapitalizationType = UITextAutocapitalizationTypeNone;
    text_.keyboardType = UIKeyboardTypeEmailAddress;
    
    text_.text = nickName;
    
    [self.view addSubview:text_];
    
    UILabel *tint = [[UILabel alloc] initWithFrame:CGRectMake(10, 33, self.view.bounds.size.width, 30)];
    tint.text = @"给您自己取一个好听的名字作为昵称";
    [self.view addSubview:tint];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)backgroundTap:(id)sender {
    [text_ resignFirstResponder];
}

- (void)setEditFinish:(id)target callback:(SEL)selector
{
    m_target_edit = target;
    m_selector_edit = selector;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    nickName = text_.text;
    
    [m_target_edit performSelector:m_selector_edit withObject:text_.text];
    [text_ resignFirstResponder];
    
    return YES;
}
@end
