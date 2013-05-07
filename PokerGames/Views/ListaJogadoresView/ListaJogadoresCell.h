//
//  ListaJogadoresCell.h
//  PokerGames
//
//  Created by Fabiano Rosa on 24/04/13.
//  Copyright (c) 2013 Fabiano Rosa. All rights reserved.
//

@interface  ListaJogadoresCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel* lblApelido;
@property (nonatomic, weak) IBOutlet UILabel* lblEmail;
@property (nonatomic, weak) IBOutlet UILabel* lblNome;
@property (nonatomic, weak) IBOutlet UILabel* lblFone;
@property (nonatomic, weak) IBOutlet UIImageView* imgViewFoto;
@property (nonatomic, weak) IBOutlet UIImageView* imgFicha;

@property (nonatomic, strong) Jogador *jogador;

@end
