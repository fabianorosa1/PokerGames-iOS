//
//  Jogador.m
//  PokerGames
//
//  Created by Fabiano Rosa on 16/04/13.
//  Copyright (c) 2013 Fabiano Rosa. All rights reserved.
//

#import "Jogador.h"

@implementation Jogador

- (id)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.idJogador = [attributes valueForKeyPath:@"IdJogador"];
    self.apelido = [attributes valueForKeyPath:@"Apelido"];
    self.email = [attributes valueForKeyPath:@"Email"];
    self.nome = [attributes valueForKeyPath:@"Nome"];
    self.foto = [attributes valueForKeyPath:@"Foto"];
    self.status = [attributes valueForKeyPath:@"Status"];
    self.imgClas = [attributes valueForKeyPath:@"ImgClas"];
    self.fone = [attributes valueForKeyPath:@"Fone"];
    
    return self;
}

@end
