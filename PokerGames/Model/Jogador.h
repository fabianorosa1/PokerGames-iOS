//
//  Jogador.h
//  PokerGames
//
//  Created by Fabiano Rosa on 22/04/13.
//  Copyright (c) 2013 Fabiano Rosa. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Liga;

@interface Jogador : NSObject

@property (nonatomic, retain) NSString * apelido;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSNumber * idJogador;
@property (nonatomic, retain) NSString * nome;
@property (nonatomic, retain) NSString * status;
//@property (nonatomic, retain) NSString * urlFoto;
// relacionamento
@property (nonatomic, retain) NSNumber * idLiga;
@property (nonatomic, retain) Liga *liga;

- (id)initWithAttributes:(NSDictionary *)attributes;

+ (void)efetuaLoginPlayerWithBlock:(NSString *)user
                             passw:(NSString *)passw
                             constructingBodyWithBlock:(void (^)(Jogador *jogador, NSError *error))block;

+ (NSURL*) buildUrlFoto:(NSNumber*)idJogador;
+ (Jogador*) loadJogadorEntity;
- (void) insertJogadorEntity;
- (void) atualizaLigaCampeonatoJogadorEntity;
+ (void) excluirTodosJogadoresDependencias;

@end
