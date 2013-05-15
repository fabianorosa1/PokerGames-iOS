//
//  PerfilJogadorViewController.h
//  PokerGames
//
//  Created by Fabiano Rosa on 03/05/13.
//  Copyright (c) 2013 Fabiano Rosa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <AddressBookUI/AddressBookUI.h>

@interface PerfilJogadorViewController : UIViewController <UIGestureRecognizerDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, ABNewPersonViewControllerDelegate>

@property (nonatomic, weak) IBOutlet UILabel* lblNome;
@property (nonatomic, weak) IBOutlet UILabel* lblApelido;
@property (nonatomic, weak) IBOutlet UILabel* lblEmail;
@property (nonatomic, weak) IBOutlet UILabel* lblNascimento;
@property (nonatomic, weak) IBOutlet UILabel* lblNaturalidade;
@property (nonatomic, weak) IBOutlet UILabel* lblTelefone;
@property (nonatomic, weak) IBOutlet UIImageView* imgViewFoto;

@property (nonatomic, weak) IBOutlet UIButton *btnOpcoes;

@property (nonatomic, strong) NSNumber* idJogadorParametro;

-(IBAction)opcoesPressed:(id)sender;

@end
