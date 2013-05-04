//
//  PokerGamesFacade.m
//  PokerGames
//
//  Created by Fabiano Rosa on 02/05/13.
//  Copyright (c) 2013 Fabiano Rosa. All rights reserved.
//

#import "PokerGamesFacade.h"
#import "AFAppDotNetAPIClient.h"
#import "Liga.h"
#import "AppDelegate.h"
#import "Campeonato.h"
#import <CoreData/CoreData.h>

@implementation PokerGamesFacade

#pragma mark Singleton Methods

+ (id)sharedInstance {
    static PokerGamesFacade *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    if (self = [super init]) {
        //
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

- (AppDelegate *)appDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

#pragma mark - Métodos do Jogador

- (void)efetuaLoginPlayerWithBlock:(NSString *)user
                             passw:(NSString *)passw
         constructingBodyWithBlock:(void (^)(Jogador *jogador, NSError *error))block
{
    
    NSString *path = [NSString stringWithFormat:@"Jogadores.svc/CredencialJogador/%@/%@", user, passw];
    //NSLog(@"Path: %@", path);
    
    [[AFAppDotNetAPIClient sharedClient] getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSDictionary *postsFromResponse = [JSON valueForKeyPath:@"CredencialJogadorResult"];
        Jogador *jogador = [[Jogador alloc] initWithAttributes:postsFromResponse];
        //NSLog(@"postsFromResponse: %@", postsFromResponse);
        
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

- (Jogador*)loadJogadorEntity
{
    NSManagedObjectContext *context = [self appDelegate].managedObjectContext;
    
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
        newJogador.foto = jogadorEntity.foto;
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

- (void)insertJogadorEntity:(Jogador*)jogador {
    NSManagedObjectContext *context = [self appDelegate].managedObjectContext;
    
    // insere o campeonato
    NSManagedObject *newManagedObjectCampeonato = [NSEntityDescription insertNewObjectForEntityForName:@"Campeonato" inManagedObjectContext:context];
    [newManagedObjectCampeonato setValue:jogador.liga.campeonato.idCampeonato forKey:@"idCampeonato"];
    [newManagedObjectCampeonato setValue:jogador.liga.campeonato.apelido forKey:@"apelido"];
    [newManagedObjectCampeonato setValue:jogador.liga.campeonato.nome forKey:@"nome"];
    
    // insere a liga
    NSManagedObject *newManagedObjectLiga = [NSEntityDescription insertNewObjectForEntityForName:@"Liga" inManagedObjectContext:context];
    [newManagedObjectLiga setValue:jogador.liga.idLiga forKey:@"idLiga"];
    [newManagedObjectLiga setValue:jogador.liga.apelido forKey:@"apelido"];
    [newManagedObjectLiga setValue:jogador.liga.nome forKey:@"nome"];
    [newManagedObjectLiga setValue:jogador.liga.idCampeonato forKey:@"idCampeonato"];
    
    // insere jogador
    NSManagedObject *newManagedObjectJogador = [NSEntityDescription insertNewObjectForEntityForName:@"Jogador" inManagedObjectContext:context];
    
    [newManagedObjectJogador setValue:jogador.idJogador forKey:@"idJogador"];
    [newManagedObjectJogador setValue:jogador.apelido forKey:@"apelido"];
    [newManagedObjectJogador setValue:jogador.email forKey:@"email"];
    [newManagedObjectJogador setValue:jogador.nome forKey:@"nome"];
    [newManagedObjectJogador setValue:jogador.foto forKey:@"foto"];
    [newManagedObjectJogador setValue:jogador.status forKey:@"status"];
    [newManagedObjectJogador setValue:jogador.idLiga forKey:@"idLiga"];
    
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Não foi possível inserir o jogador: %@", [error localizedDescription]);
    }
}

- (void) deleteAllObjects: (NSString *) entityDescription
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

- (void) excluirTodosJogadoresDependencias {
    NSManagedObjectContext *context = [self appDelegate].managedObjectContext;
    
    // exclui campeonatos
    [self deleteAllObjects:@"Campeonato" managedObjectContext:context];
    
    // exclui ligas
    [self deleteAllObjects:@"Liga" managedObjectContext:context];
    
    // exclui jogadores
    [self deleteAllObjects:@"Jogador" managedObjectContext:context];
    
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Error deleting data - error:%@", error);
    }
}

- (void) atualizaLigaCampeonatoJogadorEntity:(Jogador*)jogador {
    NSManagedObjectContext *context = [self appDelegate].managedObjectContext;
    
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
        if (jogador.idLiga != jogadorEntity.idLiga) {
            // excluio o campeonato e associa a nova liga ao jogador
            // exclui campeonatos
            [self deleteAllObjects:@"Campeonato" managedObjectContext:context];
            
            // exclui liga
            [self deleteAllObjects:@"Liga" managedObjectContext:context];
            
            // insere novo campeonato
            NSManagedObject *newManagedObjectCampeonato = [NSEntityDescription insertNewObjectForEntityForName:@"Campeonato" inManagedObjectContext:context];
            [newManagedObjectCampeonato setValue:jogador.liga.campeonato.idCampeonato forKey:@"idCampeonato"];
            [newManagedObjectCampeonato setValue:jogador.liga.campeonato.apelido forKey:@"apelido"];
            [newManagedObjectCampeonato setValue:jogador.liga.campeonato.nome forKey:@"nome"];
            
            // insere nova liga
            NSManagedObject *newManagedObjectLiga = [NSEntityDescription insertNewObjectForEntityForName:@"Liga" inManagedObjectContext:context];
            [newManagedObjectLiga setValue:jogador.liga.idLiga forKey:@"idLiga"];
            [newManagedObjectLiga setValue:jogador.liga.apelido forKey:@"apelido"];
            [newManagedObjectLiga setValue:jogador.liga.nome forKey:@"nome"];
            [newManagedObjectLiga setValue:jogador.liga.idCampeonato forKey:@"idCampeonato"];
            
            // associa a nova liga ao jogador
            [jogadorEntity setIdLiga:jogador.idLiga];
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
                if (jogador.liga.idCampeonato != ligaEntity.idCampeonato) {
                    // exclui campeonatos
                    [self deleteAllObjects:@"Campeonato" managedObjectContext:context];
                    
                    // insere novo campeonato
                    NSManagedObject *newManagedObjectCampeonato = [NSEntityDescription insertNewObjectForEntityForName:@"Campeonato" inManagedObjectContext:context];
                    [newManagedObjectCampeonato setValue:jogador.liga.campeonato.idCampeonato forKey:@"idCampeonato"];
                    [newManagedObjectCampeonato setValue:jogador.liga.campeonato.apelido forKey:@"apelido"];
                    [newManagedObjectCampeonato setValue:jogador.liga.campeonato.nome forKey:@"nome"];
                    
                    // associa o campeonato a liga
                    [ligaEntity setIdCampeonato:jogador.liga.idCampeonato];
                }
            }
        }
        
        NSError *error;
        if (![context save:&error]) {
            NSLog(@"Error deleting data - error:%@", error);
        }
    }
}

- (void)buscaLigasPlayerWithBlock:(NSNumber *)idPlayer
        constructingBodyWithBlock:(void (^)(NSArray *ligas, NSError *error))block
{
    
    NSString *path = [NSString stringWithFormat:@"Liga.svc/Liga/%@", idPlayer];
    //NSLog(@"Path: %@", path);
    
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
            NSLog(@"Path: %@", path);
            block([NSArray array], error);
        }
    }];
}

#pragma mark - Métodos do Campeonato

- (void)buscaCampeonatosLigaWithBlock:(NSNumber *)idLiga
            constructingBodyWithBlock:(void (^)(NSArray *campeonatos, NSError *error))block
{
    
    NSString *path = [NSString stringWithFormat:@"Campeonatos.svc/Todos/%@", idLiga];
    //NSLog(@"Path: %@", path);
    
    [[AFAppDotNetAPIClient sharedClient] getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSArray *postsFromResponse = [JSON valueForKeyPath:@"TodosResult"];
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
            NSLog(@"Path: %@", path);
            block([NSArray array], error);
        }
    }];
}

#pragma mark - Métodos das Views Controllers

- (void)buscaRankingCampeonatosWithBlock:(NSNumber *)idLiga
                            idCampeonato:(NSNumber *)idCampeonato
               constructingBodyWithBlock:(void (^)(NSArray *ranking, NSError *error))block
{
    
    NSString *path = [NSString stringWithFormat:@"Campeonatos.svc/Ranking/%@/%@", idLiga, idCampeonato];
    //NSLog(@"Path: %@", path);
    
    [[AFAppDotNetAPIClient sharedClient] getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSArray *postsFromResponse = [JSON valueForKeyPath:@"RankingResult"];
        if (block) {
            //NSLog(@"postsFromResponse: %@", postsFromResponse);
            block(postsFromResponse, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            NSLog(@"Path: %@", path);
            block([NSArray array], error);
        }
    }];
}

- (void)buscaResultadosTorneiosJogadorWithBlock:(NSNumber *)idLiga
                                   idCampeonato:(NSNumber *)idCampeonato
                                      idJogador:(NSNumber *)idJogador
                      constructingBodyWithBlock:(void (^)(NSArray *resultados, NSError *error))block
{
    
    NSString *path = [NSString stringWithFormat:@"Jogadores.svc/ResultadosTorneios/%@/%@/%@", idLiga, idCampeonato, idJogador];
    //NSLog(@"Path: %@", path);
    
    [[AFAppDotNetAPIClient sharedClient] getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSArray *postsFromResponse = [JSON valueForKeyPath:@"ResultadosTorneiosResult"];
        if (block) {
            block(postsFromResponse, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            NSLog(@"Path: %@", path);
            block([NSArray array], error);
        }
    }];
}

- (void)buscaCabecalhoResultadosWithBlock:(NSNumber *)idLiga
                             idCampeonato:(NSNumber *)idCampeonato
                                idJogador:(NSNumber *)idJogador
                constructingBodyWithBlock:(void (^)(NSDictionary *cabecalho, NSError *error))block
{
    
    NSString *path = [NSString stringWithFormat:@"Jogadores.svc/ResumoResultados/%@/%@/%@", idLiga, idCampeonato, idJogador];
    //NSLog(@"Path: %@", path);
    
    [[AFAppDotNetAPIClient sharedClient] getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSDictionary *postsFromResponse = [JSON valueForKeyPath:@"ResumoResultadosResult"];
        if (block) {
            block(postsFromResponse, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            NSLog(@"Path: %@", path);
            block([NSDictionary dictionary], error);
        }
    }];
}

- (void)buscaTorneiosConcluidosWithBlock:(NSNumber *)idLiga
                            idCampeonato:(NSNumber *)idCampeonato
               constructingBodyWithBlock:(void (^)(NSArray *torneios, NSError *error))block
{
    
    NSString *path = [NSString stringWithFormat:@"Torneios.svc/Inativos/%@/%@", idLiga, idCampeonato];
    //NSLog(@"Path: %@", path);
    
    [[AFAppDotNetAPIClient sharedClient] getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSArray *postsFromResponse = [JSON valueForKeyPath:@"InativosResult"];
        if (block) {
            //NSLog(@"postsFromResponse: %@", postsFromResponse);
            block(postsFromResponse, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            NSLog(@"Path: %@", path);
            block([NSArray array], error);
        }
    }];
}

- (void)buscaCabecalhoRankingWithBlock:(NSNumber *)idTorneio
             constructingBodyWithBlock:(void (^)(NSDictionary *cabecalho, NSError *error))block
{
    
    NSString *path = [NSString stringWithFormat:@"Torneios.svc/Cabecalho/%@", idTorneio];
    //NSLog(@"Path: %@", path);
    
    [[AFAppDotNetAPIClient sharedClient] getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSDictionary *postsFromResponse = [JSON valueForKeyPath:@"CabecalhoResult"];
        if (block) {
            //NSLog(@"postsFromResponse: %@", postsFromResponse);
            block(postsFromResponse, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            NSLog(@"Path: %@", path);
            block([NSDictionary dictionary], error);
        }
    }];
}

- (void)buscaRankingTorneioWithBlock:(NSNumber *)idTorneio
           constructingBodyWithBlock:(void (^)(NSArray *ranking, NSError *error))block
{
    
    NSString *path = [NSString stringWithFormat:@"Torneios.svc/Ranking/%@", idTorneio];
    //NSLog(@"Path: %@", path);
    
    [[AFAppDotNetAPIClient sharedClient] getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSArray *postsFromResponse = [JSON valueForKeyPath:@"RankingResult"];
        if (block) {
            // NSLog(@"postsFromResponse: %@", postsFromResponse);
            block(postsFromResponse, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            NSLog(@"Path: %@", path);
            block([NSArray array], error);
        }
    }];
}

// métodos da tela do JackPot

- (void)buscaCabecalhoJackPotWithBlock:(NSNumber *)idLiga
             constructingBodyWithBlock:(void (^)(NSString *saldo, NSError *error))block
{
    
    NSString *path = [NSString stringWithFormat:@"Jacks.svc/Saldo/%@", idLiga];
    //NSLog(@"Path: %@", path);
    
    [[AFAppDotNetAPIClient sharedClient] getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSString *postsFromResponse = [JSON valueForKeyPath:@"SaldoResult"];
        if (block) {
            //NSLog(@"postsFromResponse: %@", postsFromResponse);
            block(postsFromResponse, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            NSLog(@"Path: %@", path);
            block(@"", error);
        }
    }];
}

- (void)buscaJackPotWithBlock:(NSNumber *)idLiga
           constructingBodyWithBlock:(void (^)(NSArray *jackpots, NSError *error))block
{
    
    NSString *path = [NSString stringWithFormat:@"Jacks.svc/Extrato/%@", idLiga];
    //NSLog(@"Path: %@", path);
    
    [[AFAppDotNetAPIClient sharedClient] getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSArray *postsFromResponse = [JSON valueForKeyPath:@"ExtratoResult"];
        if (block) {
            // NSLog(@"postsFromResponse: %@", postsFromResponse);
            block(postsFromResponse, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            NSLog(@"Path: %@", path);
            block([NSArray array], error);
        }
    }];
}

// metodos da tela de lista de jogadores

- (void)buscaListaJogadoresPotWithBlock:(NSNumber *)idLiga
    constructingBodyWithBlock:(void (^)(NSArray *jogadores, NSError *error))block
{
    
    NSString *path = [NSString stringWithFormat:@"Jogadores.svc/Ativos/%@", idLiga];
    //NSLog(@"Path: %@", path);
    
    [[AFAppDotNetAPIClient sharedClient] getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSArray *postsFromResponse = [JSON valueForKeyPath:@"AtivosResult"];
        NSMutableArray *mutablePosts = [NSMutableArray arrayWithCapacity:[postsFromResponse count]];
        for (NSDictionary *attributes in postsFromResponse) {
            Jogador *jogador = [[Jogador alloc] initWithAttributes:attributes];
            [mutablePosts addObject:jogador];
        }
        
        if (block) {
            block([NSArray arrayWithArray:mutablePosts], nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            NSLog(@"Path: %@", path);
            block([NSArray array], error);
        }
    }];
}

@end
