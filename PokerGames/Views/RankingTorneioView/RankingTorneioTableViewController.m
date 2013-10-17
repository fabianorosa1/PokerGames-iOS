//
//  RankingTorneioTableViewController.m
//  PokerGames
//
//  Created by Fabiano Rosa on 23/04/13.
//  Copyright (c) 2013 Fabiano Rosa. All rights reserved.
//

#import "RankingTorneioTableViewController.h"
#import "Jogador.h"
#import "Liga.h"
#import "Campeonato.h"
#import "MBProgressHUD.h"
#import "RankingTorneioCell.h"
#import <QuartzCore/QuartzCore.h>
#import "MenuViewController.h"

@interface RankingTorneioTableViewController () {
    NSArray *arRanking;
}

@end

@implementation RankingTorneioTableViewController

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
    
    // configura o header
    //id <ADVTheme> theme = [ADVThemeManager sharedTheme];
    
    //[ADVThemeManager customizeTableView:self.tableView];
    
    //[self.viewHeader setBackgroundColor:[UIColor colorWithPatternImage:[theme viewBackground]]];
    self.viewHeader.layer.borderColor = [UIColor grayColor].CGColor;
    self.viewHeader.layer.borderWidth = 0.4f;
    
    // adiciona controle de refresh
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
    // busca os rankings
    [self buscaRanking];
}

-(IBAction)configAction
{
    //TODO [self.slidingViewController anchorTopViewTo:ECRight];
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
    
    self.title = @"Ranking Torneio";
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
    return arRanking.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellRankingTorneio";
    RankingTorneioCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    NSDictionary *rankingJogador = arRanking[indexPath.row];
    cell.row = indexPath.row;
    cell.dados = rankingJogador;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *rankingJogador = arRanking[indexPath.row];
    NSString *algoz = [rankingJogador valueForKey:@"NomeAlgoz"];
    if ([algoz isEqualToString:@""]) {
        return 62;
    }

    return 72;
}

#pragma mark - Table view delegate

- (void) buscaRanking {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.labelText = @"Buscando ranking";
    
    // busca cabecalho dos resultados
    [[PokerGamesFacade sharedInstance] buscaCabecalhoRankingWithBlock:self.idTorneio
                  constructingBodyWithBlock:^(NSDictionary *cabecalho, NSError *error) {
      
      if (error) {
          [hud hide:YES];
          
          [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Erro", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
      } else {
          // cabecalho do resultados
          //NSLog(@"cabecalho: %@", cabecalho );
          
          self.lblTorneio.text = [NSString stringWithFormat:@"Torneio: %@", [cabecalho valueForKey:@"Nome"]];
          self.lblData.text = [NSString stringWithFormat:@"%@ - %@", [cabecalho valueForKey:@"Data"], [cabecalho valueForKey:@"Hora"]];
          self.lblIncritos.hidden = false;
          self.lblQtInscritos.text = [cabecalho valueForKey:@"QtInscritos"];
          
          NSNumber *saldoValue = [cabecalho valueForKey:@"SaldoJack"];
          self.lblSaldoJack.text = [NSString stringWithFormat:@"JackPot: %@", [[PokerGamesUtil currencyFormatter] stringFromNumber:saldoValue]];   
      }
      
    }];
    
    // busca lista de ranking do torneio
    [[PokerGamesFacade sharedInstance] buscaRankingTorneioWithBlock:self.idTorneio
                 constructingBodyWithBlock:^(NSArray *ranking, NSError *error) {
                     
         [hud hide:YES];
         
         if (error) {
             [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Erro", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
         } else {
             // ranking do campeonato
             //NSLog(@"Ranking: %@", ranking );
             arRanking = ranking;
             
             // atualiza table
             [self.tableView reloadData];
             
             if (ranking.count <= 0) {
                  [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Atenção", nil) message:@"Nenhum ranking encontrado!" delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
             }
         }
         
     }];
}

-(void) refreshView:(UIRefreshControl *) refresh {
    // busca os rankings
    [self buscaRanking];
    
    [refresh endRefreshing];
}

@end
