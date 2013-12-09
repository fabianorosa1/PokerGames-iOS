//
//  PokerGamesUtil.h
//  PokerGames
//
//  Created by Fabiano Rosa on 27/04/13.
//  Copyright (c) 2013 Fabiano Rosa. All rights reserved.
//

@interface PokerGamesUtil : NSObject 

+ (UIImage *)menuImage;
+ (NSString *)baseURL;
+ (NSString *)baseURLFoto;

+ (UIImage *)imgPlaceholder;

+ (NSNumberFormatter*) currencyFormatter;

+ (void) setaImagemJogador:(UIImageView*)imgViewFoto foto:(NSString*)foto;
+ (NSURL*) retornaUrlFoto:(NSString*)fileFoto;

+ (NSString *)deviceUUID;

@end
