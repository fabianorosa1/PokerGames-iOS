//
//  Campeonato.h
//  PokerGames
//
//  Created by Fabiano Rosa on 16/04/13.
//  Copyright (c) 2013 Fabiano Rosa. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Liga;

@interface Campeonato : NSObject

@property (nonatomic, retain) NSNumber * idCampeonato;
@property (nonatomic, retain) NSString * apelido;
@property (nonatomic, retain) NSString * nome;

- (id)initWithAttributes:(NSDictionary *)attributes;

+ (void)buscaCampeonatosLigaWithBlock:(NSNumber *)idLiga
                             constructingBodyWithBlock:(void (^)(NSArray *campeonatos, NSError *error))block;

@end
