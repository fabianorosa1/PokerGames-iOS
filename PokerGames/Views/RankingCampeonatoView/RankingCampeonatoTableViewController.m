//
//  RankingCampeonatoTableViewController.m
//  PokerGames
//
//  Created by Fabiano Rosa on 23/04/13.
//  Copyright (c) 2013 Fabiano Rosa. All rights reserved.
//

#import "RankingCampeonatoTableViewController.h"
#import "Jogador.h"
#import "Liga.h"
#import "Campeonato.h"
#import "MBProgressHUD.h"
#import "RankingCampeonatoJogadorCell.h"
#import <QuartzCore/QuartzCore.h>
#import "ADVTheme.h"
#import "ECSlidingViewController.h"
#import "MenuViewController.h"
#import "DetalhesJogadorTableViewController.h"

@interface RankingCampeonatoTableViewController () {
    NSArray *arRanking;
}

@end

@implementation RankingCampeonatoTableViewController

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
    id <ADVTheme> theme = [ADVThemeManager sharedTheme];
    
    [ADVThemeManager customizeTableView:self.tableView];
    
    [self.viewHeader setBackgroundColor:[UIColor colorWithPatternImage:[theme viewBackground]]];
    self.viewHeader.layer.borderColor = [UIColor grayColor].CGColor;
    self.viewHeader.layer.borderWidth = 0.4f;
    
    // botao de configuracoes
    UIBarButtonItem *btnMenu = [[UIBarButtonItem alloc]
                                   initWithImage:[PokerGamesUtil menuImage]
                                   style:UIBarButtonItemStyleBordered
                                   target:self
                                   action:@selector(configAction)];
    self.navigationItem.leftBarButtonItem = btnMenu;
    
    // adiciona controle de refresh
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
    // busca os rankings
    [self buscaRanking];
}

-(IBAction)configAction
{
    [self.slidingViewController anchorTopViewTo:ECRight];
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
    
    self.title = @"Ranking Geral";
    self.lblApelidoCampeonato.text =  [NSString stringWithFormat:@"Campeonato: %@", [[PokerGamesFacade sharedInstance] jogadorLogin].liga.campeonato.apelido];
    
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[MenuViewController class]]) {
        self.slidingViewController.underLeftViewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"Menu"];
    }
    
    [self.navigationController.view addGestureRecognizer:self.slidingViewController.panGesture];
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
    static NSString *CellIdentifier = @"CellRanking";
    RankingCampeonatoJogadorCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    NSDictionary *rankingJogador = arRanking[indexPath.row];
    cell.row = indexPath.row;
    cell.dados = rankingJogador;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"ResultadosTorneioJogador" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"ResultadosTorneioJogador"])
    {
        // Get reference to the destination view controller
        DetalhesJogadorTableViewController *vc = [segue destinationViewController];
        
        // Pass any objects to the view controller here, like...
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDictionary *rankingSelecionado = arRanking[indexPath.row];
        
        Jogador *jogadorSelecionado = [[Jogador alloc] init];
        [jogadorSelecionado setIdJogador:[rankingSelecionado valueForKey:@"IdJogador"]];
        [jogadorSelecionado setApelido:[rankingSelecionado valueForKey:@"Apelido"]];
        [jogadorSelecionado setNome:[rankingSelecionado valueForKey:@"Nome"]];
        [jogadorSelecionado setIdLiga:[rankingSelecionado valueForKey:@"IdLiga"]];
        [jogadorSelecionado setFoto:[rankingSelecionado valueForKey:@"Foto"]];
        jogadorSelecionado.liga = [[PokerGamesFacade sharedInstance] jogadorLogin].liga;
        // parametros
        vc.jogador = jogadorSelecionado;
    }
}

- (void) buscaRanking {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.labelText = @"Buscando ranking";
    
    Jogador *jogadorLogin = [[PokerGamesFacade sharedInstance] jogadorLogin];
    //NSLog(@"Busca campeonatos da liga %@", jogadorLogin.idJogador);
    
    // busca lista de campeonatos da liga
    [[PokerGamesFacade sharedInstance] buscaRankingCampeonatosWithBlock:jogadorLogin.liga.idLiga
                              idCampeonato:jogadorLogin.liga.campeonato.idCampeonato
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


-(void) refreshView:(UIRefreshControl *) refresh
{
    Jogador *jogadorLogin = [[PokerGamesFacade sharedInstance] jogadorLogin];
    //NSLog(@"Busca campeonatos da liga %@", jogadorLogin.idJogador);
    
    // busca lista de campeonatos da liga
    [[PokerGamesFacade sharedInstance] buscaRankingCampeonatosWithBlock:jogadorLogin.liga.idLiga
                              idCampeonato:jogadorLogin.liga.campeonato.idCampeonato
                 constructingBodyWithBlock:^(NSArray *ranking, NSError *error) {
                     
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
    
    [refresh endRefreshing];
}
@end
