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
#import "PerfilJogadorViewController.h"

@interface ListaJogadoresTableViewController () {
    NSArray *arJogadores;
    NSMutableArray *arFilteredJogadores;
    Jogador *jogadorPressionado;
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
        
    [ADVThemeManager customizeTableView:self.tableView];
    
    // botao de configuracoes
    UIBarButtonItem *btnMenu = [[UIBarButtonItem alloc]
                                initWithImage:[PokerGamesUtil menuImage]
                                style:UIBarButtonItemStyleBordered
                                target:self
                                action:@selector(configAction)];
    self.navigationItem.leftBarButtonItem = btnMenu;
    
    // reconhecimento de long press na table
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 1.0; //seconds
    lpgr.delegate = self;
    [self.tableView addGestureRecognizer:lpgr];
    
    // adiciona controle de refresh
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
    // busca os jogadores da liga
    [self buscaJogadores];
}

-(IBAction)goToSearch:(id)sender {
    // If you're worried that your users might not catch on to the fact that a search bar is available if they scroll to reveal it, a search icon will help them
    // If you don't hide your search bar in your app, don’t include this, as it would be redundant
    //[self.searchDisplayController setActive:YES];
    [self.searchBar becomeFirstResponder];
}

- (IBAction)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint p = [gestureRecognizer locationInView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
        if (indexPath) {
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            if (cell.isHighlighted) {
                //NSLog(@"long press on table view at section %d row %d", indexPath.section, indexPath.row);
                
                jogadorPressionado = arJogadores[indexPath.row];
                
                // Create the sheet without buttons
                UIActionSheet *sheet = [[UIActionSheet alloc]
                                        initWithTitle:nil
                                        delegate:self
                                        cancelButtonTitle:nil
                                        destructiveButtonTitle:nil
                                        otherButtonTitles:nil];
                
                // adiciona os botoes
                if (![[jogadorPressionado fone] isEqualToString:@""]) {
                    [sheet addButtonWithTitle:@"Telefonar"];
                }
                
                if (![[jogadorPressionado email] isEqualToString:@""]) {
                    [sheet addButtonWithTitle:@"Enviar e-mail"];
                }
                
                [sheet addButtonWithTitle:@"Adicionar aos contatos"];
                sheet.cancelButtonIndex = [sheet addButtonWithTitle:@"Cancelar"];

                [sheet showInView:self.view];
            }
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    // Get the name of the current pressed button
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if  ([buttonTitle isEqualToString:@"Telefonar"]) {
        //NSLog(@"Telefonar: %@", jogadorPressionado.fone);
        
        // efetua ligacao para o numero do cadastro
        UIDevice *device = [UIDevice currentDevice];
        if ([[device model] isEqualToString:@"iPhone"] ) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", jogadorPressionado.fone]]];
        }
    } else if ([buttonTitle isEqualToString:@"Enviar e-mail"]) {
        MFMailComposeViewController *mailer = [[PokerGamesFacade sharedInstance] enviaEmailJogador:jogadorPressionado.email delegate:self];
        if (mailer) {
            // ipad: mailer.modalPresentationStyle = UIModalPresentationPageSheet;
            [self presentViewController:mailer animated:TRUE completion:nil];
        }
    } else if ([buttonTitle isEqualToString:@"Adicionar aos contatos"]) {
        //NSLog(@"Contatos: %@", jogadorPressionado.nome);
        
        // mostra view do iOS para criar novo contato
        ABNewPersonViewController* npvc = [ABNewPersonViewController new];
        npvc.newPersonViewDelegate = self;
        npvc.displayedPerson = [[PokerGamesFacade sharedInstance] retornaContatoJogador:jogadorPressionado];
        
        UINavigationController* nc = [[UINavigationController alloc] initWithRootViewController:npvc];
        [self presentViewController:nc animated:YES completion:nil];
    }
}

#pragma mark Adress book delegate methods

- (void)newPersonViewController:(ABNewPersonViewController*)newPersonViewController didCompleteWithNewPerson:(ABRecordRef)person {
    if (person) {
        [[PokerGamesFacade sharedInstance] gravaNovoContato:person];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    /*
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved: you saved the email message in the drafts folder.");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
            break;
        default:
            NSLog(@"Mail not sent.");
            break;
    }
    */
    
    // Remove the mail view
    [self dismissViewControllerAnimated:TRUE completion:nil];
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
    // Check to see whether the normal table or search results table is being displayed and return the count from the appropriate array
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [arFilteredJogadores count];
    } else {
        return [arJogadores count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellListaJogador";
    ListaJogadoresCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    Jogador *jogador = nil;
    
    // Check to see whether the normal table or search results table is being displayed and set the Candy object from the appropriate array
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        jogador = [arFilteredJogadores objectAtIndex:indexPath.row];
    } else {
        jogador = [arJogadores objectAtIndex:indexPath.row];
    }
    
    cell.jogador = jogador;

    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,tableView.frame.size.width,44)];
    
    // configura o header
    id <ADVTheme> theme = [ADVThemeManager sharedTheme];
    
    [ADVThemeManager customizeTableView:self.tableView];
    
    [headerView setBackgroundColor:[UIColor colorWithPatternImage:[theme viewBackground]]];
    headerView.layer.borderColor = [UIColor grayColor].CGColor;
    headerView.layer.borderWidth = 0.4f;

    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, headerView.frame.size.width, headerView.frame.size.height)];
    
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.text = [[PokerGamesFacade sharedInstance] jogadorLogin].liga.apelido;
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:19.0f];
    [headerView addSubview:headerLabel];
    
    return headerView;
}

-(float)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return  44.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"PerfilJogador" sender:tableView];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"PerfilJogador"])
    {
        // Get reference to the destination view controller
        PerfilJogadorViewController *vc = [segue destinationViewController];
        
        // In order to manipulate the destination view controller, another check on which table (search or normal) is displayed is needed
        if(sender == self.searchDisplayController.searchResultsTableView) {
            NSIndexPath *indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
            Jogador *jogador = [arFilteredJogadores objectAtIndex:indexPath.row];
            vc.idJogadorParametro = jogador.idJogador;
        }
        else {
             NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
            Jogador *jogador = [arJogadores objectAtIndex:indexPath.row];
            vc.idJogadorParametro = jogador.idJogador;
        }
    }
}

#pragma mark Content Filtering
-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    // Update the filtered array based on the search text and scope.
    // Remove all objects from the filtered search array
    [arFilteredJogadores removeAllObjects];
    // Filter the array using NSPredicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.nome contains[c] %@",searchText];
    arFilteredJogadores = [NSMutableArray arrayWithArray:[arJogadores filteredArrayUsingPredicate:predicate]];
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
           
           arFilteredJogadores = [NSMutableArray arrayWithCapacity:[arJogadores count]];
            
           // atualiza table
           [self.tableView reloadData];
           
           if (jogadores.count <= 0) {
               [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Atenção", nil) message:@"Nenhum jogador encontrado!" delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
           }
        }
    }];
}

-(void) refreshView:(UIRefreshControl *) refresh {
    // busca os jogadores
    [self buscaJogadores];
    
    [refresh endRefreshing];
}

@end
