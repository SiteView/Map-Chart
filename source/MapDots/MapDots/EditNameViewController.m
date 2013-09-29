//
//  EditNameViewController.m
//  ChatTest
//
//  Created by siteview_mac on 13-8-6.
//  Copyright (c) 2013年 siteview_mac. All rights reserved.
//

#import "EditNameViewController.h"
#import "AppDelegate.h"
#import "UserProperty.h"

@interface EditNameViewController ()

@end

@implementation EditNameViewController
{
    UITextField *text_;
    UIImageView *image_;
    UIActionSheet *actionSheet_;
}

@synthesize nickName;
@synthesize account;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    float controlTop = 0;
    float navigationTop = 0;
    float bottomHeight = 0;
    if ([self appDelegate].isiOS7) {
        //if ([self appDelegate].isiPAD)
        {
            controlTop = STATUS_BAR_HEIGHT;
            navigationTop = NAVIGATION_BAR_HEIGHT;
            bottomHeight = TAB_BAR_HEIGHT;
        }
    }
    
    CGRect rect = CGRectMake(0, controlTop, self.view.bounds.size.width, self.view.bounds.size.height - controlTop);

    UIControl *view_ = [[UIControl alloc] initWithFrame:rect];
    [view_ addTarget:self action:@selector(backgroundTap:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:view_];

    view_.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    
    image_ = [[UIImageView alloc] initWithFrame:CGRectMake(3, controlTop + navigationTop + 3, 50, 50)];
    [self configurePhoto:image_];
    image_.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userClicked:)];
    [image_ addGestureRecognizer:singleTap];
    [view_ addSubview:image_];

    actionSheet_ = [[UIActionSheet alloc] initWithTitle:nil
                                               delegate:self
                                      cancelButtonTitle:@"Cancel"
                                 destructiveButtonTitle:@"Photo"
                                      otherButtonTitles:@"Choose from album", nil];
    
    actionSheet_.actionSheetStyle = UIActionSheetStyleDefault;
    actionSheet_.destructiveButtonIndex = 3;

    text_ = [[UITextField alloc] initWithFrame:CGRectMake(3, controlTop + navigationTop + 63, self.view.bounds.size.width - controlTop - navigationTop, 30)];
    text_.borderStyle = UITextBorderStyleRoundedRect;
    text_.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    text_.delegate = self;
    text_.returnKeyType = UIReturnKeyDone;
    text_.clearButtonMode = UITextFieldViewModeWhileEditing;
    text_.autocapitalizationType = UITextAutocapitalizationTypeNone;
    text_.keyboardType = UIKeyboardTypeEmailAddress;
    
    text_.text = nickName;
    
    [view_ addSubview:text_];
    
    UILabel *tint = [[UILabel alloc] initWithFrame:CGRectMake(10, controlTop + navigationTop + 93, self.view.bounds.size.width, 30)];
    tint.text = @"给您自己取一个好听的名字作为昵称";
    [view_ addSubview:tint];
}


- (void)configurePhoto:(UIImageView *)imagePhoto
{
    // [UserProperty sharedInstance].nickName
    UIImage *image = nil;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *fileName = [NSString stringWithFormat:@"%@/%@.jpg", documentsDirectory, [UserProperty sharedInstance].account];
    
    BOOL isDir = NO;
    if ([fileManager fileExistsAtPath:fileName isDirectory:&isDir]) {
        if (!isDir) {
            image = [UIImage imageWithContentsOfFile:fileName];
        }
    }
    
	if (image != nil)
	{
		imagePhoto.image = image;
	}
	else
	{
        imagePhoto.image = [UIImage imageNamed:@"defaultPerson"];
	}
}

-(AppDelegate *)appDelegate
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
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

- (void)userClicked:(UITapGestureRecognizer *)sender
{
    [actionSheet_ showInView:[UIApplication sharedApplication].keyWindow];

}


#pragma make - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
        {
            // Photo
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                NSArray *tempMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:picker.sourceType];
                picker.mediaTypes = tempMediaTypes;
                picker.delegate = self;
                picker.allowsEditing = YES;
            }
            
            [self presentModalViewController:picker animated:YES];
        }
            break;
        case 1:
        {
            // Choose from album
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            imagePicker.delegate = self;
            imagePicker.allowsEditing = YES;
            [self presentModalViewController:imagePicker animated:YES];
            
        }
            break;
        default:
            break;
    }
}

#pragma make - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    if ([mediaType isEqualToString:@"public.image"]) {
        UIImage *image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
        
        NSString *imageFile = [NSString stringWithFormat:@"%@/%@.jpg", documentsDirectory, account];
        success = [fileManager fileExistsAtPath:imageFile];
        if (success) {
            success = [fileManager removeItemAtPath:imageFile error:&error];
        }
        
        image_.image = image;
        
        [UIImageJPEGRepresentation(image, 0.5) writeToFile:imageFile atomically:YES];
    }
    
    [picker dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissModalViewControllerAnimated:YES];
}
@end
