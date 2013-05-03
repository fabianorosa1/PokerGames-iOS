//
//  JackPotCell.h
//  PokerGames
//
//  Created by Fabiano Rosa on 24/04/13.
//  Copyright (c) 2013 Fabiano Rosa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JackPotCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel* lblValor;
@property (nonatomic, weak) IBOutlet UILabel* lblData;
@property (nonatomic, weak) IBOutlet UILabel* lblDescricao;

@property (nonatomic, strong) NSDictionary *dados;

@end
