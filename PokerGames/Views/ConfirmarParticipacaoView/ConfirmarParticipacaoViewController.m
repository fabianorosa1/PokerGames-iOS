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
    id <ADVTheme> theme = [ADVThemeManager sharedTheme];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[theme viewBackground]]];
    
    [self.btnParticipar setBackgroundImage:[theme colorButtonBackgroundForState:UIControlStateNormal] forState:UIControlStateNormal];
    [self.btnParticipar setBackgroundImage:[theme colorButtonBackgroundForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];

    [self.btnNaoParticipar setBackgroundImage:[theme colorButtonBackgroundForState:UIControlStateNormal] forState:UIControlStateNormal];
    [self.btnNaoParticipar setBackgroundImage:[theme colorButtonBackgroundForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
    
    [self.viewHeader setBackgroundColor:[UIColor colorWithPatternImage:[theme viewBackground]]];
    self.viewHeader.layer.borderColor = [UIColor grayColor].CGColor;
    self.viewHeader.layer.borderWidth = 0.4f;

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
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"PokerGames" message:@"Confirma participação?" delegate:self cancelButtonTitle:@"Não" otherButtonTitles:@"Sim", nil];
    alert.tag = 0;
    [alert show];
}

-(IBAction)NaoParticiparPressed:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"PokerGames" message:@"Deseja realmente não participar?" delegate:self cancelButtonTitle:@"Não" otherButtonTitles:@"Sim", nil];
    alert.tag = 1;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 0) {
        
        if(buttonIndex == 1)
        {
            // Confirmou a participacao
            [self confirmaParticipacao:TRUE];
        }
    } else if (alertView.tag == 1) {
        if(buttonIndex == 1)
        {
            // Não confirmou a participacao
            [self confirmaParticipacao:FALSE];
        }
    } else if (alertView.tag == 2) {
        if(buttonIndex == 0)
        {
            // NAO adicionou o evento
            [self saiTela];
        }
         else if(buttonIndex == 1)
        {
            // SIM para adicionar evento ao calendario
            [self adicionaEventoCalendario];
            [self saiTela];
        }
    }
}

- (void) confirmaParticipacao:(BOOL)confirmado {
    if (confirmado) {
        // Confirmou!
        
        //NSLog(@"Pergunta se deseja adicionar o evento");
        
        // Pergunta se deseja adicionar o evento
        //dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"PokerGames" message:@"Participação confirmada! Deseja adicionar este evento ao calendário?" delegate:self cancelButtonTitle:@"Não" otherButtonTitles:@"Sim", nil];
            alert.tag = 2;
            [alert show];
        //});
    } else {
        // Não confirmou!
        
        [self saiTela];
    }
}

- (void) saiTela {
    //NSLog(@" saiTela");
    // instancia a tela principal do ranking
    ECSlidingViewController *slidingViewController = (ECSlidingViewController *)self.view.window.rootViewController;
    slidingViewController.topViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RankingCampeonato"];
}

- (void) adicionaEventoCalendario {
    //NSLog(@"adicionaEventoCalendario");
    
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    
    if ([eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)])
    {
        [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error)
         {
             if (granted)
             {
                 //NSLog(@" granted");
                 // cria o evento
                 EKEvent *event  = [EKEvent eventWithEventStore:eventStore];
                 event.title     = [NSString stringWithFormat:@"Torneio de Poker: %@", [self lblNome].text];
                 event.location  = [NSString stringWithFormat:@"%@ - %@", [self lblLocal].text, [self lblEndereco].text];
                 event.notes     = @"Evento criado pelo aplicativo PokerGames.";
                 
                 NSDateFormatter *df = [[NSDateFormatter alloc] init];
                 [df setDateFormat:@"dd/MM/yyyy HH:mm"];
                 //NSLog(@"Data: %@", [NSString stringWithFormat:@"%@ %@", [self lblData].text, [self lblHora].text]);
                 
                 NSDate *dateEvent = [df dateFromString: [NSString stringWithFormat:@"%@ %@", [self lblData].text, [self lblHora].text]];
                 //NSLog(@"Date: %@", dateEvent);
                 
                 event.startDate = dateEvent;//[[NSDate alloc] init];
                 event.endDate   = [[NSDate alloc] initWithTimeInterval:10800 sinceDate:dateEvent];//event.startDate];
                 
                 // salva o evento
                 [event setCalendar:[eventStore defaultCalendarForNewEvents]];
                 NSError *error;
                 [eventStore saveEvent:event span:EKSpanThisEvent error:&error];
                 
                 // verifica se houve erro ao salvar
                 if (error) {
                     NSLog(@"Error: %@", error);
                     [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Erro", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
                 } else {
                     //NSLog(@" sucesso!");
                     [[[UIAlertView alloc] initWithTitle:@"PokerGames" message:@"Evento adicionado ao calendário com sucesso." delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
                 }
             }
             else
             {
                 [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Erro", nil) message:@"Não autorizado!" delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
                 [self saiTela];
             }
         }];
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Erro", nil) message:@"Não foi possível adicionar o evento" delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
    }
    //NSLog(@" fim metodo");
}

- (void) buscaDadosConfirmacao {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Buscando dados";
    
    // busca dados da participacao do torneio
    [[PokerGamesFacade sharedInstance] buscaDadosConfirmacaoParticipacaoWithBlock:self.idCampeonato
                                            constructingBodyWithBlock:^(NSDictionary *dados, NSError *error) {
                    
        [hud hide:YES];
                                                
        if (error) {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Erro", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
        } else {
            // dados
            self.lblNome.text = [dados valueForKey:@"Nome"];
            self.lblContato.text = [dados valueForKey:@"Contato"];
            self.lblData.text = [dados valueForKey:@"Data"];
            self.lblHora.text = [dados valueForKey:@"Hora"];
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
