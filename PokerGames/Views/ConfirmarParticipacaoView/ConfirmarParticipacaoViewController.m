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
    
    // configura o header
    //id <ADVTheme> theme = [ADVThemeManager sharedTheme];
    
    //[self.view setBackgroundColor:[UIColor colorWithPatternImage:[theme viewBackground]]];
    
    //[self.btnParticipar setBackgroundImage:[theme colorButtonBackgroundForState:UIControlStateNormal] forState:UIControlStateNormal];
    //[self.btnParticipar setBackgroundImage:[theme colorButtonBackgroundForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];

    //[self.btnNaoParticipar setBackgroundImage:[theme colorButtonBackgroundForState:UIControlStateNormal] forState:UIControlStateNormal];
    //[self.btnNaoParticipar setBackgroundImage:[theme colorButtonBackgroundForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];

    //[self.viewHeader setBackgroundColor:[UIColor colorWithPatternImage:[theme viewBackground]]];
    self.viewHeader.layer.borderColor = [UIColor grayColor].CGColor;
    self.viewHeader.layer.borderWidth = 0.4f;

    // popula dados cabecalho
    self.lblNome.text = [self.dicDadosConfirmacao valueForKey:@"Nome"];
    self.lblData.text = [self.dicDadosConfirmacao valueForKey:@"Data"];
    self.lblHora.text = [self.dicDadosConfirmacao valueForKey:@"Hora"];

    // verifica se habilita ou não os botões
    NSString *statusIncricao = [self.dicDadosConfirmacao valueForKey:@"Inscrito"];
    if ([statusIncricao isEqualToString:@"S"]) {
        self.btnParticipar.enabled = FALSE;
    } else if ([statusIncricao isEqualToString:@"N"]) {
        self.btnNaoParticipar.enabled = FALSE;
    }
        
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

    Jogador *jogadorLogin = [[PokerGamesFacade sharedInstance] jogadorLogin];
    
    if (confirmado) {
        // confirma participacao no torneio
        [[PokerGamesFacade sharedInstance] confirmarParticipacaoWithBlock:[self.dicDadosConfirmacao valueForKey:@"IdTorneio"]
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
        [[PokerGamesFacade sharedInstance] confirmarParticipacaoWithBlock:[self.dicDadosConfirmacao valueForKey:@"IdTorneio"]
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
    //TODO ECSlidingViewController *slidingViewController = (ECSlidingViewController *)self.view.window.rootViewController;
    //TODO slidingViewController.topViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TorneiosDisponiveisView"];
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
    [[PokerGamesFacade sharedInstance] buscaDadosConfirmacaoParticipacaoWithBlock:[self.dicDadosConfirmacao valueForKey:@"IdTorneio"]
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

@end
