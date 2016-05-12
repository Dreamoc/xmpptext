//
//  XMPPManager.h
//  xmpptext
//
//  Created by eall_linger on 16/4/26.
//  Copyright © 2016年 eall_linger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPP.h"
#import "XMPPLogging.h"
#import "XMPPReconnect.h"
#import <UIKit/UIKit.h>
#import "DDLog.h"
#import "DDTTYLogger.h"
#import <CFNetwork/CFNetwork.h>


@interface XMPPManager : NSObject<XMPPStreamDelegate>

+ (XMPPManager *)sharedInstance;
- (void)setupStream;
- (void)teardownStream;
- (void)sendMsg:(NSString *)message;
- (BOOL)connect;
- (void)goOnline;
- (void)goOffline;


@end
