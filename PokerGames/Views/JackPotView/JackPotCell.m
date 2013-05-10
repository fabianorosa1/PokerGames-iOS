//
//  JackPotCell.m
//  PokerGames
//
//  Created by Fabiano Rosa on 24/04/13.
//  Copyright (c) 2013 Fabiano Rosa. All rights reserved.
//

#import "JackPotCell.h"
#import "UIImageView+AFNetworking.h"
#import "Jogador.h"

@implementation JackPotCell


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
    
    double valor = [[_dados valueForKey:@"Valor"] doubleValue];
    
    if (valor < 0) {
        self.lblValor.textColor = [UIColor redColor];
    } else {
        self.lblValor.textColor = [UIColor colorWithRed:(46/255.f) green:(139/255.f) blue:(87/255.f) alpha:1.0f];
    }
    self.lblValor.text = [[PokerGamesUtil currencyFormatter] stringFromNumber:[NSNumber numberWithDouble:valor]];
    
    self.lblDescricao.numberOfLines = 2;
    [self.lblDescricao setLineBreakMode:NSLineBreakByWordWrapping];
    self.lblDescricao.text = [_dados valueForKey:@"Descricao"];
    [self.lblDescricao sizeToFit];
    
    self.lblData.text = [_dados valueForKey:@"Data"];
}

@end
