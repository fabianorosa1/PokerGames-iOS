//
//  RankingCampeonatoJogadorCell.m
//  PokerGames
//
//  Created by Fabiano Rosa on 24/04/13.
//  Copyright (c) 2013 Fabiano Rosa. All rights reserved.
//

#import "RankingCampeonatoJogadorCell.h"
#import "UIImageView+AFNetworking.h"

static UIImage* imgPrimeiro = nil;
static UIImage* imgSegundo = nil;
static UIImage* imgTerceiro = nil;

@implementation RankingCampeonatoJogadorCell

+(void)initialize
{
    imgPrimeiro = [UIImage imageNamed:@"primeiro.png"];
    imgSegundo = [UIImage imageNamed:@"segundo.png"];
    imgTerceiro = [UIImage imageNamed:@"terceiro.png"];
}

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

- (void)setDados:(NSDictionary *)dados
{
    _dados = dados;
    
    self.lblNome.text = [_dados valueForKey:@"Nome"];
    self.lblPontos.text = [NSString stringWithFormat:@"%@ pontos", [_dados valueForKey:@"Pontos"]];

    self.lblPosicao.hidden = true;
    self.imgViewPosicao.hidden = false;
    
    // verifica a posicao
    if (self.row == 0) {
        [self.imgViewPosicao setImage:imgPrimeiro];
    } else if (self.row == 1) {
        [self.imgViewPosicao setImage:imgSegundo];
    } else if (self.row == 2) {
        [self.imgViewPosicao setImage:imgTerceiro];
    } else {
        self.lblPosicao.hidden = false;
        self.imgViewPosicao.hidden = true;
        self.lblPosicao.text = [NSString stringWithFormat:@"%@º", [_dados valueForKey:@"Posicao"]];
    }
    
    // seta a foto do jogador
    NSURL *urlFoto = [NSURL URLWithString:[_dados valueForKey:@"Foto"]];
    [self.imgViewFoto setImageWithURL:urlFoto placeholderImage:[UIImage imageNamed:@"profile-image-placeholder"]];
    
    [self setNeedsLayout];
}

@end
