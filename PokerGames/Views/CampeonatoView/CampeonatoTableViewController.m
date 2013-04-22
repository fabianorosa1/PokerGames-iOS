//
//  CampeonatoTableViewController.m
//  PokerGames
//
//  Created by Fabiano Rosa on 21/04/13.
//  Copyright (c) 2013 Fabiano Rosa. All rights reserved.
//

#import "CampeonatoTableViewController.h"
#import "MBProgressHUD.h"
#import "Campeonato.h"
#import "Liga.h"
#import "AppDelegate.h"
#import "Jogador.h"
#import "ADVTheme.h"

@interface CampeonatoTableViewController () {
    NSArray *arCampeonatos;
}

@end

@implementation CampeonatoTableViewController

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

- (void) buscaCampeonatosLiga {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Buscando campeonatos";
    
    Jogador *playerLogin = [self.appDelegate playerLogin];
    //NSLog(@"Busca campeonatos da liga %@", playerLogin.idPlayer);
    
    // busca lista de campeonatos da liga
    [Campeonato buscaCampeonatosLigaWithBlock:playerLogin.liga.idLiga
          constructingBodyWithBlock:^(NSArray *campeonatos, NSError *error) {
              
      [hud hide:YES];
      
      if (error) {
          [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Erro", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
      } else {
          // lista de campeonatos
          NSLog(@"Campeonatos: %@", campeonatos );
          arCampeonatos = campeonatos;
          
          // atualiza table
          [self.tableView reloadData];
      }
      
  }];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.leftBarButtonItem.title = @"Voltar";
    
    [self buscaCampeonatosLiga];
    
    self.title = [self.appDelegate playerLogin].liga.apelido;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //NSLog(@"viewDidLoad");
    
    id <ADVTheme> theme = [ADVThemeManager sharedTheme];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[theme viewBackground]]];
    self.tableView.backgroundView = nil;
    [self.tableView setBackgroundColor:[UIColor colorWithPatternImage:[theme viewBackground]]];
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
    //NSLog(@"numberOfSectionsInTableView");
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    //NSLog(@">> numberOfRowsInSection: %@", arCampeonatos);
    return arCampeonatos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"cellForRowAtIndexPath");
    static NSString *CellIdentifier = @"CellLiga";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Campeonato *campeonato = [arCampeonatos objectAtIndex:indexPath.row];
    
    // Configure the cell...
    cell.textLabel.text = campeonato.apelido;
    cell.detailTextLabel.text = campeonato.nome;
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Selecione um campeonato:";
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    [self.appDelegate playerLogin].liga.campeonato = arCampeonatos[indexPath.row];
}

@end
