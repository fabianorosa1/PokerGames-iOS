//
//  TorneiosDisponiveisCell.h
//  PokerGames
//
//  Created by Fabiano Rosa on 24/04/13.
//  Copyright (c) 2013 Fabiano Rosa. All rights reserved.
//

@interface  TorneiosDisponiveisCell : UITableViewCell
    
@property (nonatomic, weak) IBOutlet UILabel* lblNome;
@property (nonatomic, weak) IBOutlet UILabel* lblQtInscritos;
@property (nonatomic, weak) IBOutlet UILabel* lblDataRealizacao;
@property (nonatomic, weak) IBOutlet UILabel* lblHoraRealizacao;
@property (nonatomic, weak) IBOutlet UILabel* lblLocal;

@property (nonatomic, strong) NSDictionary *dados;

@end
