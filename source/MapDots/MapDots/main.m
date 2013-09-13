//
//  main.m
//  MapChart
//
//  Created by siteview_mac on 13-8-20.
//  Copyright (c) 2013年 dragonflow. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"

typedef int (*PYStdWrite)(void *, const char *, int);
static PYStdWrite _oldStdWrite;

int __pyStderrWrite(void *inFD, const char *buffer, int size)
{
    if (strncmp(buffer, "AssertMacros:", 13) == 0) {
        return 0;
    }
    
    return _oldStdWrite(inFD, buffer, size);
}

int main(int argc, char *argv[])
{
    // fix: xcode5 ios7beta产生如下log：
    // ～AssertMacros: queueEntry, file: /SourceCache/IOKitUser_Sim/IOKitUser-920.1.11/hid.subproj/IOHIDEven
    // 虽然程序能运行，但是看起来很不爽～
    _oldStdWrite = stderr->_write;
    stderr->_write = __pyStderrWrite;
    
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
