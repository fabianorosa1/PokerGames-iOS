//
//  ConfirmarParticipacaoViewController.h
//  PokerGames
//
//  Created by Fabiano Rosa on 09/05/13.
//  Copyright (c) 2013 Fabiano Rosa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>

@interface ConfirmarParticipacaoViewController : UIViewController <UIAlertViewDelegate, EKEventEditViewDelegate>

@property (nonatomic, weak) IBOutlet UIView* viewHeader;

@property (nonatomic, weak) IBOutlet UILabel* lblNome;
@property (nonatomic, weak) IBOutlet UILabel* lblContato;
@property (nonatomic, weak) IBOutlet UILabel* lblData;
@property (nonatomic, weak) IBOutlet UILabel* lblEndereco;
@property (nonatomic, weak) IBOutlet UILabel* lblHora;
@property (nonatomic, weak) IBOutlet UILabel* lblLocal;
@property (nonatomic, weak) IBOutlet UILabel* lblQtInscritos;
@property (nonatomic, weak) IBOutlet UILabel* lblVlAddOn;
@property (nonatomic, weak) IBOutlet UILabel* lblVlBuyIn;
@property (nonatomic, weak) IBOutlet UILabel* lblVlRebuy;
@property (nonatomic, weak) IBOutlet UILabel* lblVlEliminacao;

@property (nonatomic, weak) IBOutlet UIButton *btnParticipar;
@property (nonatomic, weak) IBOutlet UIButton *btnNaoParticipar;
@property (nonatomic, weak) IBOutlet UIButton *btnListaJogadores;

@property (nonatomic, strong) NSDictionary* dicDadosConfirmacao;

-(IBAction)participarPressed:(id)sender;
-(IBAction)NaoParticiparPressed:(id)sender;

@end
