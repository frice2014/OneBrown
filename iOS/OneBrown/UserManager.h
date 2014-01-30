//
//  UserManager.h
//  OneBrown
//
//  Created by Valentin Perez on 1/8/14.
//  Copyright (c) 2014 Benjamin Murphy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserManager : NSObject
{
    NSString *userName;
    UIImage *userImage;
    NSMutableDictionary *userNetworks;
    
    NSString *stalkedUserName;
    UIImage *stalkedUserImage;
    NSMutableArray *stalkedUserNetworks;
    NSMutableArray *socialNetworks;
    NSMutableDictionary *socialNetworkImages;
    
}

@property (nonatomic, retain) NSString *userName;
@property (nonatomic, retain) UIImage *userImage;
@property (nonatomic, retain) NSMutableDictionary *userNetworks;

@property (nonatomic, retain) NSString *stalkedUserName;
@property (nonatomic, retain) UIImage *stalkedUserImage;
@property (nonatomic, retain) NSMutableArray *stalkedUserNetworks;

@property (nonatomic, retain) NSMutableArray *socialNetworks;
@property (nonatomic, retain) NSMutableDictionary *socialNetworkImages;


+ (id)sharedUserManager;
+ (NSString *) socialNetworkForIndex: (int) index;


@end