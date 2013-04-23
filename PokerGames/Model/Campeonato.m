//
//  Campeonato.m
//  PokerGames
//
//  Created by Fabiano Rosa on 16/04/13.
//  Copyright (c) 2013 Fabiano Rosa. All rights reserved.
//

#import "Campeonato.h"
#import "AFAppDotNetAPIClient.h"

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

#pragma mark -

+ (void)buscaCampeonatosLigaWithBlock:(NSNumber *)idLiga
            constructingBodyWithBlock:(void (^)(NSArray *campeonatos, NSError *error))block
{
    
    NSString *path = [NSString stringWithFormat:@"Campeonatos.svc/TodosCampeonatosLiga/%@", idLiga];
    NSLog(@"Path: %@", path);
    
    [[AFAppDotNetAPIClient sharedClient] getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSArray *postsFromResponse = [JSON valueForKeyPath:@"TodosCampeonatosLigaResult"];
        NSMutableArray *mutablePosts = [NSMutableArray arrayWithCapacity:[postsFromResponse count]];
        for (NSDictionary *attributes in postsFromResponse) {
            Campeonato *campeonato = [[Campeonato alloc] initWithAttributes:attributes];
            [mutablePosts addObject:campeonato];
        }
        
        if (block) {
            block([NSArray arrayWithArray:mutablePosts], nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block([NSArray array], error);
        }
    }];
}

@end
