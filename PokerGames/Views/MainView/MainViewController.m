//
//  MainViewController.m
//  PokerGames
//
//  Created by Fabiano Rosa on 22/04/13.
//  Copyright (c) 2013 Fabiano Rosa. All rights reserved.
//

#import "MainViewController.h"
#import "Jogador.h"
#import "AppDelegate.h"

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

- (AppDelegate *)appDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIStoryboard *storyboard;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
    }
    
    // verifica se já está logado
    Jogador *jogador = [Jogador loadJogadorEntity];
    
    if (jogador == nil) {
        [self appDelegate].isFirstTime = TRUE;
        //NSLog(@">>> Configuração inicial!");
        //[self performSegueWithIdentifier:@"LoginJogador" sender:self];
        
        self.topViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginJogador"];
    } else {
        [self appDelegate].isFirstTime = FALSE;
        //NSLog(@">>> Já configurado!");
        [self appDelegate].jogadorLogin = jogador;
        //[self performSegueWithIdentifier:@"RankingCampeonato" sender:self];
        
        self.topViewController = [storyboard instantiateViewControllerWithIdentifier:@"RankingCampeonato"];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
