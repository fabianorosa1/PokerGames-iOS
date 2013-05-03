//
//  TorneiosConcluidosCell.h
//  PokerGames
//
//  Created by Fabiano Rosa on 24/04/13.
//  Copyright (c) 2013 Fabiano Rosa. All rights reserved.
//

@interface TorneiosConcluidosCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView* imgViewFoto;
@property (nonatomic, weak) IBOutlet UILabel* lblDataRealizacao;
@property (nonatomic, weak) IBOutlet UILabel* lblNome;
@property (nonatomic, weak) IBOutlet UILabel* lblQtInscritos;
@property (nonatomic, weak) IBOutlet UILabel* lblSaldoJack;
@property (nonatomic, weak) IBOutlet UILabel* lblVencedor;

@property (nonatomic, strong) NSDictionary *dados;

@end
