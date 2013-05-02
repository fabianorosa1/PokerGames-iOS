//
//  TorneiosConcluidosCell.h
//  PokerGames
//
//  Created by Fabiano Rosa on 24/04/13.
//  Copyright (c) 2013 Fabiano Rosa. All rights reserved.
//

@interface TorneiosConcluidosCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIImageView* imgViewFoto;
@property (nonatomic, strong) IBOutlet UILabel* lblDataRealizacao;
@property (nonatomic, strong) IBOutlet UILabel* lblNome;
@property (nonatomic, strong) IBOutlet UILabel* lblQtInscritos;
@property (nonatomic, strong) IBOutlet UILabel* lblSaldoJack;
@property (nonatomic, strong) IBOutlet UILabel* lblVencedor;

@property (nonatomic, strong) NSDictionary *dados;

@end
