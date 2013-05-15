//
//  ListaJogadoresCell.m
//  PokerGames
//
//  Created by Fabiano Rosa on 24/04/13.
//  Copyright (c) 2013 Fabiano Rosa. All rights reserved.
//

#import "ListaJogadoresCell.h"
#import "UIImageView+AFNetworking.h"
#import <QuartzCore/QuartzCore.h>

@implementation ListaJogadoresCell


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

- (void)setJogador:(Jogador *)jogador
{
    _jogador = jogador;
    
    self.lblNome.text = jogador.nome;
    self.lblApelido.text = jogador.apelido;
    self.lblFone.text = jogador.fone;
    
    [self.imgFicha setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.jpg", jogador.imgClas]]];
    
    // verifica o status
    if ([jogador.status caseInsensitiveCompare:@"I"] == NSOrderedSame) {
        self.lblNome.textColor = [UIColor redColor];
    } else {
        self.lblNome.textColor = [UIColor blackColor];
    }
    
    // seta a foto do jogador
    if (jogador.foto && [jogador.foto isEqualToString:@""]) {
        [self.imgViewFoto setImage:[UIImage imageNamed:@"jogador.png"]];
    } else {
        [self.imgViewFoto setImageWithURL:[PokerGamesUtil buildUrlFoto:jogador.foto] placeholderImage:[PokerGamesUtil imgPlaceholder]];
    }
}

@end
