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
#import "Jogador.h"

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
    
    self.lblNome.text = [_dados valueForKey:@"Nome"];
    self.lblPontos.text = [NSString stringWithFormat:@"%@ pontos", [_dados valueForKey:@"Pontos"]];
    
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
    [self.imgViewFoto setImageWithURL:[Jogador buildUrlFoto:[_dados valueForKey:@"IdJogador"]] placeholderImage:[PokerGamesUtil imgPlaceholder]];

/* PROBLEMA DE PERFORMANCE NESTE BLOCO
    // adiciona canto arredonado
    self.imgViewFoto.layer.cornerRadius = 5.0;
    self.imgViewFoto.layer.masksToBounds = YES;
    
    // adiciona borda
    self.imgViewFoto.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.imgViewFoto.layer.borderWidth = 1.0;  
*/ 
}

@end
