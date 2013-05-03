//
//  RankingTorneioCell.h
//  PokerGames
//
//  Created by Fabiano Rosa on 24/04/13.
//  Copyright (c) 2013 Fabiano Rosa. All rights reserved.
//

@interface RankingTorneioCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel* lblNome;
@property (nonatomic, weak) IBOutlet UILabel* lblPontos;
@property (nonatomic, weak) IBOutlet UILabel* lblPosicao;
@property (nonatomic, weak) IBOutlet UIImageView* imgViewFoto;
@property (nonatomic, weak) IBOutlet UIImageView* imgViewPosicao;
@property (nonatomic, weak) IBOutlet UILabel* lblNomeAlgoz;
@property (nonatomic, weak) IBOutlet UILabel* lblSaldo;

@property (nonatomic, strong) NSDictionary *dados;

@property (nonatomic) NSInteger row;

@end
