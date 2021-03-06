//
//  JackPotTableViewController.m
//  PokerGames
//
//  Created by Fabiano Rosa on 23/04/13.
//  Copyright (c) 2013 Fabiano Rosa. All rights reserved.
//

#import "JackPotTableViewController.h"
#import "Jogador.h"
#import "Liga.h"
#import "MBProgressHUD.h"
#import "JackPotCell.h"
#import <QuartzCore/QuartzCore.h>
#import "MenuViewController.h"

@interface JackPotTableViewController () {
    NSArray *arJackPot;
}

@end

@implementation JackPotTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // adiciona gesto para chamar o menu
    [self.navigationController.view addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)]];
    
    // botao de configuracoes
    UIBarButtonItem *btnMenu = [[UIBarButtonItem alloc]
                                initWithImage:[PokerGamesUtil menuImage]
                                style:UIBarButtonItemStyleBordered
                                target:self
                                action:@selector(configAction)];
    self.navigationItem.leftBarButtonItem = btnMenu;
    
    // busca os rankings
    [self buscaRanking];
}

-(IBAction)configAction
{
    [self.frostedViewController presentMenuViewController];
}

-(void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    self.title = @"Voltar";
}

-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = @"JackPot";
    self.lblLiga.text =  [NSString stringWithFormat:@"%@", [[PokerGamesUtil pokerGamesFacadeInstance] jogadorLogin].liga.apelido];
}

#pragma mark -
#pragma mark Gesture recognizer

- (void)panGestureRecognized:(UIPanGestureRecognizer *)sender
{
    [self.frostedViewController panGestureRecognized:sender];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return arJackPot.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellJackPot";
    JackPotCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    NSDictionary *jackpot = arJackPot[indexPath.row];
    cell.dados = jackpot;
    
    return cell;
}

- (void) buscaRanking {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.labelText = @"Buscando jackpot";
    
    Jogador *jogadorLogin = [[PokerGamesUtil pokerGamesFacadeInstance] jogadorLogin];
    //NSLog(@"Busca jackpot da liga %@", jogadorLogin.idJogador);
    
    // busca cabecalho do jackpot
    [[PokerGamesUtil pokerGamesFacadeInstance] buscaCabecalhoJackPotWithBlock:jogadorLogin.idLiga
                                            constructingBodyWithBlock:^(NSString *saldo, NSError *error) {
                                                
        if (error) {
            [hud hide:YES];
            
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Erro", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
        } else {
            // cabecalho do resultados
            //NSLog(@"saldo: %@", saldo );
            
            double saldoValue = [saldo doubleValue];
            
            if (saldoValue < 0) {
                self.lblSaldo.textColor = [UIColor redColor];
            } else {
                self.lblSaldo.textColor = [UIColor colorWithRed:(46/255.f) green:(139/255.f) blue:(87/255.f) alpha:1.0f];
            }
            self.lblSaldo.text = [NSString stringWithFormat:@"Saldo: %@", [[PokerGamesUtil currencyFormatter] stringFromNumber:[NSNumber numberWithDouble:saldoValue]]];
        }
        
    }];
    
    // busca lista de jackpots da liga
    [[PokerGamesUtil pokerGamesFacadeInstance] buscaJackPotWithBlock:jogadorLogin.idLiga
                                          constructingBodyWithBlock:^(NSArray *jackpots, NSError *error) {
                                              
      [hud hide:YES];
      
      if (error) {
          [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Erro", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
      } else {
          // ranking do campeonato
          //NSLog(@"jackpots: %@", jackpots );
          arJackPot = jackpots;
          
          // atualiza table
          [self.tableView reloadData];
          
          if (jackpots.count <= 0) {
              [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Atenção", nil) message:@"Nenhum jackpot encontrado!" delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
          }
      }
      
    }];
}

@end
