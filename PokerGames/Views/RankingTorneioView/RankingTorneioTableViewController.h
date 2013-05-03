//
//  RankingTorneioTableViewController.h
//  PokerGames
//
//  Created by Fabiano Rosa on 23/04/13.
//  Copyright (c) 2013 Fabiano Rosa. All rights reserved.
//

@interface RankingTorneioTableViewController : UITableViewController

@property (nonatomic, weak) IBOutlet UIView* viewHeader;
@property (nonatomic, weak) IBOutlet UILabel* lblTorneio;
@property (nonatomic, weak) IBOutlet UILabel* lblData;
@property (nonatomic, weak) IBOutlet UILabel* lblQtInscritos;
@property (nonatomic, weak) IBOutlet UILabel* lblSaldoJack;
@property (nonatomic, weak) IBOutlet UILabel* lblIncritos;

@property (nonatomic, strong) NSNumber* idTorneio;

@end
