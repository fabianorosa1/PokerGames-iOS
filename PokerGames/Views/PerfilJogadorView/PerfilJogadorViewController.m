//
//  PerfilJogadorViewController.m
//  PokerGames
//
//  Created by Fabiano Rosa on 03/05/13.
//  Copyright (c) 2013 Fabiano Rosa. All rights reserved.
//

#import "PerfilJogadorViewController.h"
#import "ECSlidingViewController.h"
#import "MenuViewController.h"
#import "ADVTheme.h"
#import "MBProgressHUD.h"
#import "UIImageView+AFNetworking.h"

@interface PerfilJogadorViewController ()

@end

@implementation PerfilJogadorViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // configura o header
    id <ADVTheme> theme = [ADVThemeManager sharedTheme];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[theme viewBackground]]];
    
    [self.btnOpcoes setBackgroundImage:[theme colorButtonBackgroundForState:UIControlStateNormal] forState:UIControlStateNormal];
    [self.btnOpcoes setBackgroundImage:[theme colorButtonBackgroundForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];

    // verifica se foi chamado do menu
    if (!self.idJogadorParametro) {
        // botao de configuracoes
        UIBarButtonItem *btnMenu = [[UIBarButtonItem alloc]
                                    initWithImage:[PokerGamesUtil menuImage]
                                    style:UIBarButtonItemStyleBordered
                                    target:self
                                    action:@selector(configAction)];
        self.navigationItem.leftBarButtonItem = btnMenu;
    }
    
    [self buscaPerfilJogador];
}

-(IBAction)configAction
{
    [self.slidingViewController anchorTopViewTo:ECRight];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // verifica se foi chamado do menu
    if (!self.idJogadorParametro) {
        if (![self.slidingViewController.underLeftViewController isKindOfClass:[MenuViewController class]]) {
            self.slidingViewController.underLeftViewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"Menu"];
        }
        
        [self.navigationController.view addGestureRecognizer:self.slidingViewController.panGesture];        
    }
}

-(IBAction)opcoesPressed:(id)sender {
    
}

- (void) buscaPerfilJogador {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Buscando perfil";
    
    NSNumber *idJogador = nil;
    if (self.idJogadorParametro) {
        idJogador = self.idJogadorParametro;
    } else {
        idJogador = [[PokerGamesFacade sharedInstance] jogadorLogin].idJogador;
    }
    
    // busca dados da participacao do torneio
    [[PokerGamesFacade sharedInstance] buscaPerfilJogadorWithBlock:idJogador
                        constructingBodyWithBlock:^(NSDictionary *dados, NSError *error) {
                                                            
        [hud hide:YES];
                                                            
        if (error) {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Erro", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
        } else {
            // dados
            self.lblNome.text = [dados valueForKey:@"Nome"];
            self.lblApelido.text = [dados valueForKey:@"Apelido"];
            self.lblTelefone.text = [dados valueForKey:@"Telefone"];
            self.lblEmail.text = [dados valueForKey:@"Email"];
            self.lblNascimento.text = [dados valueForKey:@"Nascimento"];
            self.lblNaturalidade.text = [dados valueForKey:@"Naturalidade"];
            
            // seta a foto do jogador
            [self.imgViewFoto setImageWithURL:[PokerGamesUtil buildUrlFoto:[dados valueForKey:@"Foto"]] placeholderImage:[PokerGamesUtil imgPlaceholder]];
        }
    }];
}

@end
