//
//  RankingCampeonatoJogadorCell.m
//  PokerGames
//
//  Created by Fabiano Rosa on 24/04/13.
//  Copyright (c) 2013 Fabiano Rosa. All rights reserved.
//

#import "RankingCampeonatoJogadorCell.h"
#import "UIImageView+AFNetworking.h"

@implementation RankingCampeonatoJogadorCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setRanking:(Ranking *)ranking
{
    _ranking = ranking;
    
    self.lblNome.text = ranking.nome;
    self.lblPontos.text = [NSString stringWithFormat:@"%@ pontos", ranking.pontos];
    
    // verifica a posicao
    if (self.row == 0) {
        self.lblPosicao.hidden = true;
        self.imgViewPosicao.hidden = false;
        [self.imgViewPosicao setImage:[UIImage imageNamed:@"medal_award_gold"]];
    } else if (self.row == 1) {
        self.lblPosicao.hidden = true;
        self.imgViewPosicao.hidden = false;
        [self.imgViewPosicao setImage:[UIImage imageNamed:@"medal_award_silver"]];
    } else if (self.row == 2) {
        self.lblPosicao.hidden = true;
        self.imgViewPosicao.hidden = false;
        [self.imgViewPosicao setImage:[UIImage imageNamed:@"medal_award_bronze"]];
    } else {
        self.lblPosicao.hidden = false;
        self.imgViewPosicao.hidden = true;
        self.lblPosicao.text = [NSString stringWithFormat:@"%@º", ranking.posicao];
    }

    // arredonda a imagem
    self.imgViewFoto.layer.masksToBounds = YES;
    self.imgViewFoto.layer.cornerRadius = 22.0;

    // seta a foto do jogador
    [PokerGamesUtil setaImagemJogador:self.imgViewFoto foto:ranking.foto];

}

@end
