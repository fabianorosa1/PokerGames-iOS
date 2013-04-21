//
//  Player.m
//  PokerGames
//
//  Created by Fabiano Rosa on 16/04/13.
//  Copyright (c) 2013 Fabiano Rosa. All rights reserved.
//

#import "Player.h"
#import "AFAppDotNetAPIClient.h"

@implementation Player

@synthesize idPlayer = _idPlayer;
@synthesize apelido = _apelido;
@synthesize email = _email;
@synthesize nome = _nome;
@synthesize urlFoto = _urlFoto;
@synthesize status = _status;

- (id)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _idPlayer = [attributes valueForKeyPath:@"IdJogador"];
    _apelido = [attributes valueForKeyPath:@"Apelido"];
    _email = [attributes valueForKeyPath:@"Email"];
    _nome = [attributes valueForKeyPath:@"Nome"];
    _urlFoto = [attributes valueForKeyPath:@"FotoUrl"];
    _status = [attributes valueForKeyPath:@"Status"];
    
    return self;
}

#pragma mark -

+ (void)efetuaLoginPlayerWithBlock:(NSString *)user
                             passw:(NSString *)passw
         constructingBodyWithBlock:(void (^)(Player *player, NSError *error))block
{
    
    NSString *path = [NSString stringWithFormat:@"Jogadores.svc/CredencialJogador/%@/%@", user, passw];
    NSLog(@"Path: %@", path);
    
    [[AFAppDotNetAPIClient sharedClient] getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSDictionary *postsFromResponse = [JSON valueForKeyPath:@"CredencialJogadorResult"];
        
        Player *playerResult = [[Player alloc] initWithAttributes:postsFromResponse];
        
        if (block) {
            block(playerResult, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(nil, error);
        }
    }];
}

@end
