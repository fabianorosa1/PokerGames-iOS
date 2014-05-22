//
//  DetalhesJogadorCell.m
//  PokerGames
//
//  Created by Fabiano Rosa on 24/04/13.
//  Copyright (c) 2013 Fabiano Rosa. All rights reserved.
//

#import "DetalhesJogadorCell.h"
#import "UIImageView+AFNetworking.h"
#import <QuartzCore/QuartzCore.h>

@implementation DetalhesJogadorCell

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
    
    self.lblData.text = [_dados valueForKey:@"Data"];
    self.lblPontos.text = [NSString stringWithFormat:@"%@ pontos", [_dados valueForKey:@"Pontos"]];
    self.lblEtapa.text = [_dados valueForKey:@"Etapa"];
    
    NSNumber *posicaoValue = [_dados valueForKey:@"Posicao"];
    int posicao = [posicaoValue intValue];
    
    // verifica a posicao
    if (posicao == 1) {
        self.lblPosicao.hidden = true;
        self.imgViewPosicao.hidden = false;
        [self.imgViewPosicao setImage:[UIImage imageNamed:@"medal_award_gold"]];
    } else if (posicao == 2) {
        self.lblPosicao.hidden = true;
        self.imgViewPosicao.hidden = false;
        [self.imgViewPosicao setImage:[UIImage imageNamed:@"medal_award_silver"]];
    } else if (posicao == 3) {
        self.lblPosicao.hidden = true;
        self.imgViewPosicao.hidden = false;
        [self.imgViewPosicao setImage:[UIImage imageNamed:@"medal_award_bronze"]];
    } else {
        self.lblPosicao.hidden = false;
        self.imgViewPosicao.hidden = true;
        self.lblPosicao.text = [NSString stringWithFormat:@"%@º", [_dados valueForKey:@"Posicao"]];
    }
    
    NSNumber *saldoValue = [_dados valueForKey:@"Saldo"];
    double saldo = [saldoValue doubleValue];

    if (saldo < 0) {
        self.lblValor.textColor = [UIColor redColor];
    } else {
        self.lblValor.textColor = [UIColor colorWithRed:(46/255.f) green:(139/255.f) blue:(87/255.f) alpha:1.0f];
    }
    self.lblValor.text = [[PokerGamesUtil currencyFormatter] stringFromNumber:saldoValue];
}

@end
