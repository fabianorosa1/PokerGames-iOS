//
//  PokerGamesFacade.h
//  PokerGames
//
//  Created by Fabiano Rosa on 02/05/13.
//  Copyright (c) 2013 Fabiano Rosa. All rights reserved.
//

#import "Jogador.h"
#import <MessageUI/MessageUI.h>
#import <AddressBook/AddressBook.h>

@interface PokerGamesFacade : NSObject

@property (strong, nonatomic) Jogador *jogadorLogin;
@property (nonatomic) BOOL isFirstTime;
@property (nonatomic) BOOL isDebugApp;

+ (NSString*) paramDebugApp;

#pragma mark Singleton Methods

+ (id)sharedInstance;

#pragma mark - Métodos do Jogador

- (void)efetuaLoginPlayerWithBlock:(NSString *)user
                             passw:(NSString *)passw
         constructingBodyWithBlock:(void (^)(Jogador *jogador, NSError *error))block;

- (void) efetuaLogout;
- (Jogador*) loadJogadorEntity;
- (void)insertJogadorEntity:(Jogador*)jogador;
- (void) atualizaLigaCampeonatoJogadorEntity:(Jogador*)jogador;
- (void) excluirTodosJogadoresDependencias;

#pragma mark - Métodos da Liga

- (void)buscaLigasPlayerWithBlock:(NSNumber *)idPlayer
        constructingBodyWithBlock:(void (^)(NSArray *ligas, NSError *error))block;

#pragma mark - Métodos do Campeonato

- (void)buscaCampeonatosLigaWithBlock:(NSNumber *)idLiga
            constructingBodyWithBlock:(void (^)(NSArray *campeonatos, NSError *error))block;

#pragma mark - Métodos dos Views Controllers

- (void)buscaRankingCampeonatosWithBlock:(NSNumber *)idLiga
                            idCampeonato:(NSNumber *)idCampeonato
               constructingBodyWithBlock:(void (^)(NSArray *ranking, NSError *error))block;

- (void)buscaResultadosTorneiosJogadorWithBlock:(NSNumber *)idLiga
                                   idCampeonato:(NSNumber *)idCampeonato
                                      idJogador:(NSNumber *)idJogador
                      constructingBodyWithBlock:(void (^)(NSArray *resultados, NSError *error))block;

- (void)buscaCabecalhoResultadosWithBlock:(NSNumber *)idLiga
                             idCampeonato:(NSNumber *)idCampeonato
                                idJogador:(NSNumber *)idJogador
                constructingBodyWithBlock:(void (^)(NSDictionary *cabecalho, NSError *error))block;

- (void)buscaTorneiosConcluidosWithBlock:(NSNumber *)idLiga
                            idCampeonato:(NSNumber *)idCampeonato
               constructingBodyWithBlock:(void (^)(NSArray *torneios, NSError *error))block;


- (void)buscaCabecalhoRankingWithBlock:(NSNumber *)idTorneio
             constructingBodyWithBlock:(void (^)(NSDictionary *cabecalho, NSError *error))block;

- (void)buscaRankingTorneioWithBlock:(NSNumber *)idTorneio
           constructingBodyWithBlock:(void (^)(NSArray *ranking, NSError *error))block;

// métodos da tela do JackPot

- (void)buscaCabecalhoJackPotWithBlock:(NSNumber *)idLiga
             constructingBodyWithBlock:(void (^)(NSString *saldo, NSError *error))block;

- (void)buscaJackPotWithBlock:(NSNumber *)idLiga
    constructingBodyWithBlock:(void (^)(NSArray *jackpots, NSError *error))block;

// metodos da tela de lista de jogadores

- (void)buscaListaJogadoresPotWithBlock:(NSNumber *)idLiga
              constructingBodyWithBlock:(void (^)(NSArray *jogadores, NSError *error))block;

- (MFMailComposeViewController *) enviaEmailJogador:(NSString*)email delegate:(id<MFMailComposeViewControllerDelegate>)delegate;

- (ABRecordRef)retornaContatoJogador:(Jogador*)jogador;
- (void) gravaNovoContato:(ABRecordRef)person;

// metodos da tela de torneios disponiveis

- (void)buscaTorneiosDisponiveisWithBlock:(NSNumber *)idLiga
                             idCampeonato:(NSNumber *)idCampeonato
                                idJogador:(NSNumber *)idJogador
                constructingBodyWithBlock:(void (^)(NSArray *torneios, NSError *error))block;

// métodos da tela de confirmação de participação do torneio

- (void)buscaDadosConfirmacaoParticipacaoWithBlock:(NSNumber *)idTorneio
                         constructingBodyWithBlock:(void (^)(NSDictionary *dados, NSError *error))block;

- (void)confirmarParticipacaoWithBlock:(NSNumber *)idTorneio
                             idJogador:(NSNumber*)idJogador
                         indParticipar:(NSString*)indParticipar
             constructingBodyWithBlock:(void (^)(NSString *result, NSError *error))block;

// métodos da tela de perfil do jogador

- (void)buscaPerfilJogadorWithBlock:(NSNumber *)idJogador
          constructingBodyWithBlock:(void (^)(NSDictionary *dados, NSError *error))block;

@end
