//
//  XMPPPub.h
//  MapDots
//
//  Created by chenwei on 13-9-16.
//  Copyright (c) 2013年 chenwei. All rights reserved.
//

#import "XMPPModule.h"
#import "XMPPMessage.h"
#import "XMPPIQ.h"
#import "XMPPIDTracker.h"

@protocol XMPPPubDelegate;

static NSString *const XMPPPubSub = @"http://jabber.org/protocol/pubsub";
static NSString *const XMPPGeoloc = @"http://jabber.org/protocol/geoloc";
static NSString *const XMPPPubSubEvent = @"http://jabber.org/protocol/pubsub#event";

@interface XMPPPub : XMPPModule
{
    /*
    Inherited from XMPPModule:
     
    XMPPStream *xmppStream;
     
     dispatch_queue_t moduleQueue;
     id multicastDelegate;
    */
    
    // Horizontal GPS error in meters
    double accuracy;
    
    // The nation where the user is located
    NSString *country;
    
    // A locality within the administrative region, such as a town or city
    NSString *locality;
    
    CLLocationCoordinate2D coordinate;

	XMPPIDTracker *responseTracker;
}

/*
    Inherited from XMPPModule:
 
- (BOOL)activate:(XMPPStream *)xmppStream;
- (void)deactivate;
 
@property (readonly) XMPPStream *xmppStream;
 
- (void)addDelegate:(id)delegate delegateQueue:
    (dispatch_queue_t)delegateQueue;
- (void)removeDelegate:(id)delegate delegateQueue;
    (dispatch_queue_t)delegateQueue;
- (void)removeDelegate:(id)delegate;
 
- (NSString *)moduleName;
 
*/

@end

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@protocol XMPPPubDelegate <NSObject>
@optional

// Subscriber receives event with payload
- (void)xmppPub:(XMPPPub *)sender didReceiveEvent:(XMPPMessage *)message;

// User stops publishing geolocation information
- (void)xmppPub:(XMPPPub *)sender didStopReceiveEvent:(XMPPMessage *)message;

@end
