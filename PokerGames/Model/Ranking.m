//
//  RankingCampeonato.m
//  PokerGames
//
//  Created by Fabiano Rosa on 16/04/13.
//  Copyright (c) 2013 Fabiano Rosa. All rights reserved.
//

#import "Ranking.h"

@implementation Ranking

- (id)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }
        
    self.idJogador = [attributes valueForKeyPath:@"IdJogador"];
    self.nome = [attributes valueForKeyPath:@"Nome"];
    self.apelido = [attributes valueForKeyPath:@"Apelido"];
    self.pontos = [attributes valueForKeyPath:@"Pontos"];
    self.foto = [attributes valueForKeyPath:@"Foto"];
    self.posicao = [attributes valueForKeyPath:@"Posicao"];
    self.idLiga = [attributes valueForKeyPath:@"IdLiga"];
    
    return self;
}

@end
