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
    
    // reconhecimento de long press na table
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 1.5; //seconds
    lpgr.delegate = self;
    [self.tableView addGestureRecognizer:lpgr];
        
    // busca os jogadores da liga
    [self buscaJogadores];
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
        //NSLog(@"Email: %@", jogadorPressionado.email);
        
        // envia email para o jogador
        if ([MFMailComposeViewController canSendMail])
        {
            MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
            mailer.mailComposeDelegate = self;
            [mailer setSubject:@"Mensagem do PokerGames"];
            NSArray *toRecipients = [NSArray arrayWithObjects:jogadorPressionado.email, nil];
            [mailer setToRecipients:toRecipients];
            
            UIImage *myImage = [UIImage imageNamed:@"iPhoneIcon_Big.png"];
            NSData *imageData = UIImagePNGRepresentation(myImage);
            [mailer addAttachmentData:imageData mimeType:@"image/png" fileName:@"pokergames"];
            
            Jogador *jogadorLogin = [[PokerGamesFacade sharedInstance] jogadorLogin];
            NSString *emailBody = [NSString stringWithFormat:@"Olá, vamos jogar poker?\n\nAt,\n%@", jogadorLogin.nome];
            [mailer setMessageBody:emailBody isHTML:NO];

            // ipad: mailer.modalPresentationStyle = UIModalPresentationPageSheet;
            [self presentViewController:mailer animated:TRUE completion:nil];
        }
    } else if ([buttonTitle isEqualToString:@"Adicionar aos contatos"]) {
        //NSLog(@"Contatos: %@", jogadorPressionado.nome);
        [[PokerGamesFacade sharedInstance] adicionaJogadorAosContatos:jogadorPressionado];
    }
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
    self.lblLiga.text =  [NSString stringWithFormat:@"%@", [[PokerGamesFacade sharedInstance] jogadorLogin].liga.apelido];
    
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"PerfilJogador" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"PerfilJogador"])
    {
        // Get reference to the destination view controller
        PerfilJogadorViewController *vc = [segue destinationViewController];
        
        // Pass any objects to the view controller here, like...
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Jogador *jogador = [arJogadores objectAtIndex:indexPath.row];
        vc.idJogadorParametro = jogador.idJogador;
    }
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
