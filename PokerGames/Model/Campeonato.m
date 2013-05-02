//
//  Campeonato.m
//  PokerGames
//
//  Created by Fabiano Rosa on 16/04/13.
//  Copyright (c) 2013 Fabiano Rosa. All rights reserved.
//

#import "Campeonato.h"

@implementation Campeonato

- (id)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.idCampeonato = [attributes valueForKeyPath:@"IdCampeonato"];
    self.apelido = [attributes valueForKeyPath:@"Apelido"];
    self.nome = [attributes valueForKeyPath:@"Nome"];
    
    return self;
}

@end
