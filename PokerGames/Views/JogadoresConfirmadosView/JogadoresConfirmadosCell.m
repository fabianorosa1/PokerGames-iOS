//
//  JogadoresConfirmados.m
//  PokerGames
//
//  Created by Fabiano Rosa on 24/04/13.
//  Copyright (c) 2013 Fabiano Rosa. All rights reserved.
//

#import "JogadoresConfirmadosCell.h"

@implementation JogadoresConfirmadosCell


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
    self.lblApelido.text = [_dados valueForKey:@"Apelido"];
    
    NSString *statusIncricao = [_dados valueForKey:@"Flag"];
    NSString *imgStatus = nil;
    
    if ([statusIncricao isEqualToString:@"S"]) {
        imgStatus = @"confirmado.png";
    } else if ([statusIncricao isEqualToString:@"N"]) {
        imgStatus = @"pendente-confirmacao.png";
    }
    [self.imgViewStatus setImage:[UIImage imageNamed:imgStatus]];
    
    // seta a foto do jogador
    [PokerGamesUtil setaImagemJogador:self.imgViewFoto foto:[_dados valueForKey:@"Foto"]];
}

@end
