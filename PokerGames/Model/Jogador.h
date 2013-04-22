//
//  Player.h
//  PokerGames
//
//  Created by Fabiano Rosa on 16/04/13.
//  Copyright (c) 2013 Fabiano Rosa. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Liga;

@interface Jogador : NSObject

@property (nonatomic, retain) NSNumber * idPlayer;
@property (nonatomic, retain) NSString * apelido;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * nome;
@property (nonatomic, retain) NSString * urlFoto;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) Liga * liga;

- (id)initWithAttributes:(NSDictionary *)attributes;

+ (void)efetuaLoginPlayerWithBlock:(NSString *)user
                             passw:(NSString *)passw
                             constructingBodyWithBlock:(void (^)(Jogador *player, NSError *error))block;

@end
