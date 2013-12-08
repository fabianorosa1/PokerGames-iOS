//
//  TorneiosDisponiveisTableViewController.m
//  PokerGames
//
//  Created by Fabiano Rosa on 03/05/13.
//  Copyright (c) 2013 Fabiano Rosa. All rights reserved.
//

#import "JogadoresConfirmadosTableViewController.h"
#import "MenuViewController.h"
#import "JogadoresConfirmadosCell.h"
#import "MBProgressHUD.h"

@interface JogadoresConfirmadosTableViewController () {
    NSArray *arJogadores;
}

@end

@implementation JogadoresConfirmadosTableViewController

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
    
    // popula dados cabecalho
    self.lblNome.text = self.nomeTorneio;
    self.lblData.text = self.dataTorneio;
    self.lblHora.text = self.horaTorneio;

    // adiciona controle de refresh
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
    // busca os jogadores confirmados no torneio
    [self buscaJogadoresConfirmados];
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
    
    self.title = @"Jogadores Confirmados";
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
    static NSString *CellIdentifier = @"CellJogadoresConfirmados";
    JogadoresConfirmadosCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    NSDictionary *dados = arJogadores[indexPath.row];
    cell.dados = dados;
    
    return cell;
}

- (void) buscaJogadoresConfirmados {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.labelText = @"Buscando jogadores";
        
    // busca lista de jogadores confirmados no torneio
    [[PokerGamesFacade sharedInstance] buscaJogadoresConfirmadosWithBlock:self.idTorneio
                                             constructingBodyWithBlock:^(NSArray *jogadores, NSError *error) {
                                                 
     [hud hide:YES];
     
     if (error) {
         [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Erro", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
     } else {
         // lista lista de torneios disponiveis do campeonato
         //NSLog(@"jogadores: %@", jogadores );
         arJogadores = jogadores;
         
         // atualiza table
         [self.tableView reloadData];
         
         if (jogadores.count <= 0) {
             [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Atenção", nil) message:@"Nenhum torneio disponível!" delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
         }
     }
     
    }];
}

-(void) refreshView:(UIRefreshControl *) refresh {
    // busca os jogadores confirmados
    [self buscaJogadoresConfirmados];
    
    [refresh endRefreshing];
}

@end
