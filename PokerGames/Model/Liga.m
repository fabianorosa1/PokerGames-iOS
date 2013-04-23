//
//  Liga.m
//  PokerGames
//
//  Created by Fabiano Rosa on 16/04/13.
//  Copyright (c) 2013 Fabiano Rosa. All rights reserved.
//

#import "Liga.h"
#import "AFAppDotNetAPIClient.h"

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

#pragma mark -

+ (void)buscaLigasPlayerWithBlock:(NSNumber *)idPlayer
        constructingBodyWithBlock:(void (^)(NSArray *ligas, NSError *error))block
{
    
    NSString *path = [NSString stringWithFormat:@"Liga.svc/Liga/%@", idPlayer];
    NSLog(@"Path: %@", path);
    
    [[AFAppDotNetAPIClient sharedClient] getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSArray *postsFromResponse = [JSON valueForKeyPath:@"LigaResult"];
        NSMutableArray *mutablePosts = [NSMutableArray arrayWithCapacity:[postsFromResponse count]];
        for (NSDictionary *attributes in postsFromResponse) {
            Liga *liga = [[Liga alloc] initWithAttributes:attributes];
            [mutablePosts addObject:liga];
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
