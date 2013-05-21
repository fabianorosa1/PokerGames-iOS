//
//  TorneiosDisponiveisTableViewController.h
//  PokerGames
//
//  Created by Fabiano Rosa on 03/05/13.
//  Copyright (c) 2013 Fabiano Rosa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JogadoresConfirmadosTableViewController : UITableViewController

@property (nonatomic, weak) IBOutlet UIView* viewHeader;

@property (nonatomic, weak) IBOutlet UILabel* lblNome;
@property (nonatomic, weak) IBOutlet UILabel* lblData;
@property (nonatomic, weak) IBOutlet UILabel* lblHora;

@property (nonatomic, strong) NSNumber* idTorneio;
@property (nonatomic, strong) NSString* nomeTorneio;
@property (nonatomic, strong) NSString* dataTorneio;
@property (nonatomic, strong) NSString* horaTorneio;

@end
