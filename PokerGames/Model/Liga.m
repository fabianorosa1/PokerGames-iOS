//
//  Liga.m
//  PokerGames
//
//  Created by Fabiano Rosa on 16/04/13.
//  Copyright (c) 2013 Fabiano Rosa. All rights reserved.
//

#import "Liga.h"

@implementation Liga

- (id)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.idLiga = [attributes valueForKeyPath:@"IdLiga"];
    self.apelido = [attributes valueForKeyPath:@"Apelido"];
    self.nome = [attributes valueForKeyPath:@"Nome"];
    
    return self;
}

@end
