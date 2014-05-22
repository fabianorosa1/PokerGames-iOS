//
//  TorneiosConcluidosTableViewController.m
//  PokerGames
//
//  Created by Fabiano Rosa on 23/04/13.
//  Copyright (c) 2013 Fabiano Rosa. All rights reserved.
//

#import "TorneiosConcluidosTableViewController.h"
#import "Jogador.h"
#import "Liga.h"
#import "Campeonato.h"
#import "MBProgressHUD.h"
#import "TorneiosConcluidosCell.h"
#import <QuartzCore/QuartzCore.h>
#import "MenuViewController.h"
#import "RankingTorneioTableViewController.h"

@interface TorneiosConcluidosTableViewController () {
    NSArray *arTorneios;
}

@end

@implementation TorneiosConcluidosTableViewController

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
    
    // adiciona controle de refresh
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
    // busca os torneios concluidos
    [self buscaTorneiosConcluidos];
}

-(IBAction)configAction
{
    [self.frostedViewController presentMenuViewController];
}

#pragma mark -
#pragma mark Gesture recognizer

- (void)panGestureRecognized:(UIPanGestureRecognizer *)sender
{
    [self.frostedViewController panGestureRecognized:sender];
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
    
    self.title =  @"Torneios Realizados";
    self.lblCampeonato.text = [NSString stringWithFormat:@"%@", [[PokerGamesFacade sharedInstance] jogadorLogin].liga.campeonato.apelido];
    
    //TODO
    /*
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[MenuViewController class]]) {
        self.slidingViewController.underLeftViewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"Menu"];
    }
    
    [self.navigationController.view addGestureRecognizer:self.slidingViewController.panGesture];
     */
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
    return arTorneios.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellTorneio";
    TorneiosConcluidosCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    NSDictionary *torneio = arTorneios[indexPath.row];
    cell.dados = torneio;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"RankingTorneio" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"RankingTorneio"])
    {
        // Get reference to the destination view controller
        RankingTorneioTableViewController *vc = [segue destinationViewController];
        
        // parametros
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
         NSDictionary *torneioSelecionado = arTorneios[indexPath.row];
        vc.idTorneio = [torneioSelecionado valueForKey:@"IdTorneio"];
    }
}

- (void) buscaTorneiosConcluidos {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.labelText = @"Buscando torneios";
    
    Jogador *jogadorLogin = [[PokerGamesFacade sharedInstance] jogadorLogin];
    //NSLog(@"Busca campeonatos da liga %@", jogadorLogin.idJogador);
    
    // busca lista de campeonatos da liga
    [[PokerGamesFacade sharedInstance] buscaTorneiosConcluidosWithBlock:jogadorLogin.liga.idLiga
                              idCampeonato:jogadorLogin.liga.campeonato.idCampeonato
                 constructingBodyWithBlock:^(NSArray *torneios, NSError *error) {
                     
         [hud hide:YES];
         
         if (error) {
             [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Erro", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
         } else {
             // torneios concluidos
             //NSLog(@"torneios: %@", torneios );
             arTorneios = torneios;
             
             // atualiza table
             [self.tableView reloadData];
             
             if (torneios.count <= 0) {
                  [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Atenção", nil) message:@"Nenhum torneio encontrado!" delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
             }
         }
         
     }];
}

-(void) refreshView:(UIRefreshControl *) refresh {
    // busca os rankings
    [self buscaTorneiosConcluidos];
    
    [refresh endRefreshing];
}

@end
