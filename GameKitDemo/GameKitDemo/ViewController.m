//
//  ViewController.m
//  GameKitDemo
//
//  Created by Chen Hao 陈浩 on 16/2/22.
//  Copyright © 2016年 Chen Hao 陈浩. All rights reserved.
//

#import "ViewController.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>

#define SERVICETYPE @"chenhao-chat"

@interface ViewController ()<MCNearbyServiceAdvertiserDelegate,
                                MCNearbyServiceBrowserDelegate,
                                    MCSessionDelegate,
                                        MCBrowserViewControllerDelegate,
                                            MCAdvertiserAssistantDelegate>

@property (nonatomic, strong) MCPeerID *peerID;

@property (nonatomic, strong) MCNearbyServiceAdvertiser *advertiser;

@property (nonatomic, strong) MCNearbyServiceBrowser *browser;

@property (nonatomic, strong) MCSession *session;

@property (nonatomic, strong) MCBrowserViewController *browserViewController;

@property (nonatomic, strong) MCAdvertiserAssistant *assistant;

@property (weak, nonatomic) IBOutlet UITextField *messageTextField;


@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self initPeerID];
    
    [self initAdvertiser];
    
    [self initBrowser];
    
    [self initSession];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - initConnectClass -

- (void)initPeerID
{
    MCPeerID *peerID = [[MCPeerID alloc]initWithDisplayName:@"haozi"];
    self.peerID = peerID;
}

- (void)initAdvertiser
{
    NSDictionary *dic = @{
                          @"key1":@"chen",
                          @"key2":@"hao"
                          };
    
    MCNearbyServiceAdvertiser *advertiser = [[MCNearbyServiceAdvertiser alloc]initWithPeer:self.peerID
                                                                             discoveryInfo:dic
                                                                               serviceType:SERVICETYPE];
    self.advertiser = advertiser;
    self.advertiser.delegate = self;
}

- (void)initBrowser
{
    MCNearbyServiceBrowser *browser = [[MCNearbyServiceBrowser alloc]initWithPeer:self.peerID
                                                                      serviceType:SERVICETYPE];
    self.browser = browser;
    self.browser.delegate = self;
}

- (void)initSession
{
    MCSession *session = [[MCSession alloc]initWithPeer:self.peerID];
    self.session = session;
    self.session.delegate = self;
}

#pragma mark - xib Action -

- (IBAction)broadcastAction:(id)sender
{
    [self.advertiser startAdvertisingPeer];
    
//    NSDictionary *dic = @{
//                          @"key1":@"chen",
//                          @"key2":@"hao"
//                          };
//    
//    
//    self.assistant = [[MCAdvertiserAssistant alloc]initWithServiceType:SERVICETYPE discoveryInfo:dic session:self.session];
//    self.assistant.delegate = self;
//    [self.assistant start];
}

- (IBAction)browserAction:(id)sender
{
//    [self.browser startBrowsingForPeers];
    
    
    self.browserViewController = [[MCBrowserViewController alloc]initWithBrowser:self.browser session:self.session];
    self.browserViewController.delegate = self;
    [self presentViewController:self.browserViewController animated:YES completion:nil];
}
- (IBAction)sendDataAction:(id)sender
{
    NSError *error;
    
    NSData *data = [self.messageTextField.text dataUsingEncoding:NSUTF8StringEncoding];
    
    BOOL sendSuccess = [self.session sendData:data
                                      toPeers:self.session.connectedPeers
                                     withMode:MCSessionSendDataUnreliable
                                        error:&error];
    if (!sendSuccess)
    {
        NSLog(@"err : %@",error);
    }
    
}

#pragma mark - MCNearbyServiceAdvertiserDelegate -

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser
didReceiveInvitationFromPeer:(MCPeerID *)peerID
       withContext:(NSData *)context
 invitationHandler:(void (^)(BOOL, MCSession * _Nonnull))invitationHandler
{
    NSLog(@"adver : %@, peerID : %@, context : %@", advertiser, peerID, context);
    invitationHandler(YES, self.session);
}

#pragma mark - MCNearbyServiceBrowserDelegate -

- (void)browser:(MCNearbyServiceBrowser *)browser
      foundPeer:(MCPeerID *)peerID
withDiscoveryInfo:(NSDictionary<NSString *,NSString *> *)info
{
    NSLog(@"browser : %@, peerID : %@, info : %@ ",browser,peerID.displayName,info);
    
    NSData *data = [@"jiawoyiqiwanyouxi" dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.browser invitePeer:peerID toSession:self.session withContext:data timeout:10];
}



#pragma mark - MCSessionDelegate -

- (void)session:(MCSession *)session
           peer:(MCPeerID *)peerID
 didChangeState:(MCSessionState)state
{
    NSLog(@"session : %@, peerID : %@, state : %ld",session, peerID, (long)state);
}

-(void)session:(MCSession *)session
didReceiveCertificate:(NSArray *)certificate
      fromPeer:(MCPeerID *)peerID
certificateHandler:(void (^)(BOOL))certificateHandler
{
    NSLog(@"session : %@, certificate : %@, peerID : %@",session, certificate, peerID);
    
    certificateHandler(YES);
}

-(void)session:(MCSession *)session
didReceiveData:(NSData *)data
      fromPeer:(MCPeerID *)peerID
{
    NSLog(@"session : %@, peerID : %@, data : %@",session, peerID, data);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSString * message = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"收到信息" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        
        [alert show];
    });
    
}


#pragma mark - MCBrowserViewControllerDelegate -

- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController
{
    [self.browserViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController
{
     [self.browserViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - MCAdvertiserAssistantDelegate -

-(void)advertiserAssistantWillPresentInvitation:(MCAdvertiserAssistant *)advertiserAssistant
{
    
}

-(void)advertiserAssistantDidDismissInvitation:(MCAdvertiserAssistant *)advertiserAssistant
{
    
}

@end
