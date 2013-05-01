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
#import "Campeonato.h"
#import "PokerGamesUtil.h"

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
    //self.urlFoto = [attributes valueForKeyPath:@"FotoUrl"];
    self.status = [attributes valueForKeyPath:@"Status"];
    
    return self;
}

+ (NSURL*) buildUrlFoto:(NSNumber*)idJogador {
    NSString *pathFoto = [NSString stringWithFormat:@"%@jogador%@.jpg", [PokerGamesUtil baseURLFoto],  idJogador];
    return [NSURL URLWithString:pathFoto];
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
            NSLog(@"Path: %@", path);
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
    NSFetchRequest *fetchRequestJogador = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityJogador = [NSEntityDescription entityForName:@"Jogador"
                                              inManagedObjectContext:context];
    [fetchRequestJogador setEntity:entityJogador];
    
    NSError *error = nil;
    NSArray *fetchedObjectsJogador = [context executeFetchRequest:fetchRequestJogador error:&error];
    
    if (fetchedObjectsJogador.count > 0) {
        Jogador *jogadorEntity = fetchedObjectsJogador[0];
        //NSLog(@"Jogador Entity: %@", jogadorEntity);
        
        // cria novo jogador
        Jogador *newJogador = [[Jogador alloc] init];
        newJogador.idJogador = jogadorEntity.idJogador;
        newJogador.nome = jogadorEntity.nome;
        newJogador.apelido = jogadorEntity.apelido;
        newJogador.status = jogadorEntity.status;
        newJogador.email = jogadorEntity.email;
        //newJogador.urlFoto = jogadorEntity.urlFoto;
        newJogador.idLiga = jogadorEntity.idLiga;
        
        // carrega a liga do jogador
        NSFetchRequest *fetchRequestLiga = [[NSFetchRequest alloc] init];
        NSPredicate *predicateLiga = [NSPredicate predicateWithFormat:@"idLiga == %@", newJogador.idLiga];
        NSEntityDescription *entityLiga = [NSEntityDescription entityForName:@"Liga"
                                                         inManagedObjectContext:context];
        [fetchRequestLiga setEntity:entityLiga];
        [fetchRequestLiga setPredicate:predicateLiga];
        
        error = nil;
        NSArray *fetchedObjectsLiga = [context executeFetchRequest:fetchRequestLiga error:&error];
        
        if (fetchedObjectsLiga.count > 0) {
            Liga *ligaEntity = fetchedObjectsLiga[0];
           // NSLog(@"Liga Entity: %@", ligaEntity);
            
            Liga *newLiga = [[Liga alloc] init];
            newLiga.idLiga = ligaEntity.idLiga;
            newLiga.nome = ligaEntity.nome;
            newLiga.apelido = ligaEntity.apelido;
            newLiga.idCampeonato = ligaEntity.idCampeonato;
            
            newJogador.liga = newLiga;
            
            // carrega o campeonato
            NSFetchRequest *fetchRequestCampeonato = [[NSFetchRequest alloc] init];
            NSPredicate *predicateCampeonato = [NSPredicate predicateWithFormat:@"idCampeonato == %@", newLiga.idCampeonato];
            NSEntityDescription *entityCampeonato = [NSEntityDescription entityForName:@"Campeonato"
                                                          inManagedObjectContext:context];
            [fetchRequestCampeonato setEntity:entityCampeonato];
            [fetchRequestCampeonato setPredicate:predicateCampeonato];
            
            error = nil;
            NSArray *fetchedObjectsCampeonato = [context executeFetchRequest:fetchRequestCampeonato error:&error];
            
            if (fetchedObjectsCampeonato.count > 0) {
                Campeonato *campeonatoEntity = fetchedObjectsCampeonato[0];
               // NSLog(@"Campeonato Entity: %@", campeonatoEntity);
                
                Campeonato *newCampeonato = [[Campeonato alloc] init];
                newCampeonato.idCampeonato = campeonatoEntity.idCampeonato;
                newCampeonato.apelido = campeonatoEntity.apelido;
                newCampeonato.nome = campeonatoEntity.nome;
                
                newJogador.liga.campeonato = newCampeonato;
            } else {
                // não encontrou, configura novamente
                return nil;
            }
        } else {
            // não encontrou, configura novamente
            return nil;
        }
        return newJogador;
    } else {
        // não encontrou, configura novamente
        return nil;
    }
}

-(void)insertJogadorEntity
{
    NSManagedObjectContext *context = [Jogador appDelegate].managedObjectContext;
    
    // insere o campeonato
    NSManagedObject *newManagedObjectCampeonato = [NSEntityDescription insertNewObjectForEntityForName:@"Campeonato" inManagedObjectContext:context];
    [newManagedObjectCampeonato setValue:self.liga.campeonato.idCampeonato forKey:@"idCampeonato"];
    [newManagedObjectCampeonato setValue:self.liga.campeonato.apelido forKey:@"apelido"];
    [newManagedObjectCampeonato setValue:self.liga.campeonato.nome forKey:@"nome"];
    
    // insere a liga
    NSManagedObject *newManagedObjectLiga = [NSEntityDescription insertNewObjectForEntityForName:@"Liga" inManagedObjectContext:context];
    [newManagedObjectLiga setValue:self.liga.idLiga forKey:@"idLiga"];
    [newManagedObjectLiga setValue:self.liga.apelido forKey:@"apelido"];
    [newManagedObjectLiga setValue:self.liga.nome forKey:@"nome"];
    [newManagedObjectLiga setValue:self.liga.idCampeonato forKey:@"idCampeonato"];
    
    // insere jogador
    NSManagedObject *newManagedObjectJogador = [NSEntityDescription insertNewObjectForEntityForName:@"Jogador" inManagedObjectContext:context];
    
    [newManagedObjectJogador setValue:self.idJogador forKey:@"idJogador"];
    [newManagedObjectJogador setValue:self.apelido forKey:@"apelido"];
    [newManagedObjectJogador setValue:self.email forKey:@"email"];
    [newManagedObjectJogador setValue:self.nome forKey:@"nome"];
    //[newManagedObjectJogador setValue:self.urlFoto forKey:@"urlFoto"];
    [newManagedObjectJogador setValue:self.status forKey:@"status"];
    [newManagedObjectJogador setValue:self.idLiga forKey:@"idLiga"];
    
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Não foi possível inserir o jogador: %@", [error localizedDescription]);
    }
}

+ (void) deleteAllObjects: (NSString *) entityDescription
     managedObjectContext:(NSManagedObjectContext *) managedObjectContext
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityDescription inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *items = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    for (NSManagedObject *managedObject in items) {
    	[managedObjectContext deleteObject:managedObject];
    	//NSLog (@"%@ object deleted", managedObject);
    }
}

+ (void) excluirTodosJogadoresDependencias
{
    NSManagedObjectContext *context = [Jogador appDelegate].managedObjectContext;
    
    // exclui campeonatos
    [Jogador deleteAllObjects:@"Campeonato" managedObjectContext:context];

    // exclui ligas
    [Jogador deleteAllObjects:@"Liga" managedObjectContext:context];
    
    // exclui jogadores
    [Jogador deleteAllObjects:@"Jogador" managedObjectContext:context];
    
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Error deleting data - error:%@", error);
    } 
}

- (void) atualizaLigaCampeonatoJogadorEntity {
    NSManagedObjectContext *context = [Jogador appDelegate].managedObjectContext;
    
    // verifica se a liga associada ao jogador foi alterada
    // carrega o jogador, liga e campeonato default
    NSFetchRequest *fetchRequestJogador = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityJogador = [NSEntityDescription entityForName:@"Jogador"
                                                     inManagedObjectContext:context];
    [fetchRequestJogador setEntity:entityJogador];
    
    NSError *error = nil;
    NSArray *fetchedObjectsJogador = [context executeFetchRequest:fetchRequestJogador error:&error];
    
    if (fetchedObjectsJogador.count > 0) {
        Jogador *jogadorEntity = fetchedObjectsJogador[0];

        // verifica se a liga é diferente
        if (self.idLiga != jogadorEntity.idLiga) {
            // excluio o campeonato e associa a nova liga ao jogador
            // exclui campeonatos
            [Jogador deleteAllObjects:@"Campeonato" managedObjectContext:context];

            // exclui liga
            [Jogador deleteAllObjects:@"Liga" managedObjectContext:context];

            // insere novo campeonato
            NSManagedObject *newManagedObjectCampeonato = [NSEntityDescription insertNewObjectForEntityForName:@"Campeonato" inManagedObjectContext:context];
            [newManagedObjectCampeonato setValue:self.liga.campeonato.idCampeonato forKey:@"idCampeonato"];
            [newManagedObjectCampeonato setValue:self.liga.campeonato.apelido forKey:@"apelido"];
            [newManagedObjectCampeonato setValue:self.liga.campeonato.nome forKey:@"nome"];

            // insere nova liga
            NSManagedObject *newManagedObjectLiga = [NSEntityDescription insertNewObjectForEntityForName:@"Liga" inManagedObjectContext:context];
            [newManagedObjectLiga setValue:self.liga.idLiga forKey:@"idLiga"];
            [newManagedObjectLiga setValue:self.liga.apelido forKey:@"apelido"];
            [newManagedObjectLiga setValue:self.liga.nome forKey:@"nome"];
            [newManagedObjectLiga setValue:self.liga.idCampeonato forKey:@"idCampeonato"];
            
            // associa a nova liga ao jogador
            [jogadorEntity setIdLiga:self.idLiga];
        } else {
            // carrega a liga do jogador
            NSFetchRequest *fetchRequestLiga = [[NSFetchRequest alloc] init];
            NSPredicate *predicateLiga = [NSPredicate predicateWithFormat:@"idLiga == %@", jogadorEntity.idLiga];
            NSEntityDescription *entityLiga = [NSEntityDescription entityForName:@"Liga"
                                                          inManagedObjectContext:context];
            [fetchRequestLiga setEntity:entityLiga];
            [fetchRequestLiga setPredicate:predicateLiga];
            
            error = nil;
            NSArray *fetchedObjectsLiga = [context executeFetchRequest:fetchRequestLiga error:&error];
            
            if (fetchedObjectsLiga.count > 0) {
                Liga *ligaEntity = fetchedObjectsLiga[0];
                // verifica se o campeonato mudou
                if (self.liga.idCampeonato != ligaEntity.idCampeonato) {
                    // exclui campeonatos
                    [Jogador deleteAllObjects:@"Campeonato" managedObjectContext:context];

                    // insere novo campeonato
                    NSManagedObject *newManagedObjectCampeonato = [NSEntityDescription insertNewObjectForEntityForName:@"Campeonato" inManagedObjectContext:context];
                    [newManagedObjectCampeonato setValue:self.liga.campeonato.idCampeonato forKey:@"idCampeonato"];
                    [newManagedObjectCampeonato setValue:self.liga.campeonato.apelido forKey:@"apelido"];
                    [newManagedObjectCampeonato setValue:self.liga.campeonato.nome forKey:@"nome"];
                    
                    // associa o campeonato a liga
                    [ligaEntity setIdCampeonato:self.liga.idCampeonato];
                }
            }
        }
        
        NSError *error;
        if (![context save:&error]) {
            NSLog(@"Error deleting data - error:%@", error);
        }
    }
}

@end
