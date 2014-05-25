//
//  PokerGamesUtil.h
//  PokerGames
//
//  Created by Fabiano Rosa on 27/04/13.
//  Copyright (c) 2013 Fabiano Rosa. All rights reserved.
//

#import "Jogador.h"
#import <MessageUI/MessageUI.h>
#import <AddressBook/AddressBook.h>
#import "PokerGamesLocalFacade.h"
#import "PokerGamesRemoteFacade.h"

////////////////////////////////////////////////////////////////////////
//////////////////    PokerGamesUtil Declaration      //////////////////
////////////////////////////////////////////////////////////////////////
@interface PokerGamesUtil : NSObject

+ (UIImage *)menuImage;
+ (NSString *)baseURL;
+ (NSString *)baseURLFoto;
+ (NSString*) paramDebugApp;
+ (NSString*) paramLocalDataApp;
+ (NSNumberFormatter*) currencyFormatter;

+ (BOOL)getIndLocalData;

+ (void)setIndLocalData:(BOOL)value;

+ (void) setaImagemJogador:(UIImageView*)imgViewFoto foto:(NSString*)foto;

+ (NSURL*) retornaUrlFoto:(NSString*)fileFoto;

+ (NSString *)deviceUUID;

+ (UIColor *) colorFromHexString:(NSString *)hexString alpha: (CGFloat)alpha;

+ (id <PokerGamesFacade>)pokerGamesFacadeInstance;

@end

