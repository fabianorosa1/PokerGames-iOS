//
//  MenuViewController.m
//  REFrostedViewController
//
//  Created by Michael Enriquez on 1/23/12.
//  Copyright (c) 2012 EdgeCase. All rights reserved.
//

#import "MenuViewController.h"
#import "Jogador.h"
#import "UIImageView+AFNetworking.h"
#import "MBProgressHUD.h"
#import "UIViewController+REFrostedViewController.h"

@interface MenuViewController() {
    UIImageView *imgViewFoto;
    UILabel *lblNome;
}

@end

@implementation MenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.separatorColor = [UIColor colorWithRed:150/255.0f green:161/255.0f blue:177/255.0f alpha:1.0f];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.opaque = NO;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = ({
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 140.0f)];
        
        imgViewFoto = [[UIImageView alloc] initWithFrame:CGRectMake(0, 25, 80, 80)];
        imgViewFoto.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        //imgViewFoto.image = [UIImage imageNamed:@"avatar.jpg"];
        imgViewFoto.layer.masksToBounds = YES;
        imgViewFoto.layer.cornerRadius = 40.0;
        imgViewFoto.layer.borderColor = [UIColor whiteColor].CGColor;
        imgViewFoto.layer.borderWidth = 3.0f;
        imgViewFoto.layer.rasterizationScale = [UIScreen mainScreen].scale;
        imgViewFoto.layer.shouldRasterize = YES;
        imgViewFoto.clipsToBounds = YES;
        imgViewFoto.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGestureFoto = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mostraPerfilJogador)];
        [imgViewFoto addGestureRecognizer:tapGestureFoto];
        
        lblNome = [[UILabel alloc] initWithFrame:CGRectMake(0, 110, 250, 24)];
        //lblNome.text = @"Roman Efimov";
        lblNome.font = [UIFont fontWithName:@"HelveticaNeue" size:20];
        lblNome.backgroundColor = [UIColor clearColor];
        lblNome.textColor = [UIColor colorWithRed:62/255.0f green:68/255.0f blue:75/255.0f alpha:1.0f];
        lblNome.textAlignment = NSTextAlignmentCenter;
        //[lblNome sizeToFit];
        lblNome.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        lblNome.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGestureNome = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mostraPerfilJogador)];
        [lblNome addGestureRecognizer:tapGestureNome];
        
        [view addSubview:imgViewFoto];
        [view addSubview:lblNome];
        view;
    });
    
    // evento de recebimento do push
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(didReceiveRemoteNotification:)
     name:@"UIApplicationDidReceiveRemoteNotification"
     object:nil];

}

-(void) mostraPerfilJogador {
    // Chama a tela do perfil do jogador
    [self chamaTela:@"PerfilView"];
}

-(void)viewDidUnload {
    // desregistra o evento de push
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:@"UIApplicationDidReceiveRemoteNotification"
     object:nil];
}

-(void)didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // see http://stackoverflow.com/a/2777460/305149
    //if (self.isViewLoaded && self.view.window) {
    // handle the notification
    //self.imgViewPush.hidden = NO;
    //}
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // seta os dados do perfil
    Jogador *jogador = [[PokerGamesFacade sharedInstance] jogadorLogin];
    lblNome.text = jogador.nome;
    
    // seta a foto do jogador
    [PokerGamesUtil setaImagemJogador:imgViewFoto foto:jogador.foto];
}


#pragma mark -
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor colorWithRed:62/255.0f green:68/255.0f blue:75/255.0f alpha:1.0f];
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)sectionIndex
{
    if (sectionIndex == 0)
        return nil;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30)];
    view.backgroundColor = [UIColor colorWithRed:167/255.0f green:167/255.0f blue:167/255.0f alpha:0.6f];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 3, 0, 0)];
    label.text = @"Configurações";
    label.font = [UIFont systemFontOfSize:15];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    [label sizeToFit];
    [view addSubview:label];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)sectionIndex
{
    if (sectionIndex == 0)
        return 0;
    
    return 25;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            // Tela de ranking geral
            [self chamaTela:@"RankingCampeonatoView"];
        } else if (indexPath.row == 1) {
            // Tela de ranking dos torneios
            [self chamaTela:@"TorneiosConcluidosView"];
        } else if (indexPath.row == 2) {
            // Tela de torneios disponiveis
            [self chamaTela:@"TorneiosDisponiveisView"];
        }else if (indexPath.row == 3) {
            // Tela de meus resultados
            [self chamaTela:@"MeusResultadosView"];
        }else if (indexPath.row == 4) {
            // Tela de lista de jogadores
            [self chamaTela:@"ListaJogadoresView"];
        }else if (indexPath.row == 5) {
            // Tela de JackPot
            [self chamaTela:@"JackPotView"];
        }
    } else {
        if (indexPath.row == 0) {
            // Tela de Liga
            [self chamaTela:@"LigaView"];
        } else if (indexPath.row == 1) {
            // Tela de Campeonato
            [self chamaTela:@"CampeonatoView"];
        } else if (indexPath.row == 2) {
            // ação de desconectar
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"PokerGames" message:@"Deseja realmente desconetar?" delegate:self cancelButtonTitle:@"Não" otherButtonTitles:@"Sim", nil];
            [alert show];
        }
    }
}

#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 33;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    if (sectionIndex == 0)
        return 6;
    
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if (indexPath.section == 0) {
        NSArray *titles = @[@"Ranking Geral", @"Ranking dos Torneios", @"Torneios Disponíveis", @"Meus Resultados", @"Lista de Jogadores", @"Jackpot"];
        cell.textLabel.text = titles[indexPath.row];
    } else {
        NSArray *titles = @[@"Liga", @"Campeonato", @"Desconectar"];
        cell.textLabel.text = titles[indexPath.row];
    }
    
    return cell;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // opcao YES
	if (buttonIndex == 1) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Desconectando";
        
		[[PokerGamesFacade sharedInstance] efetuaLogout];
		[[PokerGamesFacade sharedInstance] setJogadorLogin:nil];
        
        // desregistra o dispositivo
        [[PokerGamesFacade sharedInstance] registraDispositivoWithBlock:[[PokerGamesFacade sharedInstance] apnsToken]
                                                             deviceUUID:[PokerGamesUtil deviceUUID]
                                                              idJogador:nil
                                              constructingBodyWithBlock:^(NSString *result, NSError *error) {
            if (error) {
              NSLog(@"Erro ao desregistrar dispositivo ao efetuar logout: %@", error);
            }
        }];
        
        [hud hide:YES];
        
        [self chamaTela:@"LoginJogadorView"];
	}
}

-(void) chamaTela:(NSString*)identifier {
    UINavigationController *navigationController = (UINavigationController *)self.frostedViewController.contentViewController;
    
    UIViewController *newTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
    
    navigationController.viewControllers = @[newTopViewController];
    
    NSLog(@"chamaTela: %@", newTopViewController);
    
    [self.frostedViewController hideMenuViewController];
}

@end
