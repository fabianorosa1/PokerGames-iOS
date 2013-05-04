//
//  ListaJogadoresTableViewController.m
//  PokerGames
//
//  Created by Fabiano Rosa on 03/05/13.
//  Copyright (c) 2013 Fabiano Rosa. All rights reserved.
//

#import "ListaJogadoresTableViewController.h"
#import "ECSlidingViewController.h"
#import "MenuViewController.h"
#import "ADVTheme.h"
#import "ListaJogadoresCell.h"
#import "MBProgressHUD.h"

@interface ListaJogadoresTableViewController () {
    NSArray *arJogadores;
}

@end

@implementation ListaJogadoresTableViewController

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
    
    // busca os jogadores da liga
    [self buscaJogadores];
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
    
    self.title = @"Lista de Jogadores";
    self.lblLiga.text =  [NSString stringWithFormat:@"Liga: %@", [[PokerGamesFacade sharedInstance] jogadorLogin].liga.apelido];
    
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
    return arJogadores.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellListaJogador";
    ListaJogadoresCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    Jogador *jogador = arJogadores[indexPath.row];
    cell.jogador = jogador;
    
    return cell;
}

- (void) buscaJogadores {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.labelText = @"Buscando jogadores";
    
    Jogador *jogadorLogin = [[PokerGamesFacade sharedInstance] jogadorLogin];
    //NSLog(@"Busca jogadores da liga %@", jogadorLogin.idJogador);
        
    // busca lista de jackpots da liga
    [[PokerGamesFacade sharedInstance] buscaListaJogadoresPotWithBlock:jogadorLogin.idLiga
                                   constructingBodyWithBlock:^(NSArray *jogadores, NSError *error) {
                                       
    [hud hide:YES];

    if (error) {
       [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Erro", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
    } else {
       // lista de jogadores da liga
       //NSLog(@"jogadores: %@", jogadores );
       arJogadores = jogadores;
       
       // atualiza table
       [self.tableView reloadData];
       
       if (jogadores.count <= 0) {
           [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Atenção", nil) message:@"Nenhum jogador encontrado!" delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
       }
    }

    }];
}

@end
