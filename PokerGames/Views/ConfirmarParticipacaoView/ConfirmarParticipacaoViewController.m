//
//  ConfirmarParticipacaoViewController.m
//  PokerGames
//
//  Created by Fabiano Rosa on 09/05/13.
//  Copyright (c) 2013 Fabiano Rosa. All rights reserved.
//

#import "ConfirmarParticipacaoViewController.h"
#import "MBProgressHUD.h"
#import <QuartzCore/QuartzCore.h>
#import "JogadoresConfirmadosTableViewController.h"
#import "MenuViewController.h"

@interface ConfirmarParticipacaoViewController ()

@end

@implementation ConfirmarParticipacaoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // popula dados cabecalho
    self.lblNome.text = [self.dicDadosConfirmacao valueForKey:@"Nome"];
    self.lblData.text = [self.dicDadosConfirmacao valueForKey:@"Data"];
    self.lblHora.text = [self.dicDadosConfirmacao valueForKey:@"Hora"];

    // verifica se habilita ou não os botões
    [self.btnParticipar setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [self.btnNaoParticipar setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    
    NSString *statusIncricao = [self.dicDadosConfirmacao valueForKey:@"Inscrito"];
    if ([statusIncricao isEqualToString:@"S"]) {
        self.btnParticipar.enabled = FALSE;
    } else if ([statusIncricao isEqualToString:@"N"]) {
        self.btnNaoParticipar.enabled = FALSE;
    }
    
    // ajustes layout botoes
    self.btnListaJogadores.layer.borderColor = [UIColor grayColor].CGColor;
    self.btnListaJogadores.layer.backgroundColor = [UIColor colorWithRed:98/255.0f
                                                                   green:161/255.0f
                                                                    blue:37/255.0f
                                                                   alpha:1.0f].CGColor;
    
    self.btnListaJogadores.layer.borderWidth = 0.5;
    self.btnListaJogadores.layer.cornerRadius = 3;

    self.btnNaoParticipar.layer.borderColor = [UIColor grayColor].CGColor;
    self.btnNaoParticipar.layer.backgroundColor = [PokerGamesUtil colorFromHexString:@"fe4533" alpha:1.0].CGColor;
    self.btnNaoParticipar.layer.borderWidth = 0.5;
    self.btnNaoParticipar.layer.cornerRadius = 3;

    self.btnParticipar.layer.borderColor = [UIColor grayColor].CGColor;
    self.btnParticipar.layer.backgroundColor = [UIColor colorWithRed:98/255.0f
                                                                   green:161/255.0f
                                                                    blue:37/255.0f
                                                                   alpha:1.0f].CGColor;
    self.btnParticipar.layer.borderWidth = 0.5;
    self.btnParticipar.layer.cornerRadius = 3;

    
    // mostra os dados na tela
    [self buscaDadosConfirmacao];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = @"Confirmar Participação";
}

-(void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.title = @"Voltar";
}

-(IBAction)participarPressed:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"PokerGames" message:@"Confirma participação no torneio?" delegate:self cancelButtonTitle:@"Não" otherButtonTitles:@"Sim", nil];
    alert.tag = 0;
    [alert show];
}

-(IBAction)NaoParticiparPressed:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"PokerGames" message:@"Não vai mesmo participar do torneio?" delegate:self cancelButtonTitle:@"Não" otherButtonTitles:@"Sim", nil];
    alert.tag = 1;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 0) {
        if(buttonIndex == 1) {
            // Confirmou a participacao
            [self confirmaParticipacao:TRUE];
        }
    } else if (alertView.tag == 1) {
        if(buttonIndex == 1) {
            // Não confirmou a participacao
            [self confirmaParticipacao:FALSE];
        }
    } else if (alertView.tag == 2) {
        if(buttonIndex == 1) {
            // SIM para adicionar evento ao calendario
            [self verificaAdicaoEventoCalendario];
        }
    }
}

- (void) confirmaParticipacao:(BOOL)confirmado {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Atualizando torneio";

    Jogador *jogadorLogin = [[PokerGamesUtil pokerGamesFacadeInstance] jogadorLogin];
    
    if (confirmado) {
        // confirma participacao no torneio
        [[PokerGamesUtil pokerGamesFacadeInstance] confirmarParticipacaoWithBlock:[self.dicDadosConfirmacao valueForKey:@"IdTorneio"]
                                                            idJogador:jogadorLogin.idJogador
                                                            indParticipar:@"S"
                                                    constructingBodyWithBlock:^(NSString *result, NSError *error) {
            [hud hide:YES];
            
            if (error) {
                [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Erro", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
            } else {
                // participacao confirmada, verifica se adiciona o evento ao calendario
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"PokerGames" message:@"Participação confirmada! Deseja adicionar este evento ao calendário?" delegate:self cancelButtonTitle:@"Não" otherButtonTitles:@"Sim", nil];
                alert.tag = 2;
                [alert show];
            }
        }];
    } else {
        // Não confirmou!
        // confirma participacao no torneio
        [[PokerGamesUtil pokerGamesFacadeInstance] confirmarParticipacaoWithBlock:[self.dicDadosConfirmacao valueForKey:@"IdTorneio"]
                                                            idJogador:jogadorLogin.idJogador
                                                            indParticipar:@"N"
                                                constructingBodyWithBlock:^(NSString *result, NSError *error) {
            [hud hide:YES];
            
            if (error) {
                [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Erro", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"PokerGames" message:@"Participação não confirmada." delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
                alert.tag = 3;
                [alert show];
            }
        }];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    // workarround para fazer o alert modal
    if (alertView.tag == 2 && buttonIndex == 0) {
        [self saiTela];
    } else if (alertView.tag == 3) {
        [self saiTela];
    }
}

- (void) saiTela {
    // instancia a tela principal do ranking
    [self chamaTela:@"TorneiosDisponiveisView"];
}

- (void) verificaAdicaoEventoCalendario {
    EKEventStore* eventStore = [[EKEventStore alloc] init];
    
    // iOS 6 introduced a requirement where the app must
    // explicitly request access to the user's calendar. This
    // function is built to support the new iOS6 requirement,
    // as well as earlier versions of the OS.
    if([eventStore respondsToSelector:
        @selector(requestAccessToEntityType:completion:)]) {
        // iOS 6 and later
        [eventStore
         requestAccessToEntityType:EKEntityTypeEvent
         completion:^(BOOL granted, NSError *error) {
             [self performSelectorOnMainThread:
              @selector(presentEventEditViewControllerWithEventStore:)
                                    withObject:eventStore
                                 waitUntilDone:NO];
         }];
    } else {
        // iOS 5
        [self presentEventEditViewControllerWithEventStore:eventStore];
    }
}

- (void)presentEventEditViewControllerWithEventStore:(EKEventStore*)eventStore
{
    EKEventEditViewController* vc = [[EKEventEditViewController alloc] init];
    vc.eventStore = eventStore;
    
    EKEvent* event = [EKEvent eventWithEventStore:eventStore];
    // Prepopulate all kinds of useful information with you event.
    event.title     = [NSString stringWithFormat:@"Torneio de Poker: %@", [self lblNome].text];
    event.location  = [self lblEndereco].text;
    event.notes     = [NSString stringWithFormat:@"Local do Torneio: %@\nEste evento é gerenciado pelo PokerGames.", [self lblLocal].text];
    event.allDay = NO;
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"dd/MM/yyyy HH:mm"];
    //NSLog(@"Data: %@", [NSString stringWithFormat:@"%@ %@", [self lblData].text, [self lblHora].text]);
    
    NSDate *dateEvent = [df dateFromString: [NSString stringWithFormat:@"%@ %@", [self lblData].text, [self lblHora].text]];
    //NSLog(@"Date: %@", dateEvent);
    
    event.startDate = dateEvent;//[[NSDate alloc] init];
    event.endDate   = [[NSDate alloc] initWithTimeInterval:10800 sinceDate:dateEvent];//event.startDate];
    [event setCalendar:[eventStore defaultCalendarForNewEvents]];
    
    vc.event = event;
    vc.editViewDelegate = self;
    
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma EKEventEditViewDelegate

- (void)eventEditViewController:(EKEventEditViewController*)controller
          didCompleteWithAction:(EKEventEditViewAction)action
{
    [controller dismissViewControllerAnimated:YES completion:nil];
    [self saiTela];
}

- (void) buscaDadosConfirmacao {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Buscando dados";
    
    // busca dados da participacao do torneio
    [[PokerGamesUtil pokerGamesFacadeInstance] buscaDadosConfirmacaoParticipacaoWithBlock:[self.dicDadosConfirmacao valueForKey:@"IdTorneio"]
                                            constructingBodyWithBlock:^(NSDictionary *dados, NSError *error) {
                    
        [hud hide:YES];
                                                
        if (error) {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Erro", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
        } else {
            // dados            
            self.lblContato.text = [dados valueForKey:@"Contato"];
            self.lblLocal.text = [dados valueForKey:@"Local"];
            self.lblQtInscritos.text = [dados valueForKey:@"QtConfirmados"]; // agora é QtConfirmados
                        
            // formata e verifica se os campos são numéricos
            [self formataCampo:self.lblVlAddOn dados:dados key:@"VlAddOn"];
            [self formataCampo:self.lblVlBuyIn dados:dados key:@"VlBuyIn"];
            [self formataCampo:self.lblVlRebuy dados:dados key:@"VlRebuy"];
            [self formataCampo:self.lblVlEliminacao dados:dados key:@"VlEliminacao"];
            
            self.lblEndereco.numberOfLines = 2;
            [self.lblEndereco setLineBreakMode:NSLineBreakByWordWrapping];
            self.lblEndereco.text = [dados valueForKey:@"Endereco"];
            [self.lblEndereco sizeToFit];
        }
    }];
}

- (void) formataCampo:(UILabel*)label dados:(NSDictionary*)dados key:(NSString*)key {
    NSString *strValue = [dados valueForKey:key];
    if ([self isNumeric:strValue]) {
        double valor = [[dados valueForKey:key] doubleValue];
        label.text = [[PokerGamesUtil currencyFormatter] stringFromNumber:[NSNumber numberWithDouble:valor]];
    } else {
        label.text = strValue;
    }
}

- (BOOL)isNumeric:(NSString *)code{
    NSScanner *ns = [NSScanner scannerWithString:code];
    float the_value;
    if ( [ns scanFloat:&the_value] ) {
        return YES;
    }
    
    return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"JogadoresConfirmados"])
    {
        // Get reference to the destination view controller
        JogadoresConfirmadosTableViewController *vc = [segue destinationViewController];
                
        // passa o parametro
        vc.idTorneio = [self.dicDadosConfirmacao valueForKey:@"IdTorneio"];
        vc.nomeTorneio = [self.dicDadosConfirmacao valueForKey:@"Nome"];
        vc.dataTorneio = [self.dicDadosConfirmacao valueForKey:@"Data"];
        vc.horaTorneio = [self.dicDadosConfirmacao valueForKey:@"Hora"];
      }
}

-(void) chamaTela:(NSString*)identifier {
    UINavigationController *navigationController = (UINavigationController *)self.frostedViewController.contentViewController;
    UIViewController *newTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
    navigationController.viewControllers = @[newTopViewController];
}

@end
