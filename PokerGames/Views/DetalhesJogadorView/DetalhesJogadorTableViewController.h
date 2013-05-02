//
//  DetalhesJogadorTableViewController.h
//  PokerGames
//
//  Created by Fabiano Rosa on 23/04/13.
//  Copyright (c) 2013 Fabiano Rosa. All rights reserved.
//

#import "Jogador.h"

@interface DetalhesJogadorTableViewController : UITableViewController

@property (nonatomic, strong) IBOutlet UIView* viewHeader;
@property (nonatomic, strong) IBOutlet UILabel* headerNomeCamp;

@property (nonatomic, strong) IBOutlet UILabel* lblAlgoz;
@property (nonatomic, strong) IBOutlet UILabel* lblColocacao;
@property (nonatomic, strong) IBOutlet UILabel* lblITM;
@property (nonatomic, strong) IBOutlet UILabel* lblMedia;
@property (nonatomic, strong) IBOutlet UILabel* lblParticipacoes;
@property (nonatomic, strong) IBOutlet UILabel* lblPontos;
@property (nonatomic, strong) IBOutlet UILabel* lblSaldo;
@property (nonatomic, strong) IBOutlet UILabel* lblVitima;

@property (nonatomic, strong) Jogador *jogador;

@end
