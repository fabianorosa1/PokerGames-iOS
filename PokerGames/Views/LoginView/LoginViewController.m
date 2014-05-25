//
//  ADVLoginViewController.m
//  apartmentshare
//
//  Created by Tope Abayomi on 22/01/2013.
//  Copyright (c) 2013 App Design Vault. All rights reserved.
//

#import "LoginViewController.h"
#import "Jogador.h"
#import "MBProgressHUD.h"
#import "AFNetworking.h"

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.loginButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    self.loginButton.enabled = FALSE;
    
    [self.userTextField setPlaceholder:@"Apelido"];
    [self.userTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    self.userTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    [self.passwordTextField setPlaceholder:@"Senha"];
    [self.passwordTextField setSecureTextEntry:YES];
    [self.passwordTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    self.passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    self.userTextField.delegate = self;
    self.passwordTextField.delegate = self;
    
    // ajustes layout botoes
    self.loginButton.layer.borderColor = [UIColor grayColor].CGColor;
    self.loginButton.layer.backgroundColor = [UIColor colorWithRed:98/255.0f
                                                             green:161/255.0f
                                                              blue:37/255.0f
                                                             alpha:1.0f].CGColor;
    self.loginButton.layer.borderWidth = 0.5;
    self.loginButton.layer.cornerRadius = 3;
    
    self.demoButton.layer.borderColor = [UIColor grayColor].CGColor;
    self.demoButton.layer.backgroundColor = [UIColor colorWithRed:29/255.0f
                                                            green:50/255.0f
                                                             blue:60/255.0f
                                                            alpha:1.0f].CGColor;
    self.demoButton.layer.borderWidth = 0.5;
    self.demoButton.layer.cornerRadius = 3;
    
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = @"PokerGames";
}

-(void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.title = @"Voltar";
}

-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    // remove o botão Back de navegação
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.hidesBackButton = YES;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.userTextField = nil;
    self.passwordTextField = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    [self validateTextFields];    
    return YES;
}

-(void) validateTextFields {
    if ((self.userTextField.text.length > 0) && (self.passwordTextField.text.length > 0)) {
        self.loginButton.enabled = YES;
    } else {
        self.loginButton.enabled = NO;
    }
}

- (BOOL)textFieldShouldClear:(UITextField *)textField{
    self.loginButton.enabled = NO;
    return YES;
}

#pragma mark IB Actions

//Login button pressed
-(IBAction)logInPressed:(id)sender
{
    [self efetuaLogin:[self.userTextField text] passw:[self.passwordTextField text]];
}

- (IBAction)demoPressed:(id)sender {
    [self efetuaLogin:@"nagel" passw:@"AXSXSX"];
}

- (void) efetuaLogin:(NSString*)user passw:(NSString*)passw {
    [self.view endEditing:YES];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Autenticando";
    
    // efetua validacao do login
    [[PokerGamesUtil pokerGamesFacadeInstance] efetuaLoginPlayerWithBlock:user
                                                            passw:passw
                                        constructingBodyWithBlock:^(Jogador *jogador, NSError *error) {
                                            
    [hud hide:YES];
    
    if (error) {
        // Erro ao efetuar login
        NSInteger httpErrorCode = [[[error userInfo] objectForKey:AFNetworkingOperationFailingURLResponseErrorKey] statusCode];
        //NSLog(@"Http error code %i",httpErrorCode);
        NSString *msgError = nil;
        
        if (httpErrorCode == 400) {
            msgError = @"Usuário ou senha inválido!";
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Autenticação", nil) message:msgError delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
        } else {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Erro", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
        }
    } else {
        // login com sucesso
        
        //NSLog(@"Jogador: %@", jogador );
        [[PokerGamesUtil pokerGamesFacadeInstance] setJogadorLogin:jogador];
                
        // registra o dispositivo
        // [[PokerGamesFacade sharedInstance] registraDispositivoWithBlock:[[PokerGamesFacade sharedInstance] apnsToken]
        //                                                     deviceUUID:[PokerGamesUtil deviceUUID]
        //                                                     idJogador:jogador.idJogador
        //                                      constructingBodyWithBlock:^(NSString *result, NSError *error) {
    
        //    if (error) {
        //      NSLog(@"Erro ao registrar dispositivo ao efetuar login: %@", error);
        //    }
        //}];

        [self performSegueWithIdentifier:@"SelecaoLiga" sender:self];
    }
    
    }];
}

@end
