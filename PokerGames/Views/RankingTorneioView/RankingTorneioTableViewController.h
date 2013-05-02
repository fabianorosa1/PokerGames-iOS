//
//  RankingTorneioTableViewController.h
//  PokerGames
//
//  Created by Fabiano Rosa on 23/04/13.
//  Copyright (c) 2013 Fabiano Rosa. All rights reserved.
//

@interface RankingTorneioTableViewController : UITableViewController

@property (nonatomic, strong) IBOutlet UIView* viewHeader;
@property (nonatomic, strong) NSNumber* idTorneio;

@property (nonatomic, strong) IBOutlet UILabel* lblData;
@property (nonatomic, strong) IBOutlet UILabel* lblQtInscritos;
@property (nonatomic, strong) IBOutlet UILabel* lblSaldoJack;

@property (nonatomic, strong) IBOutlet UILabel* lblIncritos;

@end
