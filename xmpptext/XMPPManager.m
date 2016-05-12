//
//  XMPPManager.m
//  xmpptext
//
//  Created by eall_linger on 16/4/26.
//  Copyright © 2016年 eall_linger. All rights reserved.
//

#import "XMPPManager.h"

#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif
@implementation XMPPManager
{
    XMPPStream *xmppStream;
    XMPPReconnect *xmppReconnect;

    NSString *password;
    
    BOOL isXmppConnected;
}


+ (XMPPManager *)sharedInstance
{
    static XMPPManager * _sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[XMPPManager alloc]init];
        [_sharedInstance setupStream];
        [DDLog addLogger:[DDTTYLogger sharedInstance] withLogLevel:XMPP_LOG_FLAG_SEND_RECV];

    });
    return _sharedInstance;
}

- (void)setupStream
{
    NSAssert(xmppStream == nil, @"Method setupStream invoked multiple times");
 
    xmppStream = [[XMPPStream alloc] init];
    
#if !TARGET_IPHONE_SIMULATOR
    {
        xmppStream.enableBackgroundingOnSocket = YES;
    }
#endif
  
    xmppReconnect = [[XMPPReconnect alloc] init];
 
    // Activate xmpp modules
    
    [xmppReconnect         activate:xmppStream];
    // Add ourself as a delegate to anything we may be interested in
    
    [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
}

- (void)teardownStream
{
    [xmppStream removeDelegate:self];
    
    [xmppReconnect         deactivate];

    
    [xmppStream disconnect];
    
    xmppStream = nil;
    xmppReconnect = nil;

}
#pragma mark 连接
- (BOOL)connect
{
    
    if (![xmppStream isDisconnected]) {
        return YES;
    }
    
    NSString *myJID = @"20361919_970@im.eallcn.com";
    NSString *myPassword = @"pass_20361919_970";
    
    
    if (myJID == nil || myPassword == nil) {
        return NO;
    }
    
    [xmppStream setMyJID:[XMPPJID jidWithString:myJID]];
    password = myPassword;
    
    NSError *error = nil;
    if (![xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error])
    {
       
        
        DDLogError(@"Error connecting: %@", error);
        
        return NO;
    }
    
    return YES;
}

- (void)disconnect
{
    [self goOffline];
    [xmppStream disconnect];
}
#pragma mark 登录
- (void)goOnline
{
    XMPPPresence *presence = [XMPPPresence presence]; // type="available" is implicit
    
    NSString *domain = [xmppStream.myJID domain];
    
    //Google set their presence priority to 24, so we do the same to be compatible.
    
    if([domain isEqualToString:@"gmail.com"]
       || [domain isEqualToString:@"gtalk.com"]
       || [domain isEqualToString:@"talk.google.com"])
    {
        NSXMLElement *priority = [NSXMLElement elementWithName:@"priority" stringValue:@"24"];
        [presence addChild:priority];
    }
    
    [ xmppStream sendElement:presence];

}

- (void)goOffline
{
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    
    [ xmppStream sendElement:presence];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Connect/disconnect
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)sendMsg:(NSString *)message
{
    NSXMLElement *body=[NSXMLElement elementWithName:@"body"];
    [body setStringValue:@"你好呀"];
    NSXMLElement *mes=[NSXMLElement elementWithName:@"message"];
    [mes addAttributeWithName:@"type" stringValue:@"chat"];
    NSString *to=@"c_19857289_13800000000@im.eallcn.com";
    [mes addAttributeWithName:@"to" stringValue:to];
    [mes addChild:body];
    NSLog(@"%@",mes);
    [xmppStream sendElement:mes];
}

- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    isXmppConnected = YES;
    
    NSError *error = nil;
    
    if (![xmppStream authenticateWithPassword:password error:&error])
    {
        DDLogError(@"Error authenticating: %@", error);
    }
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    [self goOnline];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}


#pragma mark 接收信息
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    
    if ([message isChatMessageWithBody])
    {
 
  
        
        NSString *body = [[message elementForName:@"body"] stringValue];
        NSString *displayName = @"";
        
        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
        {
                    }
        else
        {
            // We are not active, so use a local notification instead
            UILocalNotification *localNotification = [[UILocalNotification alloc] init];
            localNotification.alertAction = @"Ok";
            localNotification.alertBody = [NSString stringWithFormat:@"From: %@\n\n%@",displayName,body];
            
            [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
        }
    }
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
//    断网 就会调用 自动重新连接
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    if (!isXmppConnected)
    {
        DDLogError(@"Unable to connect to server. Check xmppStream.hostName");
    }
}
 


@end
