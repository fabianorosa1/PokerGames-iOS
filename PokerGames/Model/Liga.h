//
//  Liga.h
//  PokerGames
//
//  Created by Fabiano Rosa on 16/04/13.
//  Copyright (c) 2013 Fabiano Rosa. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Campeonato;
@class Jogador;

@interface Liga : NSObject

@property (nonatomic, retain) NSNumber * idLiga;
@property (nonatomic, retain) NSString * apelido;
@property (nonatomic, retain) NSString * nome;
@property (nonatomic, retain) Campeonato * campeonato;

- (id)initWithAttributes:(NSDictionary *)attributes;

+ (void)buscaLigasPlayerWithBlock:(NSNumber *)idPlayer
                             constructingBodyWithBlock:(void (^)(NSArray *ligas, NSError *error))block;

@end
