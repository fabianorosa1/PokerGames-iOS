//
//  RankingTorneioCell.m
//  PokerGames
//
//  Created by Fabiano Rosa on 24/04/13.
//  Copyright (c) 2013 Fabiano Rosa. All rights reserved.
//

#import "RankingTorneioCell.h"
#import "UIImageView+AFNetworking.h"
#import <QuartzCore/QuartzCore.h>

@implementation RankingTorneioCell


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
    self.lblPontos.text = [NSString stringWithFormat:@"%@ pts", [_dados valueForKey:@"Pontuacao"]];
    self.lblNomeAlgoz.text = [_dados valueForKey:@"NomeAlgoz"];
    
    // verifica a posicao
    if (self.row == 0) {
        self.lblPosicao.hidden = true;
        self.imgViewPosicao.hidden = false;
        [self.imgViewPosicao setImage:[PokerGamesUtil imgPrimeiroLugar]];
    } else if (self.row == 1) {
        self.lblPosicao.hidden = true;
        self.imgViewPosicao.hidden = false;
        [self.imgViewPosicao setImage:[PokerGamesUtil imgSegundoLugar]];
    } else if (self.row == 2) {
        self.lblPosicao.hidden = true;
        self.imgViewPosicao.hidden = false;
        [self.imgViewPosicao setImage:[PokerGamesUtil imgTerceiroLugar]];
    } else {
        self.lblPosicao.hidden = false;
        self.imgViewPosicao.hidden = true;
        self.lblPosicao.text = [NSString stringWithFormat:@"%@º", [_dados valueForKey:@"Posicao"]];
    }

    // seta a foto do jogador
    [self.imgViewFoto setImageWithURL:[PokerGamesUtil buildUrlFoto:[_dados valueForKey:@"Foto"]] placeholderImage:[PokerGamesUtil imgPlaceholder]];
    
    NSNumber *saldoValue = [_dados valueForKey:@"Saldo"];
    double saldo = [saldoValue doubleValue];
    
    if (saldo < 0) {
        self.lblSaldo.textColor = [UIColor redColor];
    } else {
        self.lblSaldo.textColor = [UIColor colorWithRed:(46/255.f) green:(139/255.f) blue:(87/255.f) alpha:1.0f];
    }
    self.lblSaldo.text = [[PokerGamesUtil currencyFormatter] stringFromNumber:saldoValue];
}

@end
