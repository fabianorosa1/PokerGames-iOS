//
//  PokerGamesUtil.h
//  PokerGames
//
//  Created by Fabiano Rosa on 27/04/13.
//  Copyright (c) 2013 Fabiano Rosa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PokerGamesUtil : NSObject 

+ (UIImage *)menuImage;
+ (NSString *)baseURL;
+ (NSString *)baseURLFoto;

+ (UIImage *)imgPlaceholder;
+ (UIImage *)imgPrimeiroLugar;
+ (UIImage *)imgSegundoLugar;
+ (UIImage *)imgTerceiroLugar;

+ (NSNumberFormatter*) currencyFormatter;

@end
