//
//  Liga.h
//  PokerGames
//
//  Created by Fabiano Rosa on 16/04/13.
//  Copyright (c) 2013 Fabiano Rosa. All rights reserved.
//

#import "Campeonato.h"

@interface Liga : NSObject

@property (nonatomic, retain) NSNumber * idLiga;
@property (nonatomic, retain) NSString * apelido;
@property (nonatomic, retain) NSString * nome;
// relacionamento
@property (nonatomic, retain) NSNumber * idCampeonato;
@property (nonatomic, retain) Campeonato * campeonato;

- (id)initWithAttributes:(NSDictionary *)attributes;

@end
