//
//  TorneiosDisponiveis.m
//  PokerGames
//
//  Created by Fabiano Rosa on 24/04/13.
//  Copyright (c) 2013 Fabiano Rosa. All rights reserved.
//

#import "TorneiosDisponiveisCell.h"

@implementation TorneiosDisponiveisCell


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
    self.lblQtInscritos.text = [_dados valueForKey:@"QtInscritos"];
    self.lblDataRealizacao.text = [_dados valueForKey:@"Data"];
    self.lblHoraRealizacao.text = [_dados valueForKey:@"Hora"];
    self.lblLocal.text = [_dados valueForKey:@"Local"];
    
    NSString *statusIncricao = [_dados valueForKey:@"Inscrito"];
    NSString *imgStatus = nil;
    
    if ([statusIncricao isEqualToString:@"S"]) {
        imgStatus = @"confirmado.png";
    } else if ([statusIncricao isEqualToString:@"N"]) {
        imgStatus = @"nao-confirmado.png";
    } else {
        imgStatus = @"pendente-confirmacao.png";
    }
    [self.imgViewStatus setImage:[UIImage imageNamed:imgStatus]];
}

@end
