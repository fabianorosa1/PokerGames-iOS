//
//  MainViewController.m
//  PokerGames
//
//  Created by Fabiano Rosa on 22/04/13.
//  Copyright (c) 2013 Fabiano Rosa. All rights reserved.
//

#import "MainViewController.h"
#import "Jogador.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)awakeFromNib
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];

    self.menuViewController = [storyboard instantiateViewControllerWithIdentifier:@"Menu"];

    // configurações do menu
    self.limitMenuViewSize = YES;
    self.liveBlur = NO;
    
    // verifica se já está logado
    Jogador *jogador = [[PokerGamesFacade sharedInstance] loadJogadorEntity];
    
    if (jogador == nil) {
        [[PokerGamesFacade sharedInstance] setIsFirstTime:TRUE];
        //NSLog(@">>> Configuração inicial!");
        self.contentViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginJogador"];
    } else {
        [[PokerGamesFacade sharedInstance] setIsFirstTime:FALSE];
        //NSLog(@">>> Já configurado!");
        [[PokerGamesFacade sharedInstance] setJogadorLogin:jogador];
        
        // verifica se recebeu alguma notificacao via push
        if ([[UIApplication sharedApplication] applicationIconBadgeNumber] > 0) {
            self.contentViewController = [storyboard instantiateViewControllerWithIdentifier:@"TorneiosDisponiveis"];
        } else {
            self.contentViewController = [storyboard instantiateViewControllerWithIdentifier:@"RankingCampeonato"];
        }
    }
}

@end
