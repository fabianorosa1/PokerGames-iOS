//
//  MenuViewController.m
//  ECSlidingViewController
//
//  Created by Michael Enriquez on 1/23/12.
//  Copyright (c) 2012 EdgeCase. All rights reserved.
//

#import "MenuViewController.h"
#import "ADVTheme.h"
#import "AppDelegate.h"
#import "Jogador.h"
#import "UIImageView+AFNetworking.h"


@interface MenuViewController()
@end

@implementation MenuViewController

- (AppDelegate *)appDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

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
  
    id <ADVTheme> theme = [ADVThemeManager sharedTheme];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[theme viewBackground]]];
    
    [ADVThemeManager customizeTableView:self.tableView];
    
    // configura menu deslizante
    [self.slidingViewController setAnchorRightRevealAmount:263.0f];
    self.slidingViewController.underLeftWidthLayout = ECFullWidth;
    
    self.clearsSelectionOnViewWillAppear = NO;
    
    // adiciona canto arredonado
    self.imgViewFoto.layer.cornerRadius = 5.0;
    self.imgViewFoto.layer.masksToBounds = YES;
    
    // adiciona borda
    self.imgViewFoto.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.imgViewFoto.layer.borderWidth = 1.0;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // seta os dados do perfil
    Jogador *jogador = [self.appDelegate jogadorLogin];
    self.lblNome.text = jogador.nome;
    
    // seta a foto do jogador
    [self.imgViewFoto setImageWithURL:[Jogador buildUrlFoto:jogador.idJogador] placeholderImage:[PokerGamesUtil imgPlaceholder]];
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    id <ADVTheme> theme = [ADVThemeManager sharedTheme];
    
    UIImageView *imgBkg = [[UIImageView alloc] initWithImage:[theme tableSectionHeaderBackground]];
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 23)];
    
    lblTitle.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"navigationBackground"]];
    lblTitle.textColor = [UIColor whiteColor];
    lblTitle.font = [UIFont fontWithName:@"HelveticaNeue" size:18.0f];
    
    // verifica o titulo
    if (section == 0) {
        lblTitle.text = @"Perfil";
    } else if (section == 1) {
        lblTitle.text = @"Opções";
    } else if (section == 2) {
        lblTitle.text = @"Configurações";
    }
    
    [imgBkg addSubview:lblTitle];
    return imgBkg;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    NSString *identifier = cell.reuseIdentifier;
    NSLog(@"Menu selecionado: %@", identifier);
    UIViewController *newTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
    
    [self.slidingViewController anchorTopViewOffScreenTo:ECRight animations:nil onComplete:^{
        CGRect frame = self.slidingViewController.topViewController.view.frame;
        self.slidingViewController.topViewController = newTopViewController;
        self.slidingViewController.topViewController.view.frame = frame;
        [self.slidingViewController resetTopView];
    }];
}


@end
