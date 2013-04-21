//
//  Player.h
//  PokerGames
//
//  Created by Fabiano Rosa on 16/04/13.
//  Copyright (c) 2013 Fabiano Rosa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Player : NSObject

@property (nonatomic, retain) NSNumber * idPlayer;
@property (nonatomic, retain) NSString * apelido;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * nome;
@property (nonatomic, retain) NSString * urlFoto;
@property (nonatomic, retain) NSString * status;

- (id)initWithAttributes:(NSDictionary *)attributes;

+ (void)efetuaLoginPlayerWithBlock:(NSString *)user
                             passw:(NSString *)passw
                             constructingBodyWithBlock:(void (^)(Player *player, NSError *error))block;

@end
