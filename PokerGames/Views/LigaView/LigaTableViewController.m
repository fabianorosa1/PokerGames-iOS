//
//  LigaTableViewController.m
//  PokerGames
//
//  Created by Fabiano Rosa on 21/04/13.
//  Copyright (c) 2013 Fabiano Rosa. All rights reserved.
//

#import "LigaTableViewController.h"
#import "MBProgressHUD.h"
#import "Liga.h"
#import "Jogador.h"
#import "CampeonatoTableViewController.h"
#import "MenuViewController.h"

@interface LigaTableViewController () {
    NSArray *arLiga;
}

@end

@implementation LigaTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) buscaLigasPlayer {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Buscando ligas";
    
    Jogador *jogadorLogin = [[PokerGamesFacade sharedInstance] jogadorLogin];
    //NSLog(@"Busca ligas do jogador %@", jogadorLogin.idJogador);
    
    // busca lista de ligas do jogador
    [[PokerGamesFacade sharedInstance] buscaLigasPlayerWithBlock:jogadorLogin.idJogador
          constructingBodyWithBlock:^(NSArray *ligas, NSError *error) {
              
      [hud hide:YES];
      
      if (error) {
          // Erro ao buscar ligas
          [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Erro", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
      } else {
          // lista de ligas
          //NSLog(@"Ligas: %@", ligas );
          arLiga = ligas;
          
          // atualiza table
          [self.tableView reloadData];
      }
      
  }];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = @"Liga";
}

-(void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    self.title = @"Voltar";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // verifica se deve adicionar o botao de menu
    if (![[PokerGamesFacade sharedInstance] isFirstTime]) {

        // adiciona gesto para chamar o menu
        [self.navigationController.view addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)]];
        
        // botao de configuracoes
        UIBarButtonItem *btnMenu = [[UIBarButtonItem alloc]
                                    initWithImage:[PokerGamesUtil menuImage]
                                    style:UIBarButtonItemStyleBordered
                                    target:self
                                    action:@selector(configAction)];
        self.navigationItem.leftBarButtonItem = btnMenu;
    }
    
    [self buscaLigasPlayer];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    //NSLog(@"numberOfSectionsInTableView");
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    //NSLog(@">> numberOfRowsInSection: %@", arLiga);
    return arLiga.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"cellForRowAtIndexPath");
    static NSString *CellIdentifier = @"CellLiga";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Liga *liga = [arLiga objectAtIndex:indexPath.row];
    
    // Configure the cell...
    cell.textLabel.text = liga.apelido;
    cell.detailTextLabel.text = liga.nome;
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Selecione uma liga:";
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"SelecaoCampeonato" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"SelecaoCampeonato"])
    {
        // Get reference to the destination view controller
        CampeonatoTableViewController *vc = [segue destinationViewController];
        
        // Pass any objects to the view controller here, like...
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        vc.ligaSelecionada = [arLiga objectAtIndex:indexPath.row];
    }
}

@end
