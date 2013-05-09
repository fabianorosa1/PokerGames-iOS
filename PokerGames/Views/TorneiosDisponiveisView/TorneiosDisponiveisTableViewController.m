//
//  TorneiosDisponiveisTableViewController.m
//  PokerGames
//
//  Created by Fabiano Rosa on 03/05/13.
//  Copyright (c) 2013 Fabiano Rosa. All rights reserved.
//

#import "TorneiosDisponiveisTableViewController.h"
#import "ECSlidingViewController.h"
#import "MenuViewController.h"
#import "ADVTheme.h"
#import "TorneiosDisponiveisCell.h"
#import "MBProgressHUD.h"

@interface TorneiosDisponiveisTableViewController () {
    NSArray *arTorneios;
}

@end

@implementation TorneiosDisponiveisTableViewController

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
    
    // busca os torneios disponiveis do campeonato
    [self buscaTorneios];
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
    
    self.title = @"Torneios Disponíveis";
    self.lblCampeonato.text =  [NSString stringWithFormat:@"%@", [[PokerGamesFacade sharedInstance] jogadorLogin].liga.campeonato.apelido];
    
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
    return arTorneios.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellTorneiosDisponiveis";
    TorneiosDisponiveisCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    NSDictionary *dados = arTorneios[indexPath.row];
    cell.dados = dados;
    
    return cell;
}

- (void) buscaTorneios {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.labelText = @"Buscando torneios";
    
    Jogador *jogadorLogin = [[PokerGamesFacade sharedInstance] jogadorLogin];
    //NSLog(@"Busca jogadores da liga %@", jogadorLogin.idJogador);
    
    // busca lista de jackpots da liga
    [[PokerGamesFacade sharedInstance] buscaTorneiosDisponiveisWithBlock:jogadorLogin.idLiga
                                                            idCampeonato:jogadorLogin.liga.idCampeonato
                                             constructingBodyWithBlock:^(NSArray *torneios, NSError *error) {
                                                 
     [hud hide:YES];
     
     if (error) {
         [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Erro", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
     } else {
         // lista de jogadores da liga
         //NSLog(@"jogadores: %@", jogadores );
         arTorneios = torneios;
         
         // atualiza table
         [self.tableView reloadData];
         
         if (torneios.count <= 0) {
             [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Atenção", nil) message:@"Nenhum torneio encontrado!" delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
         }
     }
     
    }];
}

@end
