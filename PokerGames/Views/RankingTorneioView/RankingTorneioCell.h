//
//  RankingTorneioCell.h
//  PokerGames
//
//  Created by Fabiano Rosa on 24/04/13.
//  Copyright (c) 2013 Fabiano Rosa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RankingTorneioCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel* lblNome;
@property (nonatomic, strong) IBOutlet UILabel* lblPontos;
@property (nonatomic, strong) IBOutlet UILabel* lblPosicao;
@property (nonatomic, strong) IBOutlet UIImageView* imgViewFoto;
@property (nonatomic, strong) IBOutlet UIImageView* imgViewPosicao;

@property (nonatomic, strong) IBOutlet UILabel* lblNomeAlgoz;
@property (nonatomic, strong) IBOutlet UILabel* lblSaldo;

@property (nonatomic, strong) NSDictionary *dados;

@property (nonatomic) NSInteger row;

@end
