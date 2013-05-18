//
//  ListaJogadoresTableViewController.h
//  PokerGames
//
//  Created by Fabiano Rosa on 03/05/13.
//  Copyright (c) 2013 Fabiano Rosa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <AddressBookUI/AddressBookUI.h>

@interface ListaJogadoresTableViewController : UITableViewController <UIGestureRecognizerDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, ABNewPersonViewControllerDelegate, UISearchBarDelegate, UISearchDisplayDelegate>

@property (nonatomic, weak) IBOutlet UISearchBar* searchBar;

-(IBAction)goToSearch:(id)sender;

@end
