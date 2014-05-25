//
//  PokerGamesFacade.m
//  PokerGames
//
//  Created by Fabiano Rosa on 02/05/13.
//  Copyright (c) 2013 Fabiano Rosa. All rights reserved.
//

#import "PokerGamesLocalFacade.h"
#import "Liga.h"
#import "AppDelegate.h"
#import "Campeonato.h"
#import <CoreData/CoreData.h>
#import "Ranking.h"

@implementation PokerGamesLocalFacade

@synthesize jogadorLogin, isDebugApp, isFirstTime, apnsTokenRegister;

#pragma mark Singleton Methods

+ (id)sharedInstance {
    static PokerGamesLocalFacade *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@"Instancia PokerGamesFacade LOCAL!");        
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    if (self = [super init]) {
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
    if (self.isDebugApp) {
        NSLog(@"%@: %@", label, text);
    }
}

#pragma mark - Métodos do Jogador

- (void)efetuaLogout {
    // limpa dados de configuracao
    [self excluirTodosJogadoresDependencias];
    
    // seta não configurado
    [self setIsFirstTime:TRUE];
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

- (void)efetuaLoginPlayerWithBlock:(NSString *)user
                             passw:(NSString *)passw
         constructingBodyWithBlock:(void (^)(Jogador *jogador, NSError *error))block
{
    NSArray *JSON = [self readDataFromJSONFile:@"CredencialJogador"];
    NSDictionary *postsFromResponse = [JSON valueForKeyPath:@"CredencialJogadorResult"];
    
    Jogador *jogador = [[Jogador alloc] initWithAttributes:postsFromResponse];
    [self logServicos:@"postsFromResponse" text:postsFromResponse];
    block(jogador, nil);
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
    
    NSArray *JSON = [self readDataFromJSONFile:@"Liga"];
    NSArray *postsFromResponse = [JSON valueForKeyPath:@"LigaResult"];
    [self logServicos:@"postsFromResponse" text:postsFromResponse];

    NSMutableArray *mutablePosts = [NSMutableArray arrayWithCapacity:[postsFromResponse count]];
    for (NSDictionary *attributes in postsFromResponse) {
        Liga *liga = [[Liga alloc] initWithAttributes:attributes];
        [mutablePosts addObject:liga];
    }
    block([NSArray arrayWithArray:mutablePosts], nil);
}

#pragma mark - Métodos do Campeonato

- (void)buscaCampeonatosLigaWithBlock:(NSNumber *)idLiga
            constructingBodyWithBlock:(void (^)(NSArray *campeonatos, NSError *error))block
{
    NSArray *JSON = [self readDataFromJSONFile:@"Campeonatos"];
    NSArray *postsFromResponse = [JSON valueForKeyPath:@"TodosResult"];
    [self logServicos:@"postsFromResponse" text:postsFromResponse];
        
    NSMutableArray *mutablePosts = [NSMutableArray arrayWithCapacity:[postsFromResponse count]];
    for (NSDictionary *attributes in postsFromResponse) {
        Campeonato *campeonato = [[Campeonato alloc] initWithAttributes:attributes];
        [mutablePosts addObject:campeonato];
    }
        
    block([NSArray arrayWithArray:mutablePosts], nil);
}

#pragma mark - Métodos das Views Controllers

- (void)buscaRankingCampeonatosWithBlock:(NSNumber *)idLiga
                            idCampeonato:(NSNumber *)idCampeonato
               constructingBodyWithBlock:(void (^)(NSArray *ranking, NSError *error))block
{
    
    NSArray *JSON = [self readDataFromJSONFile:@"RankingCampeonatos"];
    NSArray *postsFromResponse = [JSON valueForKeyPath:@"RankingResult"];
    [self logServicos:@"postsFromResponse" text:postsFromResponse];
        
    NSMutableArray *mutablePosts = [NSMutableArray arrayWithCapacity:[postsFromResponse count]];
    for (NSDictionary *attributes in postsFromResponse) {
        Ranking *ranking = [[Ranking alloc] initWithAttributes:attributes];
        [mutablePosts addObject:ranking];
    }
        
    block([NSArray arrayWithArray:mutablePosts], nil);
}

- (void)buscaResultadosTorneiosJogadorWithBlock:(NSNumber *)idLiga
                                   idCampeonato:(NSNumber *)idCampeonato
                                      idJogador:(NSNumber *)idJogador
                      constructingBodyWithBlock:(void (^)(NSArray *resultados, NSError *error))block
{
        NSArray *JSON = [self readDataFromJSONFile:@"ResultadosTorneios"];
        NSArray *postsFromResponse = [JSON valueForKeyPath:@"ResultadosTorneiosResult"];
        [self logServicos:@"postsFromResponse" text:postsFromResponse];
        block(postsFromResponse, nil);
}

- (void)buscaCabecalhoResultadosWithBlock:(NSNumber *)idLiga
                             idCampeonato:(NSNumber *)idCampeonato
                                idJogador:(NSNumber *)idJogador
                constructingBodyWithBlock:(void (^)(NSDictionary *cabecalho, NSError *error))block
{
    NSArray *JSON = [self readDataFromJSONFile:@"ResumoResultados"];
    NSDictionary *postsFromResponse = [JSON valueForKeyPath:@"ResumoResultadosResult"];
    
    [self logServicos:@"postsFromResponse" text:postsFromResponse];
    block(postsFromResponse, nil);
}

- (void)buscaTorneiosConcluidosWithBlock:(NSNumber *)idLiga
                            idCampeonato:(NSNumber *)idCampeonato
               constructingBodyWithBlock:(void (^)(NSArray *torneios, NSError *error))block
{
    NSArray *JSON = [self readDataFromJSONFile:@"TorneiosInativos"];
    NSArray *postsFromResponse = [JSON valueForKeyPath:@"InativosResult"];
    
    [self logServicos:@"postsFromResponse" text:postsFromResponse];
    block(postsFromResponse, nil);
}

- (void)buscaCabecalhoRankingWithBlock:(NSNumber *)idTorneio
             constructingBodyWithBlock:(void (^)(NSDictionary *cabecalho, NSError *error))block
{
    
    NSArray *JSON = [self readDataFromJSONFile:@"TorneioCabecalho"];
    NSDictionary *postsFromResponse = [JSON valueForKeyPath:@"CabecalhoResult"];
    [self logServicos:@"postsFromResponse" text:postsFromResponse];
    block(postsFromResponse, nil);
}

- (void)buscaRankingTorneioWithBlock:(NSNumber *)idTorneio
           constructingBodyWithBlock:(void (^)(NSArray *ranking, NSError *error))block
{
    NSArray *JSON = [self readDataFromJSONFile:@"TorneioRanking"];
    NSArray *postsFromResponse = [JSON valueForKeyPath:@"RankingResult"];
    [self logServicos:@"postsFromResponse" text:postsFromResponse];
    block(postsFromResponse, nil);
}

// métodos da tela do JackPot

- (void)buscaCabecalhoJackPotWithBlock:(NSNumber *)idLiga
             constructingBodyWithBlock:(void (^)(NSString *saldo, NSError *error))block
{
    NSArray *JSON = [self readDataFromJSONFile:@"LigaSaldoJack"];
    NSString *postsFromResponse = [JSON valueForKeyPath:@"SaldoResult"];
    [self logServicos:@"postsFromResponse" text:postsFromResponse];
    block(postsFromResponse, nil);
}

- (void)buscaJackPotWithBlock:(NSNumber *)idLiga
           constructingBodyWithBlock:(void (^)(NSArray *jackpots, NSError *error))block
{
    NSArray *JSON = [self readDataFromJSONFile:@"LigaExtratoJack"];
    NSArray *postsFromResponse = [JSON valueForKeyPath:@"ExtratoResult"];
    [self logServicos:@"postsFromResponse" text:postsFromResponse];
    block(postsFromResponse, nil);
}

// metodos da tela de lista de jogadores

- (void)buscaListaJogadoresPotWithBlock:(NSNumber *)idLiga
    constructingBodyWithBlock:(void (^)(NSArray *jogadores, NSError *error))block
{
    NSArray *JSON = [self readDataFromJSONFile:@"Jogadores"];
    NSArray *postsFromResponse = [JSON valueForKeyPath:@"TodosResult"];
    
    NSMutableArray *mutablePosts = [NSMutableArray arrayWithCapacity:[postsFromResponse count]];
    for (NSDictionary *attributes in postsFromResponse) {
        Jogador *jogador = [[Jogador alloc] initWithAttributes:attributes];
        [mutablePosts addObject:jogador];
    }
    
    block([NSArray arrayWithArray:mutablePosts], nil);
}

- (MFMailComposeViewController *) enviaEmailJogador:(NSString*)email delegate:(id<MFMailComposeViewControllerDelegate>)delegate {
    // envia email para o jogador
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = delegate;
        [mailer setSubject:@"Mensagem do PokerGames"];
        NSArray *toRecipients = [NSArray arrayWithObjects:email, nil];
        [mailer setToRecipients:toRecipients];
        
        UIImage *myImage = [UIImage imageNamed:@"iPhoneIcon_Big.png"];
        NSData *imageData = UIImagePNGRepresentation(myImage);
        [mailer addAttachmentData:imageData mimeType:@"image/png" fileName:@"pokergames"];
        
        NSString *emailBody = [NSString stringWithFormat:@"Olá, vamos jogar poker?\n\nAt,\n%@", [self jogadorLogin].nome];
        [mailer setMessageBody:emailBody isHTML:NO];
        
        return mailer;
    }
    return nil;
}

- (ABRecordRef)retornaContatoJogador:(Jogador*)jogador {
        UIImage *imgContact = [UIImage imageWithData:[NSData dataWithContentsOfURL:[PokerGamesUtil retornaUrlFoto:jogador.foto]]];
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

        return aRecord;
}

- (void) gravaNovoContato:(ABRecordRef)person {
    CFErrorRef error = NULL;
    NSUInteger addressbookId = 0;
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(nil, nil);
    ABAddressBookAddRecord (addressBook, person, &error);
    if (error != NULL) {
        NSLog(@"ABAddressBookAddRecord %@", error);
    }
    error = NULL;
    
    if(ABAddressBookSave ( addressBook,  &error)){
        addressbookId =  ABRecordGetRecordID (person);
    }
    
    if (error != NULL) {
        NSLog(@"ABAddressBookSave %@", error);
    }
    
    [self logServicos:@"Contato criado - AddressbookId" text:[NSString stringWithFormat:@"%lu", (unsigned long)addressbookId]];
    
    CFRelease(person);
    CFRelease(addressBook);
}

// metodos da tela de torneios disponiveis

- (void)buscaTorneiosDisponiveisWithBlock:(NSNumber *)idLiga
                            idCampeonato:(NSNumber *)idCampeonato
                            idJogador:(NSNumber *)idJogador
               constructingBodyWithBlock:(void (^)(NSArray *torneios, NSError *error))block
{
    NSArray *JSON = [self readDataFromJSONFile:@"TorneiosDisponiveis"];
    NSArray *postsFromResponse = [JSON valueForKeyPath:@"DisponiveisResult"];
    [self logServicos:@"postsFromResponse" text:postsFromResponse];
    block(postsFromResponse, nil);
}

// métodos da tela de confirmação de participação do torneio

- (void)buscaDadosConfirmacaoParticipacaoWithBlock:(NSNumber *)idTorneio
                constructingBodyWithBlock:(void (^)(NSDictionary *dados, NSError *error))block
{
    NSArray *JSON = [self readDataFromJSONFile:@"Torneio"];
    NSDictionary *postsFromResponse = [JSON valueForKeyPath:@"TorneioResult"];
    [self logServicos:@"postsFromResponse" text:postsFromResponse];
    block(postsFromResponse, nil);
}

- (void)confirmarParticipacaoWithBlock:(NSNumber *)idTorneio
                             idJogador:(NSNumber*)idJogador
                             indParticipar:(NSString*)indParticipar
                         constructingBodyWithBlock:(void (^)(NSString *result, NSError *error))block
{
    block(@"true", nil);
}

// métodos da tela de perfil do jogador

- (void)buscaPerfilJogadorWithBlock:(NSNumber *)idJogador
                         constructingBodyWithBlock:(void (^)(NSDictionary *dados, NSError *error))block
{
    NSArray *JSON = [self readDataFromJSONFile:@"Jogador"];
    NSDictionary *postsFromResponse = [JSON valueForKeyPath:@"JogadorResult"];
    [self logServicos:@"postsFromResponse" text:postsFromResponse];
    block(postsFromResponse, nil);
}

// metodos da tela de jogadores confirmados

- (void)buscaJogadoresConfirmadosWithBlock:(NSNumber *)idTorneio
                constructingBodyWithBlock:(void (^)(NSArray *jogadores, NSError *error))block
{
    NSArray *JSON = [self readDataFromJSONFile:@"JogadoresConfirmados"];
    NSArray *postsFromResponse = [JSON valueForKeyPath:@"ConfirmadosResult"];
    [self logServicos:@"postsFromResponse" text:postsFromResponse];
    block(postsFromResponse, nil);
}

// métodos de push

- (void)registraDispositivoWithBlock:(NSString *)apnsToken
                             deviceUUID:(NSString*)deviceUUID
                         idJogador:(NSNumber*)idJogador
             constructingBodyWithBlock:(void (^)(NSString *result, NSError *error))block
{
    block(@"", nil);
}


// Where the magic happens
- (NSMutableArray*)readDataFromJSONFile:(NSString*)filename {
    NSMutableArray *jsonArray = [[NSMutableArray alloc] init];
    NSError *fileError;
    
    // Create a JSON String from the JSON file contents
    NSString *filePath = [[NSBundle mainBundle] pathForResource:filename ofType:@"json"];
    NSString *jsonString = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&fileError];
    if (fileError)
        NSLog(@"Error parsing JSON File: %@", fileError);
    
    // If we don't have a valid JSON object, return the empty array
    if ([NSJSONSerialization isValidJSONObject:jsonString])
        return jsonArray;
    
    // Create the JSON Object from the string
    NSError *error;
    jsonArray = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
    if (!jsonArray)
        NSLog(@"Error parsing JSON: %@", error);
    
    return jsonArray;
}

@end
