//
//  XMPPPub.m
//  MapDots
//
//  Created by siteview_mac on 13-9-16.
//  Copyright (c) 2013年 drogranflow. All rights reserved.
//

#import "XMPPPub.h"
#import "XMPP.h"
#import "XMPPLogging.h"
#import "XMPPFramework.h"
#import "DDList.h"

#if ! __has_feature(objc_arc)
#warning This file must be complied with ARC. Use -fobjc-arc flag (or converst project to ARC).
#endif

// Log levels: off, error, warn, info, verbose
// Log flags: trace
#if DEBUG
    static const int xmppLogLevel = XMPP_LOG_LEVEL_WARN;    // XMPP_LOG_FLAG_TRACE;
#else
    static const int xmppLogLevel = XMPP_LOG_LEVEL_WARN;
#endif

@implementation XMPPPub

- (id)init
{
    return [self initWithDispatchQueue:NULL];
}

- (id)initWithDispatchQueue:(dispatch_queue_t)queue
{
    if ((self = [super initWithDispatchQueue:queue])) {
        ;
    }
    return self;
}

- (BOOL)activate:(XMPPStream *)aXmppStream
{
    XMPPLogTrace();
    
    if ([super activate:aXmppStream]) {
        XMPPLogVerbose(@"%@: Activated", THIS_FILE);
        
		responseTracker = [[XMPPIDTracker alloc] initWithDispatchQueue:moduleQueue];

        return YES;
    }
    
    return NO;
}

- (void)deactivate
{
    XMPPLogTrace();
    
	dispatch_block_t block = ^{ @autoreleasepool {
		
		[responseTracker removeAllIDs];
		responseTracker = nil;
		
	}};
	
	if (dispatch_get_specific(moduleQueueTag))
		block();
	else
		dispatch_sync(moduleQueue, block);
	
    [super deactivate];
}

- (double)accuracy
{
    __block double result = 0;
    
    dispatch_block_t block = ^{
        result = accuracy;
    };
    
    if (dispatch_get_specific(moduleQueueTag)) {
        block();
    } else {
        dispatch_sync(moduleQueue, block);
    }
    
    return result;
}

- (void)setAccuracy:(double)newAccuracy
{
    dispatch_block_t block = ^{
        accuracy = newAccuracy;
    };
    
    if (dispatch_get_specific(moduleQueueTag)) {
        block();
    } else {
        dispatch_sync(moduleQueue, block);
    }
}

- (NSString *)country
{
    __block NSString *result = 0;
    
    dispatch_block_t block = ^{
        result = country;
    };
    
    if (dispatch_get_specific(moduleQueueTag)) {
        block();
    } else {
        dispatch_sync(moduleQueue, block);
    }
    
    return result;
    
}

- (void)setCountry:(NSString *)newCountry
{
    dispatch_block_t block = ^{
        country = newCountry;
    };
    
    if (dispatch_get_specific(moduleQueueTag)) {
        block();
    } else {
        dispatch_sync(moduleQueue, block);
    }
}

- (NSString *)locality
{
    __block NSString *result = 0;
    
    dispatch_block_t block = ^{
        result = locality;
    };
    
    if (dispatch_get_specific(moduleQueueTag)) {
        block();
    } else {
        dispatch_sync(moduleQueue, block);
    }
    
    return result;
    
}

- (void)setLocality:(NSString *)newLocality
{
    dispatch_block_t block = ^{
        locality = newLocality;
    };
    
    if (dispatch_get_specific(moduleQueueTag)) {
        block();
    } else {
        dispatch_sync(moduleQueue, block);
    }
}


- (CLLocationCoordinate2D)coordinate
{
    __block CLLocationCoordinate2D result;
    
    dispatch_block_t block = ^{
        result = coordinate;
    };
    
    if (dispatch_get_specific(moduleQueueTag)) {
        block();
    } else {
        dispatch_sync(moduleQueue, block);
    }
    
    return result;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
    dispatch_block_t block = ^{
        coordinate = newCoordinate;
    };
    
    if (dispatch_get_specific(moduleQueueTag)) {
        block();
    } else {
        dispatch_sync(moduleQueue, block);
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark User Location
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)pubsubUserLocation
{
    // This is a public method, so it may be invoked on any thread/queue.
    
    /*
    4.1 Entity publishes location via PEP
    
    Example 1. Entity publishes location
    
    <iq type='set' from='portia@merchantofvenice.lit/pda' id='publish1'>
        <pubsub xmlns='http://jabber.org/protocol/pubsub'>
            <publish node='http://jabber.org/protocol/geoloc'>
                <item>
                    <geoloc xmlns='http://jabber.org/protocol/geoloc' xml:lang='en'>
                        <accuracy>20</accuracy>
                        <country>Italy</country>
                        <lat>45.44</lat>
                        <locality>Venice</locality>
                        <lon>12.33</lon>
                    </geoloc>
                </item>
            </publish>
        </pubsub>
    </iq>
    */
    
    NSString *accuracyStr = [NSString stringWithFormat:@"%lf", accuracy];
    NSXMLElement *accuracyNode = [NSXMLElement elementWithName:@"accuracy" stringValue:accuracyStr];
    
    NSXMLElement *countryNode = [NSXMLElement elementWithName:@"country" stringValue:country];
    
    NSXMLElement *localityNode = [NSXMLElement elementWithName:@"locality" stringValue:locality];
    
    NSString *latStr = [NSString stringWithFormat:@"%lf", coordinate.latitude];
    NSXMLElement *latNode = [NSXMLElement elementWithName:@"lat" stringValue:latStr];
    NSString *lonStr = [NSString stringWithFormat:@"%lf", coordinate.longitude];
    NSXMLElement *lonNode = [NSXMLElement elementWithName:@"lon" stringValue:lonStr];
    
    NSXMLElement *geoloc = [NSXMLElement elementWithName:@"geoloc" xmlns:XMPPGeoloc];
    [geoloc addAttributeWithName:@"xml:lang" stringValue:@"en"];
    [geoloc addChild:accuracyNode];
    [geoloc addChild:countryNode];
    [geoloc addChild:latNode];
    [geoloc addChild:localityNode];
    [geoloc addChild:lonNode];

    NSXMLElement *item = [NSXMLElement elementWithName:@"item"];
    [item addChild:geoloc];

    NSXMLElement *pubsub = [NSXMLElement elementWithName:@"pubsub" xmlns:XMPPPubSub];
    [pubsub addChild:item];
    
    XMPPIQ *iq = [XMPPIQ iqWithType:@"set"];
    [iq addChild:pubsub];
    
    [xmppStream sendElement:iq];
}

- (void)stopReceiveEvent
{
    /*
     Example 3. User stops publishing geolocation information
     
     <iq from='portia@merchantofvenice.lit/pda' id='publish2' type='set'>
     <pubsub xmlns='http://jabber.org/protocol/pubsub'>
     <publish node='http://jabber.org/protocol/geoloc'>
     <item>
     <geoloc xmlns='http://jabber.org/protocol/geoloc'/>
     </item>
     </publish>
     </pubsub>
     </iq>
     */
    
    NSXMLElement *geoloc = [NSXMLElement elementWithName:@"geoloc" xmlns:XMPPGeoloc];
    
    NSXMLElement *item = [NSXMLElement elementWithName:@"item"];
    [item addChild:geoloc];
    
    NSXMLElement *pubsub = [NSXMLElement elementWithName:@"pubsub" xmlns:XMPPPubSub];
    [pubsub addChild:item];
    
    NSString *iqID = [xmppStream generateUUID];

    XMPPIQ *iq = [XMPPIQ iqWithType:@"set" elementID:iqID child:pubsub];
    
    [xmppStream sendElement:iq];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPStream Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    // This method is invoked on the moduleQueue.
    
    XMPPLogTrace();
    
    /*
    Example 2. Subscriber receives event with payload
    
     <message from='portia@merchantofvenice.lit' to='bassanio@merchantofvenice.lit'>
        <event xmlns='http://jabber.org/protocol/pubsub#event'>
            <items node='http://jabber.org/protocol/geoloc'>
                <item id='d81a52b8-0f9c-11dc-9bc8-001143d5d5db'>
                    <geoloc xmlns='http://jabber.org/protocol/geoloc' xml:lang='en'>
                        <accuracy>20</accuracy>
                        <country>Italy</country>
                        <lat>45.44</lat>
                        <locality>Venice</locality>
                        <lon>12.33</lon>
                    </geoloc>
                </item>
            </items>
        </event>
     </message>
     
     Example 4. Subscriber receives empty event
     
     <message from='portia@merchantofvenice.lit' to='bassanio@merchantofvenice.lit'>
         <event xmlns='http://jabber.org/protocol/pubsub#event'>
             <items node='http://jabber.org/protocol/geoloc'>
                 <item id='d81a52b8-0f9c-11dc-9bc8-001143d5d5db'>
                    <geoloc xmlns='http://jabber.org/protocol/geoloc'/>
                 </item>
             </items>
         </event>
     </message>
    */
    
    NSXMLElement *event = [message elementForName:@"event" xmlns:XMPPPubSubEvent];
    if (event) {
        NSXMLElement *items = [event elementForName:@"items"];
        if (items) {
            NSString *node = [event attributeStringValueForName:@"node"];
            if ([node isEqualToString:XMPPGeoloc]) {
                NSXMLElement *item = [items elementForName:@"item"];
                if (item) {
                    NSXMLElement *geoloc = [item elementForName:@"geoloc" xmlns:XMPPGeoloc];
                    
                    // TODO: xml:lang
                    if (geoloc) {
                        if ([geoloc childCount] == 0) {
                            [multicastDelegate xmppPub:self didStopReceiveEvent:message];

                        } else {
                            NSXMLElement *accuracyNode = [geoloc elementForName:@"accuracy"];
                            if (accuracyNode) {
                                accuracy = [accuracyNode stringValueAsInt];
                            }
                            NSXMLElement *countryNode = [geoloc elementForName:@"country"];
                            if (countryNode) {
                                country = [countryNode stringValue];
                            }
                            
                            NSXMLElement *localityNode = [geoloc elementForName:@"locality"];
                            if (localityNode) {
                                locality = [localityNode stringValue];
                            }
                            
                            NSXMLElement *latNode = [geoloc elementForName:@"lat"];
                            if (latNode) {
                                coordinate.latitude = [latNode stringValueAsFloat];
                            }
                            NSXMLElement *lonNode = [geoloc elementForName:@"lon"];
                            if (lonNode) {
                                coordinate.longitude = [lonNode stringValueAsFloat];
                            }
                            
                            [multicastDelegate xmppPub:self didReceiveEvent:message];
                        }
                    }

                }
            }
        }
        return YES;
    }
    
    return NO;
}

@end
