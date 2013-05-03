//
//  CampeonatoTableViewController.h
//  PokerGames
//
//  Created by Fabiano Rosa on 21/04/13.
//  Copyright (c) 2013 Fabiano Rosa. All rights reserved.
//

#import "Liga.h"

@interface CampeonatoTableViewController : UITableViewController

@property (nonatomic, strong) IBOutlet UIView* viewHeader;
@property (nonatomic, strong) IBOutlet UILabel* lblLiga;
@property (nonatomic, strong) Liga *ligaSelecionada;

@end
