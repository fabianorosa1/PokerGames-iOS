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
#import "MenuViewController.h"
#import "DetalhesJogadorTableViewController.h"
#import "REFrostedViewController.h"

@interface RankingCampeonatoTableViewController () {
    NSArray *arRanking;
    NSMutableArray *arFilteredRanking;
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
    
    // corrige o bug do header da table
    self.tableView.contentInset = UIEdgeInsetsMake(-44, 0, 0, 0);
    self.tableView.contentSize = CGSizeMake(self.tableView.contentSize.width, self.tableView.contentSize.height+44);

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
    
    self.title = @"Ranking Geral";
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
    // Check to see whether the normal table or search results table is being displayed and return the count from the appropriate array
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [arFilteredRanking count];
    } else {
        return [arRanking count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellRanking";
    RankingCampeonatoJogadorCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    Ranking *rankingJogador = nil;
    
    // Check to see whether the normal table or search results table is being displayed and set the Candy object from the appropriate array
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        rankingJogador = [arFilteredRanking objectAtIndex:indexPath.row];
    } else {
        rankingJogador = [arRanking objectAtIndex:indexPath.row];
    }
    cell.row = indexPath.row;
    cell.ranking = rankingJogador;
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,tableView.frame.size.width,44)];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, headerView.frame.size.width, headerView.frame.size.height)];
    
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.text = [[PokerGamesFacade sharedInstance] jogadorLogin].liga.campeonato.apelido;
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:19.0f];
    [headerView addSubview:headerLabel];
    
    [headerView bringSubviewToFront:headerLabel];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return  44;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath

{
    return (CGFloat)60.0f;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"ResultadosTorneioJogador" sender:tableView];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"ResultadosTorneioJogador"])
    {
        // Get reference to the destination view controller
        DetalhesJogadorTableViewController *vc = [segue destinationViewController];
        
        Ranking *rankingSelecionado = nil;
        // In order to manipulate the destination view controller, another check on which table (search or normal) is displayed is needed
        if(sender == self.searchDisplayController.searchResultsTableView) {
            NSIndexPath *indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
            rankingSelecionado = [arFilteredRanking objectAtIndex:indexPath.row];
        }
        else {
            NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
            rankingSelecionado = [arRanking objectAtIndex:indexPath.row];
        }
        
        Jogador *jogadorSelecionado = [[Jogador alloc] init];
        [jogadorSelecionado setIdJogador:rankingSelecionado.idJogador];
        [jogadorSelecionado setApelido:rankingSelecionado.apelido];
        [jogadorSelecionado setNome:rankingSelecionado.nome];
        [jogadorSelecionado setIdLiga:rankingSelecionado.idLiga];
        [jogadorSelecionado setFoto:rankingSelecionado.foto];
        jogadorSelecionado.liga = [[PokerGamesFacade sharedInstance] jogadorLogin].liga;
        // parametros
        vc.jogador = jogadorSelecionado;
    }
}

- (IBAction)btSearch:(id)sender {
    // If you're worried that your users might not catch on to the fact that a search bar is available if they scroll to reveal it, a search icon will help them
    // If you don't hide your search bar in your app, don’t include this, as it would be redundant
    [self.searchBar setHidden:NO];
    [self.searchDisplayController setActive:YES];
    [self.searchBar becomeFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar setHidden:YES];
    [searchBar resignFirstResponder];
}

#pragma mark Content Filtering
-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    // Update the filtered array based on the search text and scope.
    // Remove all objects from the filtered search array
    [arFilteredRanking removeAllObjects];
    // Filter the array using NSPredicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.nome contains[c] %@",searchText];
    arFilteredRanking = [NSMutableArray arrayWithArray:[arRanking filteredArrayUsingPredicate:predicate]];
}

#pragma mark - UISearchDisplayController Delegate Methods
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    // Tells the table data source to reload when text changes
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    // Tells the table data source to reload when scope bar selection changes
    [self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
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
             
             arFilteredRanking = [NSMutableArray arrayWithCapacity:[arRanking count]];
             
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
