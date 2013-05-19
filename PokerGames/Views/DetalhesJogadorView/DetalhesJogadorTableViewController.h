//
//  DetalhesJogadorTableViewController.h
//  PokerGames
//
//  Created by Fabiano Rosa on 23/04/13.
//  Copyright (c) 2013 Fabiano Rosa. All rights reserved.
//

#import "Jogador.h"

@interface DetalhesJogadorTableViewController : UITableViewController <UIGestureRecognizerDelegate>

@property (nonatomic, weak) IBOutlet UIView* viewHeader;
@property (nonatomic, weak) IBOutlet UILabel* lblJogador;
@property (nonatomic, weak) IBOutlet UILabel* lblApelido;
@property (nonatomic, weak) IBOutlet UILabel* lblCampeonato;
@property (nonatomic, weak) IBOutlet UIImageView* imgViewFoto;
@property (nonatomic, weak) IBOutlet UILabel* lblAlgoz;
@property (nonatomic, weak) IBOutlet UILabel* lblColocacao;
@property (nonatomic, weak) IBOutlet UILabel* lblITM;
@property (nonatomic, weak) IBOutlet UILabel* lblMedia;
@property (nonatomic, weak) IBOutlet UILabel* lblParticipacoes;
@property (nonatomic, weak) IBOutlet UILabel* lblPontos;
@property (nonatomic, weak) IBOutlet UILabel* lblSaldo;
@property (nonatomic, weak) IBOutlet UILabel* lblVitima;

@property (nonatomic, strong) Jogador *jogador;

@end
