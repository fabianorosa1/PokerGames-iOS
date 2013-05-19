//
//  RankingCampeonato.h
//  PokerGames
//
//  Created by Fabiano Rosa on 22/04/13.
//  Copyright (c) 2013 Fabiano Rosa. All rights reserved.
//

#import "Ranking.h"

@interface Ranking : NSObject

@property (nonatomic, retain) NSNumber * idJogador;
@property (nonatomic, retain) NSString * nome;
@property (nonatomic, retain) NSString * apelido;
@property (nonatomic, retain) NSString * pontos;
@property (nonatomic, retain) NSString * foto;
@property (nonatomic, retain) NSString * posicao;
@property (nonatomic, retain) NSNumber * idLiga;

- (id)initWithAttributes:(NSDictionary *)attributes;

@end
