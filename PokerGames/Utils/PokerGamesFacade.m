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
#import <AddressBook/AddressBook.h>

@implementation PokerGamesFacade {
    BOOL *indLog;
}

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
        // configuracao de log
        indLog = FALSE;
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

- (AppDelegate *)appDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void) logServicos:(NSString*)label text:(id)text {
    if (indLog) {
        NSLog(@"%@: %@", label, text);
    }
}

#pragma mark - Métodos do Jogador

- (void)efetuaLogout {
    // limpa dados de configuracao
    [self excluirTodosJogadoresDependencias];
    
    // seta não configurado
    [self setIsFirstTime:TRUE];
    
    // limpa o cache de reanking geral
    self.arRankingGeral = nil;
}

- (void)efetuaLoginPlayerWithBlock:(NSString *)user
                             passw:(NSString *)passw
         constructingBodyWithBlock:(void (^)(Jogador *jogador, NSError *error))block
{
    
    NSString *path = [NSString stringWithFormat:@"Jogadores.svc/CredencialJogador/%@/%@", user, passw];
    //logServicos(@"Path", path);
    [self logServicos:@"Path" text:path];
    
    [[AFAppDotNetAPIClient sharedClient] getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSDictionary *postsFromResponse = [JSON valueForKeyPath:@"CredencialJogadorResult"];
        Jogador *jogador = [[Jogador alloc] initWithAttributes:postsFromResponse];
        [self logServicos:@"postsFromResponse" text:postsFromResponse];
        
        if (block) {
            block(jogador, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            [self logServicos:@"Path" text:path];
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
        // [self logServicos:@"Jogador Entity" text:jogadorEntity];
        
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
            // [self logServicos:@"Liga Entity" text:ligaEntity);
            
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
                // [self logServicos:@"Campeonato Entity" text:campeonatoEntity);
                
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
        NSLog(@"Não foi possível inserir o jogador: %@" ,[error localizedDescription]);
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
    [self logServicos:@"Path" text:path];
    
    [[AFAppDotNetAPIClient sharedClient] getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSArray *postsFromResponse = [JSON valueForKeyPath:@"LigaResult"];
        [self logServicos:@"postsFromResponse" text:postsFromResponse];

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
            [self logServicos:@"Path" text:path];
            block([NSArray array], error);
        }
    }];
}

#pragma mark - Métodos do Campeonato

- (void)buscaCampeonatosLigaWithBlock:(NSNumber *)idLiga
            constructingBodyWithBlock:(void (^)(NSArray *campeonatos, NSError *error))block
{
    
    NSString *path = [NSString stringWithFormat:@"Campeonatos.svc/Todos/%@", idLiga];
    [self logServicos:@"Path" text:path];
    
    [[AFAppDotNetAPIClient sharedClient] getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSArray *postsFromResponse = [JSON valueForKeyPath:@"TodosResult"];
        [self logServicos:@"postsFromResponse" text:postsFromResponse];
        
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
            [self logServicos:@"Path" text:path];
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
    [self logServicos:@"Path" text:path];
    
    [[AFAppDotNetAPIClient sharedClient] getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSArray *postsFromResponse = [JSON valueForKeyPath:@"RankingResult"];
        if (block) {
            [self logServicos:@"postsFromResponse" text:postsFromResponse];
            block(postsFromResponse, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            [self logServicos:@"Path" text:path];
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
    [self logServicos:@"Path" text:path];
    
    [[AFAppDotNetAPIClient sharedClient] getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSArray *postsFromResponse = [JSON valueForKeyPath:@"ResultadosTorneiosResult"];
        if (block) {
            [self logServicos:@"postsFromResponse" text:postsFromResponse];
            block(postsFromResponse, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            [self logServicos:@"Path" text:path];
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
    [self logServicos:@"Path" text:path];
    
    [[AFAppDotNetAPIClient sharedClient] getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSDictionary *postsFromResponse = [JSON valueForKeyPath:@"ResumoResultadosResult"];
        if (block) {
            [self logServicos:@"postsFromResponse" text:postsFromResponse];
            block(postsFromResponse, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            [self logServicos:@"Path" text:path];
            block([NSDictionary dictionary], error);
        }
    }];
}

- (void)buscaTorneiosConcluidosWithBlock:(NSNumber *)idLiga
                            idCampeonato:(NSNumber *)idCampeonato
               constructingBodyWithBlock:(void (^)(NSArray *torneios, NSError *error))block
{
    
    NSString *path = [NSString stringWithFormat:@"Torneios.svc/Inativos/%@/%@", idLiga, idCampeonato];
    [self logServicos:@"Path" text:path];
    
    [[AFAppDotNetAPIClient sharedClient] getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSArray *postsFromResponse = [JSON valueForKeyPath:@"InativosResult"];
        if (block) {
            [self logServicos:@"postsFromResponse" text:postsFromResponse];
            block(postsFromResponse, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            [self logServicos:@"Path" text:path];
            block([NSArray array], error);
        }
    }];
}

- (void)buscaCabecalhoRankingWithBlock:(NSNumber *)idTorneio
             constructingBodyWithBlock:(void (^)(NSDictionary *cabecalho, NSError *error))block
{
    
    NSString *path = [NSString stringWithFormat:@"Torneios.svc/Cabecalho/%@", idTorneio];
    [self logServicos:@"Path" text:path];
    
    [[AFAppDotNetAPIClient sharedClient] getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSDictionary *postsFromResponse = [JSON valueForKeyPath:@"CabecalhoResult"];
        if (block) {
            [self logServicos:@"postsFromResponse" text:postsFromResponse];
            block(postsFromResponse, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            [self logServicos:@"Path" text:path];
            block([NSDictionary dictionary], error);
        }
    }];
}

- (void)buscaRankingTorneioWithBlock:(NSNumber *)idTorneio
           constructingBodyWithBlock:(void (^)(NSArray *ranking, NSError *error))block
{
    
    NSString *path = [NSString stringWithFormat:@"Torneios.svc/Ranking/%@", idTorneio];
    [self logServicos:@"Path" text:path];
    
    [[AFAppDotNetAPIClient sharedClient] getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSArray *postsFromResponse = [JSON valueForKeyPath:@"RankingResult"];
        if (block) {
            [self logServicos:@"postsFromResponse" text:postsFromResponse];
            block(postsFromResponse, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            [self logServicos:@"Path" text:path];
            block([NSArray array], error);
        }
    }];
}

// métodos da tela do JackPot

- (void)buscaCabecalhoJackPotWithBlock:(NSNumber *)idLiga
             constructingBodyWithBlock:(void (^)(NSString *saldo, NSError *error))block
{
    
    NSString *path = [NSString stringWithFormat:@"Jacks.svc/Saldo/%@", idLiga];
    [self logServicos:@"Path" text:path];
    
    [[AFAppDotNetAPIClient sharedClient] getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSString *postsFromResponse = [JSON valueForKeyPath:@"SaldoResult"];
        if (block) {
            [self logServicos:@"postsFromResponse" text:postsFromResponse];
            block(postsFromResponse, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            [self logServicos:@"Path" text:path];
            block(@"", error);
        }
    }];
}

- (void)buscaJackPotWithBlock:(NSNumber *)idLiga
           constructingBodyWithBlock:(void (^)(NSArray *jackpots, NSError *error))block
{
    
    NSString *path = [NSString stringWithFormat:@"Jacks.svc/Extrato/%@", idLiga];
    [self logServicos:@"Path" text:path];
    
    [[AFAppDotNetAPIClient sharedClient] getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSArray *postsFromResponse = [JSON valueForKeyPath:@"ExtratoResult"];
        if (block) {
            [self logServicos:@"postsFromResponse" text:postsFromResponse];
            block(postsFromResponse, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            [self logServicos:@"Path" text:path];
            block([NSArray array], error);
        }
    }];
}

// metodos da tela de lista de jogadores

- (void)buscaListaJogadoresPotWithBlock:(NSNumber *)idLiga
    constructingBodyWithBlock:(void (^)(NSArray *jogadores, NSError *error))block
{
    
    NSString *path = [NSString stringWithFormat:@"Jogadores.svc/Todos/%@", idLiga];
    [self logServicos:@"Path" text:path];
    
    [[AFAppDotNetAPIClient sharedClient] getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSArray *postsFromResponse = [JSON valueForKeyPath:@"TodosResult"];
        [self logServicos:@"postsFromResponse" text:postsFromResponse];
        
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
            [self logServicos:@"Path" text:path];
            block([NSArray array], error);
        }
    }];
}

- (void) adicionaJogadorAosContatos:(Jogador*)jogador {
    // cria objeto de contatos
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);

    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    PokerGamesFacade * __weak weakSelf = self; // avoid capturing self in the block
    
    ABAddressBookRequestAccessCompletionHandler completion = ^(bool granted, CFErrorRef error) {
        if (granted) {
            NSLog(@"Autorizado!!!");
            
            if ([weakSelf criaNovoContato:addressBook jogador:jogador] != 0){
                [[[UIAlertView alloc] initWithTitle:@"PokerGames" message:@"Jogador adicionado aos contatos!" delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
            }
        } else {
            // update the UI on the main thread
            //dispatch_async(dispatch_get_main_queue(), ^{
            //    [contacts removeAllObjects];
            //    [self.tableView reloadData];
            //});
            NSLog(@"NAO autorizado");
        }
    };
    
    // ask the user for access if necessary
    switch (status) {
        case kABAuthorizationStatusNotDetermined:
            ABAddressBookRequestAccessWithCompletion(addressBook, completion);
            break;
        case kABAuthorizationStatusAuthorized:
            completion(YES, NULL);
            break;
        case kABAuthorizationStatusDenied:
        case kABAuthorizationStatusRestricted:
            completion(NO, NULL);
            break;
    }
    
}

- (NSUInteger)criaNovoContato:(ABAddressBookRef)addressBook jogador:(Jogador*)jogador {
    NSUInteger addressbookId = 0;
    
    UIImage *imgContact = [UIImage imageWithData:[NSData dataWithContentsOfURL:[PokerGamesUtil buildUrlFoto:jogador.foto]]];
    NSString *firstName= jogador.nome;
    NSString *nickName= jogador.apelido;
    NSString *workPhone = jogador.fone;
    NSString *workEmail = jogador.email;
    
    ABRecordRef aRecord = ABPersonCreate();
    CFErrorRef  anError = NULL;
    ABRecordSetValue(aRecord, kABPersonFirstNameProperty, (__bridge CFTypeRef)(firstName), &anError);
    ABRecordSetValue(aRecord, kABPersonNicknameProperty, (__bridge CFTypeRef)(nickName), &anError);
    
    if (anError != NULL) {
        NSLog(@"error while creating kABPerson Properties..%@", anError);
    }
    
    if(imgContact){
        NSData *data = UIImagePNGRepresentation(imgContact);
        if(ABPersonSetImageData(aRecord, (__bridge CFDataRef)data, &anError)){
        }
    }
    
    //(@"adding email");
    if(workEmail){
        ABMutableMultiValueRef emails = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        ABMultiValueAddValueAndLabel(emails,  (__bridge CFTypeRef)(workEmail), kABWorkLabel, NULL);
        ABRecordSetValue(aRecord, kABPersonEmailProperty, emails, &anError);
        CFRelease(emails);
    }
    
    //(@"adding phonee");
    ABMutableMultiValueRef multi = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    
    if(workPhone) ABMultiValueAddValueAndLabel(multi, (__bridge CFTypeRef)(workPhone), kABWorkLabel, NULL) ;
    if(workPhone){
        ABRecordSetValue(aRecord, kABPersonPhoneProperty, multi, &anError);
        if (anError != NULL) {
            NSLog(@"error while creating ABMutableMultiValueRef..%@", anError);
        }
    }
    
    CFRelease(multi);

    CFErrorRef error = NULL;
    
    ABAddressBookAddRecord (addressBook, aRecord, &error);
    if (error != NULL) {
        NSLog(@"ABAddressBookAddRecord %@", error);
    }
    error = NULL;
    
    if(ABAddressBookSave ( addressBook,  &error)){
        addressbookId =  ABRecordGetRecordID (aRecord);
    }
    
    if (error != NULL) {
        NSLog(@"ABAddressBookSave %@", error);
    }
    
    NSLog(@"addressbookId: %lu", (unsigned long)addressbookId);
    CFRelease(aRecord);
    CFRelease(addressBook);
    
    return addressbookId;
}

// metodos da tela de torneios disponiveis

- (void)buscaTorneiosDisponiveisWithBlock:(NSNumber *)idLiga
                            idCampeonato:(NSNumber *)idCampeonato
                            idJogador:(NSNumber *)idJogador
               constructingBodyWithBlock:(void (^)(NSArray *torneios, NSError *error))block
{
    
    NSString *path = [NSString stringWithFormat:@"Torneios.svc/Disponiveis/%@/%@/%@", idLiga, idCampeonato, idJogador];
    [self logServicos:@"Path" text:path];
    
    [[AFAppDotNetAPIClient sharedClient] getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSArray *postsFromResponse = [JSON valueForKeyPath:@"DisponiveisResult"];
        if (block) {
            [self logServicos:@"postsFromResponse" text:postsFromResponse];
            block(postsFromResponse, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            [self logServicos:@"Path" text:path];
            block([NSArray array], error);
        }
    }];
}

// métodos da tela de confirmação de participação do torneio

- (void)buscaDadosConfirmacaoParticipacaoWithBlock:(NSNumber *)idTorneio
                constructingBodyWithBlock:(void (^)(NSDictionary *dados, NSError *error))block
{
    
    NSString *path = [NSString stringWithFormat:@"Torneios.svc/Torneio/%@", idTorneio];
    [self logServicos:@"Path" text:path];
    
    [[AFAppDotNetAPIClient sharedClient] getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSDictionary *postsFromResponse = [JSON valueForKeyPath:@"TorneioResult"];
        if (block) {
            [self logServicos:@"postsFromResponse" text:postsFromResponse];
            block(postsFromResponse, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            [self logServicos:@"Path" text:path];
            block([NSDictionary dictionary], error);
        }
    }];
}

- (void)confirmarParticipacaoWithBlock:(NSNumber *)idTorneio
                             idJogador:(NSNumber*)idJogador
                             indParticipar:(NSString*)indParticipar
                         constructingBodyWithBlock:(void (^)(NSString *result, NSError *error))block
{
    
    NSString *path = [NSString stringWithFormat:@"Torneios.svc/Inscricao/%@/%@/%@", idTorneio, idJogador, indParticipar];
    [self logServicos:@"Path" text:path];
    
    [[AFAppDotNetAPIClient sharedClient] getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSString *postsFromResponse = [JSON valueForKeyPath:@"InscricaoResult"];
        if (block) {
            [self logServicos:@"postsFromResponse" text:postsFromResponse];
            block(postsFromResponse, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            [self logServicos:@"Path" text:path];
            block(@"", error);
        }
    }];
}


@end
