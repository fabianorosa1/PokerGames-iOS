//
//  RankingCampeonatoJogadorCell.h
//  PokerGames
//
//  Created by Fabiano Rosa on 24/04/13.
//  Copyright (c) 2013 Fabiano Rosa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetalhesJogadorCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel* lblPosicao;
@property (nonatomic, strong) IBOutlet UILabel* lblEtapa;
@property (nonatomic, strong) IBOutlet UILabel* lblPontos;
@property (nonatomic, strong) IBOutlet UILabel* lblData;
@property (nonatomic, strong) IBOutlet UILabel* lblValor;
@property (nonatomic, strong) IBOutlet UIImageView* imgViewPosicao;

@property (nonatomic, strong) NSDictionary *dados;


@end
