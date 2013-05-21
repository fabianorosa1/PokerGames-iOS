//
//  JogadoresConfirmadosCell.h
//  PokerGames
//
//  Created by Fabiano Rosa on 24/04/13.
//  Copyright (c) 2013 Fabiano Rosa. All rights reserved.
//

@interface  JogadoresConfirmadosCell : UITableViewCell
    
@property (nonatomic, weak) IBOutlet UILabel* lblApelido;
@property (nonatomic, weak) IBOutlet UILabel* lblNome;
@property (nonatomic, weak) IBOutlet UIImageView* imgViewFoto;
@property (nonatomic, weak) IBOutlet UIImageView* imgViewStatus;

@property (nonatomic, strong) NSDictionary *dados;

@end
