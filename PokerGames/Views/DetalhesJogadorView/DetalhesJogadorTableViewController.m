//
//  RankingCampeonatoTableViewController.m
//  PokerGames
//
//  Created by Fabiano Rosa on 23/04/13.
//  Copyright (c) 2013 Fabiano Rosa. All rights reserved.
//

#import "DetalhesJogadorTableViewController.h"
#import "AppDelegate.h"
#import "Jogador.h"
#import "Liga.h"
#import "Campeonato.h"
#import "AFAppDotNetAPIClient.h"
#import "MBProgressHUD.h"
#import "DetalhesJogadorCell.h"
#import "ADVTheme.h"
#import "ECSlidingViewController.h"
#import "MenuViewController.h"

@interface DetalhesJogadorTableViewController () {
    NSArray *arResultadosTorneios;
}

@end

@implementation DetalhesJogadorTableViewController

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
    
    // busca os resultados dos torneios do jogador
    [self buscaResultadosTorneio];
}

-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = self.jogador.apelido;
    self.headerNomeCamp.text = self.jogador.liga.campeonato.apelido;
    
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
    return arResultadosTorneios.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellResultado";
    DetalhesJogadorCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    NSDictionary *resultadoTorneioJogador = arResultadosTorneios[indexPath.row];
    cell.row = indexPath.row;
    //cell.dados = resultadoTorneioJogador;
    
    return cell;
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
}

- (void)buscaResultadosTorneiosJogadorWithBlock:(NSNumber *)idLiga
                                  idCampeonato:(NSNumber *)idCampeonato
                                      idJogador:(NSNumber *)idJogador
            constructingBodyWithBlock:(void (^)(NSArray *resultados, NSError *error))block
{
    
    NSString *path = [NSString stringWithFormat:@"Jogadores.svc/ResultadosTorneios/%@/%@/%@", idLiga, idCampeonato, idJogador];
    NSLog(@"Path: %@", path);
    
    [[AFAppDotNetAPIClient sharedClient] getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSArray *postsFromResponse = [JSON valueForKeyPath:@"ResultadosTorneiosResult"];
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

- (void) buscaResultadosTorneio {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.labelText = @"Buscando resultados";
        
    // busca lista de campeonatos da liga
    [self buscaResultadosTorneiosJogadorWithBlock:self.jogador.idLiga
                              idCampeonato:self.jogador.liga.idCampeonato
                                idJogador:self.jogador.idJogador
                 constructingBodyWithBlock:^(NSArray *resultados, NSError *error) {
                     
         [hud hide:YES];
         
         if (error) {
             [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Erro", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
         } else {
             // resultados do torneio
             //NSLog(@"resultados: %@", resultados );
             arResultadosTorneios = resultados;
             
             // atualiza table
             [self.tableView reloadData];
             
             if (resultados.count <= 0) {
                  [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Atenção", nil) message:@"Nenhum resultado encontrado!" delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
             }
         }
         
     }];
}

@end
