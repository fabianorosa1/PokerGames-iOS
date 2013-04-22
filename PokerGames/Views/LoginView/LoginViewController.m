//
//  ADVLoginViewController.m
//  apartmentshare
//
//  Created by Tope Abayomi on 22/01/2013.
//  Copyright (c) 2013 App Design Vault. All rights reserved.
//

#import "LoginViewController.h"
#import "ADVTheme.h"
#import "AppDelegate.h"
#import "Jogador.h"
#import "MBProgressHUD.h"
#import "AFNetworking.h"

@implementation LoginViewController

@synthesize userTextField = _userTextField, passwordTextField = _passwordTextField;

- (AppDelegate *)appDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

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
    
    id <ADVTheme> theme = [ADVThemeManager sharedTheme];
    
    self.loginTableView = [[UITableView alloc] initWithFrame:CGRectMake(16, 50, 294, 110) style:UITableViewStyleGrouped];
    
    [self.loginTableView setScrollEnabled:NO];
    [self.loginTableView setBackgroundView:nil];
    [self.view addSubview:self.loginTableView];
    
    [self.loginTableView setDataSource:self];
    [self.loginTableView setDelegate:self];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[theme viewBackground]]];
    
    
    [self.loginButton setBackgroundImage:[theme colorButtonBackgroundForState:UIControlStateNormal] forState:UIControlStateNormal];
    [self.loginButton setBackgroundImage:[theme colorButtonBackgroundForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
    
    self.userTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 10, 260, 50)];
    [self.userTextField setPlaceholder:@"Apelido"];
    [self.userTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    
    
    self.passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 10, 260, 50)];
    [self.passwordTextField setPlaceholder:@"Senha"];
    [self.passwordTextField setSecureTextEntry:YES];
    [self.passwordTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    
    self.userTextField.delegate = self;
    self.passwordTextField.delegate = self;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = @"Poker Games";
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell* cell = nil;
    
    if(indexPath.row == 0){
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UsernameCell"];
        
        [cell addSubview:self.userTextField];
        
    }else {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PasswordCell"];
        
        [cell addSubview:self.passwordTextField];
    }
    
    return cell;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark IB Actions

//Login button pressed
-(IBAction)logInPressed:(id)sender
{
    
    [self.view endEditing:YES];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Autenticando";
    
    // efetua validacao do login
    [Jogador efetuaLoginPlayerWithBlock:[self.userTextField text]
                                 passw:[self.passwordTextField text]
             constructingBodyWithBlock:^(Jogador *player, NSError *error) {
        
        [hud hide:YES];
                 
        if (error) {
            // Erro ao efetuar login
            NSInteger httpErrorCode = [[[error userInfo] objectForKey:AFNetworkingOperationFailingURLResponseErrorKey] statusCode];
            //NSLog(@"Http error code %i",httpErrorCode);
            NSString *msgError = nil;
            
            if (httpErrorCode == 401) {
                msgError = @"Usuário ou senha inválido!";
                [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Autenticação", nil) message:msgError delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
            } else {
                [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Erro", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil] show];
            }
        } else {
            // login com sucesso
            
            //NSLog(@"Player: %@", player );
            [self appDelegate].playerLogin = player;
            [self performSegueWithIdentifier:@"SelecaoLiga" sender:self];
        }
     
    }];
    
//    [self.client loginWithUsername:self.userTextField.text password:self.passwordTextField.text onSuccess:^(NSDictionary *results) {
//        
//        if ([[[self appDelegate] client] isLoggedIn]) {
//            NSLog(@"Logged in");
//        }
//        
//        [self performSegueWithIdentifier:@"SelecaoLiga" sender:self];
//        
//    } onFailure:^(NSError *error) {
//        //Something bad has ocurred
//        NSString *errorString = [error localizedDescription];
//        UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//        [errorAlertView show];
//    }];
}

@end
