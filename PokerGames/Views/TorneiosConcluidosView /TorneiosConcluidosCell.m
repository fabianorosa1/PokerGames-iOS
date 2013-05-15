//
//  TorneiosConcluidosCell.m
//  PokerGames
//
//  Created by Fabiano Rosa on 24/04/13.
//  Copyright (c) 2013 Fabiano Rosa. All rights reserved.
//

#import "TorneiosConcluidosCell.h"
#import "UIImageView+AFNetworking.h"

@implementation TorneiosConcluidosCell


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
    
    self.lblDataRealizacao.text = [_dados valueForKey:@"DataRealizacao"];
    self.lblNome.text = [_dados valueForKey:@"Nome"];
    self.lblQtInscritos.text = [_dados valueForKey:@"QtInscritos"];
    
    NSNumber *saldoValue = [_dados valueForKey:@"SaldoJack"];
    self.lblSaldoJack.text = [[PokerGamesUtil currencyFormatter] stringFromNumber:saldoValue];
    self.lblVencedor.text = [_dados valueForKey:@"Vencedor"];

    // seta a foto do jogador
    NSString *foto = [dados valueForKey:@"Foto"];
    if (foto && [foto isEqualToString:@""]) {
        [self.imgViewFoto setImage:[UIImage imageNamed:@"jogador.png"]];
    } else {
        [self.imgViewFoto setImageWithURL:[PokerGamesUtil buildUrlFoto:[dados valueForKey:@"Foto"]] placeholderImage:[PokerGamesUtil imgPlaceholder]];
    }
}

@end
