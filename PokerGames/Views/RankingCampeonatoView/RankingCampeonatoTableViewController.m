//
//  RankingCampeonatoTableViewController.m
//  PokerGames
//
//  Created by Fabiano Rosa on 23/04/13.
//  Copyright (c) 2013 Fabiano Rosa. All rights reserved.
//

#import "RankingCampeonatoTableViewController.h"
#import "AppDelegate.h"
#import "Jogador.h"
#import "Liga.h"
#import "Campeonato.h"
#import "AFAppDotNetAPIClient.h"
#import "MBProgressHUD.h"
#import "RankingCampeonatoJogadorCell.h"
#import <QuartzCore/QuartzCore.h>
#import "ADVTheme.h"
#import "ECSlidingViewController.h"
#import "MenuViewController.h"
#import "DetalhesJogadorTableViewController.h"

@interface RankingCampeonatoTableViewController () {
    NSArray *arRanking;
    NSDictionary *rankingSelecionado;
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

- (AppDelegate *)appDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // configura o header
    id <ADVTheme> theme = [ADVThemeManager sharedTheme];
    
    [ADVThemeManager customizeTableView:self.tableView];
    
    [self.viewHeader setBackgroundColor:[UIColor colorWithPatternImage:[theme viewBackground]]];
    self.viewHeader.layer.borderColor = [UIColor grayColor].CGColor;
    self.viewHeader.layer.borderWidth = 0.7f;
    
    // botao de configuracoes
    UIBarButtonItem *btnMenu = [[UIBarButtonItem alloc]
                                   initWithImage:[PokerGamesUtil menuImage]
                                   style:UIBarButtonItemStyleBordered
                                   target:self
                                   action:@selector(configAction)];
    self.navigationItem.leftBarButtonItem = btnMenu;
    
    /*
    // botao de logout
    UIImage* imgLogout = [UIImage imageNamed:@"NavBarIconLogout.png"];
    UIBarButtonItem *btnLogout = [[UIBarButtonItem alloc]
                                  initWithImage:imgLogout
                                  style:UIBarButtonItemStyleBordered
                                  target:self
                                  action:@selector(logoutAction)];
    self.navigationItem.rightBarButtonItem = btnLogout;
    */
    
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
/*
-(IBAction)logoutAction
{
    [Jogador excluirTodosJogadoresDependencias];
    // seta não configurado
    [self appDelegate].isFirstTime = TRUE;

    // instancia a tela principal do ranking
    ECSlidingViewController *slidingViewController = (ECSlidingViewController *)self.view.window.rootViewController;
    slidingViewController.topViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginJogador"];
}
*/
-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    // remove o botão Back de navegação
    //self.navigationItem.leftBarButtonItem = nil;
    //self.navigationItem.hidesBackButton = YES;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = [self.appDelegate jogadorLogin].liga.campeonato.apelido;
    
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[MenuViewController class]]) {
        self.slidingViewController.underLeftViewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"Menu"];
    }
    
    [self.navigationController.view addGestureRecognizer:self.slidingViewController.panGesture];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    rankingSelecionado = arRanking[indexPath.row];
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
        Jogador *jogadorSelecionado = [[Jogador alloc] init];
        [jogadorSelecionado setIdJogador:[rankingSelecionado valueForKey:@"IdJogador"]];
        [jogadorSelecionado setApelido:[rankingSelecionado valueForKey:@"Apelido"]];
        [jogadorSelecionado setNome:[rankingSelecionado valueForKey:@"Nome"]];
        [jogadorSelecionado setIdLiga:[rankingSelecionado valueForKey:@"IdLiga"]];
        jogadorSelecionado.liga = [self.appDelegate jogadorLogin].liga;
        // parametros
        vc.jogador = jogadorSelecionado;
    }
}

- (void)buscaRankingCampeonatosWithBlock:(NSNumber *)idLiga
                                  idCampeonato:(NSNumber *)idCampeonato
            constructingBodyWithBlock:(void (^)(NSArray *ranking, NSError *error))block
{
    
    NSString *path = [NSString stringWithFormat:@"Campeonatos.svc/Ranking/%@/%@", idLiga, idCampeonato];
    //NSLog(@"Path: %@", path);
    
    [[AFAppDotNetAPIClient sharedClient] getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSArray *postsFromResponse = [JSON valueForKeyPath:@"RankingResult"];
        if (block) {
            block(postsFromResponse, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            NSLog(@"Path: %@", path);
            block([NSArray array], error);
        }
    }];
}

- (void) buscaRanking {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.labelText = @"Buscando ranking";
    
    Jogador *jogadorLogin = [self.appDelegate jogadorLogin];
    //NSLog(@"Busca campeonatos da liga %@", jogadorLogin.idJogador);
    
    // busca lista de campeonatos da liga
    [self buscaRankingCampeonatosWithBlock:jogadorLogin.liga.idLiga
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
    Jogador *jogadorLogin = [self.appDelegate jogadorLogin];
    //NSLog(@"Busca campeonatos da liga %@", jogadorLogin.idJogador);
    
    // busca lista de campeonatos da liga
    [self buscaRankingCampeonatosWithBlock:jogadorLogin.liga.idLiga
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
