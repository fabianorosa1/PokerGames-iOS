//
//  RankingCampeonatoTableViewController.h
//  PokerGames
//
//  Created by Fabiano Rosa on 23/04/13.
//  Copyright (c) 2013 Fabiano Rosa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Jogador.h"

@interface DetalhesJogadorTableViewController : UITableViewController

@property (nonatomic, strong) IBOutlet UIView* viewHeader;
@property (nonatomic, strong) IBOutlet UILabel* headerNomeCamp;

@property (nonatomic, strong) Jogador *jogador;

@end
