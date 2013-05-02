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
#import "ECSlidingViewController.h"
#import "MenuViewController.h"

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
    
    NSNumber *idLiga = nil;
    // verifica se foi passa a liga de parametro
    if (self.ligaSelecionada) {
        idLiga = self.ligaSelecionada.idLiga;
    } else {
        idLiga = [self.appDelegate jogadorLogin].liga.idLiga;
    }
    
    // busca lista de campeonatos da liga
    [Campeonato buscaCampeonatosLigaWithBlock:idLiga
                    constructingBodyWithBlock:^(NSArray *campeonatos, NSError *error) {
        
        [hud hide:YES];
        
        if (error) {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Erro", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
        } else {
            // lista de campeonatos
            //NSLog(@"Campeonatos: %@", campeonatos );
            arCampeonatos = campeonatos;
            
            // atualiza table
            [self.tableView reloadData];
        }
        
    }];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.ligaSelecionada) {
        self.title = self.ligaSelecionada.apelido;
    } else {
        self.title = [self.appDelegate jogadorLogin].liga.apelido;
    }
}

-(void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    self.title = @"Voltar";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //NSLog(@"viewDidLoad");
    
    id <ADVTheme> theme = [ADVThemeManager sharedTheme];
    
    [ADVThemeManager customizeTableView:self.tableView];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[theme viewBackground]]];
    self.tableView.backgroundView = nil;
    [self.tableView setBackgroundColor:[UIColor colorWithPatternImage:[theme viewBackground]]];
    
    // verifica se deve adicionar o botao de menu
    if ( !((self.ligaSelecionada) || ([self appDelegate].isFirstTime)) ) {
        // botao de configuracoes
        UIBarButtonItem *btnMenu = [[UIBarButtonItem alloc]
                                    initWithImage:[PokerGamesUtil menuImage]
                                    style:UIBarButtonItemStyleBordered
                                    target:self
                                    action:@selector(configAction)];
        self.navigationItem.leftBarButtonItem = btnMenu;
        
        if (![self.slidingViewController.underLeftViewController isKindOfClass:[MenuViewController class]]) {
            self.slidingViewController.underLeftViewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"Menu"];
        }
        
        [self.navigationController.view addGestureRecognizer:self.slidingViewController.panGesture];
    }
    
    [self buscaCampeonatosLiga];
}

-(IBAction)configAction
{
    [self.slidingViewController anchorTopViewTo:ECRight];
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
    static NSString *CellIdentifier = @"CellCampeonato";
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
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Salvando dados";

    // associa o campeonato selecionado na liga do jogador
    Jogador *jogador = [self.appDelegate jogadorLogin];
    // associa a liga ao jogador
    
    // verifica se foi passa a liga de parametro
    if (self.ligaSelecionada) {
        jogador.liga = self.ligaSelecionada;
        jogador.idLiga = self.ligaSelecionada.idLiga;
    }
    
    // associa o campeonato a liga
    Campeonato *campeonato = [arCampeonatos objectAtIndex:indexPath.row];
    jogador.liga.campeonato = campeonato;
    jogador.liga.idCampeonato = campeonato.idCampeonato;
    
    // verifica se é configuração inicial ou não
    if ([self appDelegate].isFirstTime == TRUE) {
        // limpa a base de dados
        [Jogador excluirTodosJogadoresDependencias];
        
        // insere o jogador, liga e campeonato
        [jogador insertJogadorEntity];
        
        // já configurado
        [self appDelegate].isFirstTime = FALSE;
    } else {
        // verifica se foi alterado a liga ou o campeonato
        [jogador atualizaLigaCampeonatoJogadorEntity];
    }
    
    [hud hide:YES];
    
    // instancia a tela principal do ranking
    ECSlidingViewController *slidingViewController = (ECSlidingViewController *)self.view.window.rootViewController;
    slidingViewController.topViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RankingCampeonato"];
}

@end
