//
//  Jogador.m
//  PokerGames
//
//  Created by Fabiano Rosa on 16/04/13.
//  Copyright (c) 2013 Fabiano Rosa. All rights reserved.
//

#import "Jogador.h"
#import "AFAppDotNetAPIClient.h"
#import "Liga.h"
#import "AppDelegate.h"

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
    self.urlFoto = [attributes valueForKeyPath:@"FotoUrl"];
    self.status = [attributes valueForKeyPath:@"Status"];
    
    return self;
}

#pragma mark -

+ (void)efetuaLoginPlayerWithBlock:(NSString *)user
                             passw:(NSString *)passw
         constructingBodyWithBlock:(void (^)(Jogador *jogador, NSError *error))block
{
    
    NSString *path = [NSString stringWithFormat:@"Jogadores.svc/CredencialJogador/%@/%@", user, passw];
    //NSLog(@"Path: %@", path);
    
    [[AFAppDotNetAPIClient sharedClient] getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSDictionary *postsFromResponse = [JSON valueForKeyPath:@"CredencialJogadorResult"];
        Jogador *jogador = [[Jogador alloc] initWithAttributes:postsFromResponse];
        
        if (block) {
            block(jogador, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(nil, error);
        }
    }];
}

+ (AppDelegate *)appDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

+(Jogador*)loadJogadorEntity
{
    NSManagedObjectContext *context = [Jogador appDelegate].managedObjectContext;
    
    // carrega o jogador, liga e campeonato default
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Jogador"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    if (fetchedObjects.count > 0) {
        NSLog(@"Jogador Entity: %@", fetchedObjects[0]);
        return fetchedObjects[0];
    } else {
        return nil;
    }
    
    //for (FailedBankInfo *info in fetchedObjects) {
    //    NSLog(@"Name: %@", info.name);
    //    FailedBankDetails *details = info.details;
    //    NSLog(@"Zip: %@", details.zip);
    //}
}

-(void)insertJogadorEntity
{
    NSManagedObjectContext *context = [Jogador appDelegate].managedObjectContext;
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Jogador" inManagedObjectContext:context];
    
    [newManagedObject setValue:self.idJogador forKey:@"idJogador"];
    [newManagedObject setValue:self.apelido forKey:@"apelido"];
    [newManagedObject setValue:self.email forKey:@"email"];
    [newManagedObject setValue:self.nome forKey:@"nome"];
    [newManagedObject setValue:self.urlFoto forKey:@"urlFoto"];
    [newManagedObject setValue:self.status forKey:@"status"];
    
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
}

@end
