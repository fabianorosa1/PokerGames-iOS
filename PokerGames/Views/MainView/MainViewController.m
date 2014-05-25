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
    // verifica se foi passado parametros para o app
    NSArray *args = [[NSProcessInfo processInfo] arguments];
    
    // verifica se vai obter os dados localmente ou remotamente
    if ([args containsObject:[PokerGamesUtil paramLocalDataApp]]) {
        [PokerGamesUtil setIndLocalData:YES];
    } else {
        [PokerGamesUtil setIndLocalData:NO];
    }
    
    // verifica se deve ser exibida as mensagens de log ou não
    if ([args containsObject:[PokerGamesUtil paramDebugApp]]) {
        [[PokerGamesUtil pokerGamesFacadeInstance] setIsDebugApp:YES];
    } else {
        [[PokerGamesUtil pokerGamesFacadeInstance] setIsDebugApp:NO];
    }

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];

    self.menuViewController = [storyboard instantiateViewControllerWithIdentifier:@"Menu"];

    // configurações do menu
    self.limitMenuViewSize = YES;
    self.liveBlur = NO;
    
    // verifica se já está logado
    Jogador *jogador = [[PokerGamesUtil pokerGamesFacadeInstance] loadJogadorEntity];
    
    if (jogador == nil) {
        [[PokerGamesUtil pokerGamesFacadeInstance] setIsFirstTime:TRUE];
        //NSLog(@">>> Configuração inicial!");
        self.contentViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginJogador"];
    } else {
        [[PokerGamesUtil pokerGamesFacadeInstance] setIsFirstTime:FALSE];
        //NSLog(@">>> Já configurado!");
        [[PokerGamesUtil pokerGamesFacadeInstance] setJogadorLogin:jogador];
        
        // verifica se recebeu alguma notificacao via push
        if ([[UIApplication sharedApplication] applicationIconBadgeNumber] > 0) {
            self.contentViewController = [storyboard instantiateViewControllerWithIdentifier:@"TorneiosDisponiveis"];
        } else {
            self.contentViewController = [storyboard instantiateViewControllerWithIdentifier:@"RankingCampeonato"];
        }
    }
}

@end
