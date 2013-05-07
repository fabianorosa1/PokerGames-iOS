//
//  Jogador.h
//  PokerGames
//
//  Created by Fabiano Rosa on 22/04/13.
//  Copyright (c) 2013 Fabiano Rosa. All rights reserved.
//

#import "Liga.h"

@interface Jogador : NSObject

@property (nonatomic, retain) NSString * apelido;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSNumber * idJogador;
@property (nonatomic, retain) NSString * nome;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * foto;
@property (nonatomic, retain) NSString * fone;
@property (nonatomic, retain) NSString * imgClas;
// relacionamento
@property (nonatomic, retain) NSNumber * idLiga;
@property (nonatomic, retain) Liga *liga;

- (id)initWithAttributes:(NSDictionary *)attributes;

@end
