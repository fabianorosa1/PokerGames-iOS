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
#import "Jogador.h"
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

- (void) buscaCampeonatosLiga {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Buscando campeonatos";
    
    NSNumber *idLiga = nil;
    // verifica se foi passa a liga de parametro
    if (self.ligaSelecionada) {
        idLiga = self.ligaSelecionada.idLiga;
    } else {
        idLiga = [[PokerGamesFacade sharedInstance] jogadorLogin].liga.idLiga;
    }
    
    // busca lista de campeonatos da liga
    [[PokerGamesFacade sharedInstance] buscaCampeonatosLigaWithBlock:idLiga
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
    
    self.title = @"Campeonato";
    
    if (self.ligaSelecionada) {
        self.lblLiga.text = [NSString stringWithFormat:@"%@", self.ligaSelecionada.apelido];
    } else {
        self.lblLiga.text = [NSString stringWithFormat:@"%@", [[PokerGamesFacade sharedInstance] jogadorLogin].liga.apelido];
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
    
    // verifica se deve adicionar o botao de menu
    if ( !((self.ligaSelecionada) || ([[PokerGamesFacade sharedInstance] isFirstTime])) ) {
        // adiciona gesto para chamar o menu
        [self.view addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)]];
        
        // botao de configuracoes
        UIBarButtonItem *btnMenu = [[UIBarButtonItem alloc]
                                    initWithImage:[PokerGamesUtil menuImage]
                                    style:UIBarButtonItemStyleBordered
                                    target:self
                                    action:@selector(configAction)];
        self.navigationItem.leftBarButtonItem = btnMenu;
    }
    
    [self buscaCampeonatosLiga];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arCampeonatos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellCampeonato";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Campeonato *campeonato = [arCampeonatos objectAtIndex:indexPath.row];
    
    // Configure the cell...
    cell.textLabel.text = campeonato.apelido;
    cell.detailTextLabel.text = campeonato.nome;
    
    return cell;
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
    Jogador *jogador = [[PokerGamesFacade sharedInstance] jogadorLogin];
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
    if ([[PokerGamesFacade sharedInstance] isFirstTime]) {
        // limpa a base de dados
        [[PokerGamesFacade sharedInstance] excluirTodosJogadoresDependencias];
        
        // insere o jogador, liga e campeonato
        [[PokerGamesFacade sharedInstance] insertJogadorEntity:jogador];
        
        // já configurado
        [[PokerGamesFacade sharedInstance] setIsFirstTime:FALSE];
    } else {
        // verifica se foi alterado a liga ou o campeonato
        [[PokerGamesFacade sharedInstance] atualizaLigaCampeonatoJogadorEntity:jogador];
    }
    
    [hud hide:YES];
    
    // verifica se recebeu alguma notificacao via push
    if ([[UIApplication sharedApplication] applicationIconBadgeNumber] > 0) {
        // instancia a tela de torneios disponiveis
        [self chamaTela:@"TorneiosDisponiveisView"];
    } else {
        // instancia a tela principal do ranking
        [self chamaTela:@"RankingCampeonatoView"];
    }
}

-(void) chamaTela:(NSString*)identifier {
    UINavigationController *navigationController = (UINavigationController *)self.frostedViewController.contentViewController;
    UIViewController *newTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
    navigationController.viewControllers = @[newTopViewController];
}

@end
