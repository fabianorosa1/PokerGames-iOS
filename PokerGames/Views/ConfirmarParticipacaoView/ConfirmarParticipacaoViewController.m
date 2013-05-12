//
//  ConfirmarParticipacaoViewController.m
//  PokerGames
//
//  Created by Fabiano Rosa on 09/05/13.
//  Copyright (c) 2013 Fabiano Rosa. All rights reserved.
//

#import "ConfirmarParticipacaoViewController.h"
#import "ADVTheme.h"
#import "MBProgressHUD.h"
#import <QuartzCore/QuartzCore.h>
#import "ECSlidingViewController.h"
#import <EventKit/EventKit.h>

@interface ConfirmarParticipacaoViewController () {
    EKEventStore *eventStore;
}

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
    id <ADVTheme> theme = [ADVThemeManager sharedTheme];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[theme viewBackground]]];
    
    [self.btnParticipar setBackgroundImage:[theme colorButtonBackgroundForState:UIControlStateNormal] forState:UIControlStateNormal];
    [self.btnParticipar setBackgroundImage:[theme colorButtonBackgroundForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];

    [self.btnNaoParticipar setBackgroundImage:[theme colorButtonBackgroundForState:UIControlStateNormal] forState:UIControlStateNormal];
    [self.btnNaoParticipar setBackgroundImage:[theme colorButtonBackgroundForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
    
    [self.viewHeader setBackgroundColor:[UIColor colorWithPatternImage:[theme viewBackground]]];
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
    
    // inicializa o Calendar
    eventStore = [[EKEventStore alloc] init];
    
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
    if (alertView.tag == 2 || alertView.tag == 3) {
        [self saiTela];
    }
}

- (void) saiTela {
    // instancia a tela principal do ranking
    ECSlidingViewController *slidingViewController = (ECSlidingViewController *)self.view.window.rootViewController;
    slidingViewController.topViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TorneiosDisponiveisView"];
}

- (void) verificaAdicaoEventoCalendario {
    // Verifica se adiciona evento ao calendario
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    EKEventStoreRequestAccessCompletionHandler completion = ^(BOOL granted, NSError *error) {
        if (granted) {
            [self criaEventoCalendario];
        }
    };
    
    // ask the user for access if necessary
    switch (status) {
        case EKAuthorizationStatusNotDetermined:
            [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:completion];
            break;
            
        case EKAuthorizationStatusAuthorized:
            completion(YES, NULL);
            break;
            
        case EKAuthorizationStatusDenied:
        case EKAuthorizationStatusRestricted:
            completion(NO, NULL);
            break;
    }
}

- (void) criaEventoCalendario {
    //NSLog(@"criaEventoCalendario");
    ConfirmarParticipacaoViewController * __weak weakSelf = self; // avoid capturing self in the block
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // cria o evento
        EKEvent *event  = [EKEvent eventWithEventStore:eventStore];
        event.title     = [NSString stringWithFormat:@"Torneio de Poker: %@", [weakSelf lblNome].text];
        event.location  = [weakSelf lblEndereco].text;
        event.notes     = [NSString stringWithFormat:@"Local do Torneio: %@\nEste evento é gerenciado pelo PokerGames.", [weakSelf lblLocal].text];
        event.allDay = NO;

        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"dd/MM/yyyy HH:mm"];
        //NSLog(@"Data: %@", [NSString stringWithFormat:@"%@ %@", [self lblData].text, [self lblHora].text]);

        NSDate *dateEvent = [df dateFromString: [NSString stringWithFormat:@"%@ %@", [weakSelf lblData].text, [weakSelf lblHora].text]];
        //NSLog(@"Date: %@", dateEvent);

        event.startDate = dateEvent;//[[NSDate alloc] init];
        event.endDate   = [[NSDate alloc] initWithTimeInterval:10800 sinceDate:dateEvent];//event.startDate];

        // salva o evento
        [event setCalendar:[eventStore defaultCalendarForNewEvents]];
        NSError *error;
        [eventStore saveEvent:event span:EKSpanThisEvent commit:YES error:&error];

        // verifica se houve erro ao salvar
        if (error) {
            NSLog(@"Erro ao adicionar evento ao calendário: %@", error);
        } 
    });
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
            self.lblQtInscritos.text = [dados valueForKey:@"QtInscritos"];
            self.lblVlAddOn.text = [dados valueForKey:@"VlAddOn"];
            
            double valorBuyIn = [[dados valueForKey:@"VlBuyIn"] doubleValue];
            self.lblVlBuyIn.text = [[PokerGamesUtil currencyFormatter] stringFromNumber:[NSNumber numberWithDouble:valorBuyIn]];

            double valorRebuy = [[dados valueForKey:@"VlRebuy"] doubleValue];
            self.lblVlRebuy.text = [[PokerGamesUtil currencyFormatter] stringFromNumber:[NSNumber numberWithDouble:valorRebuy]];

            self.lblVlEliminacao.text = [dados valueForKey:@"VlEliminacao"];
            
            self.lblEndereco.numberOfLines = 2;
            [self.lblEndereco setLineBreakMode:NSLineBreakByWordWrapping];
            self.lblEndereco.text = [dados valueForKey:@"Endereco"];
            [self.lblEndereco sizeToFit];
        }
    }];
}

@end
