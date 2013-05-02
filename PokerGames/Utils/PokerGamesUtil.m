//
//  PokerGamesUtil.m
//  PokerGames
//
//  Created by Fabiano Rosa on 27/04/13.
//  Copyright (c) 2013 Fabiano Rosa. All rights reserved.
//

#import "PokerGamesUtil.h"

// variaveis estaticas
static UIImage* imgPlaceholder = nil;
static UIImage* imgPrimeiroLugar = nil;
static UIImage* imgSegundoLugar = nil;
static UIImage* imgTerceiroLugar = nil;
static NSNumberFormatter *numberFormatter;

@implementation PokerGamesUtil

+(void)initialize
{
    imgPlaceholder = [UIImage imageNamed:@"profile-image-placeholder"];
    imgPrimeiroLugar = [UIImage imageNamed:@"primeiro"];
    imgSegundoLugar = [UIImage imageNamed:@"segundo"];
    imgTerceiroLugar = [UIImage imageNamed:@"terceiro"];
    numberFormatter = [[NSNumberFormatter alloc] init];
}

+ (UIImage *)menuImage {
	static UIImage *defaultImage = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		UIGraphicsBeginImageContextWithOptions(CGSizeMake(20.f, 13.f), NO, 0.0f);
		
		[[UIColor blackColor] setFill];
		[[UIBezierPath bezierPathWithRect:CGRectMake(0, 0, 20, 1)] fill];
		[[UIBezierPath bezierPathWithRect:CGRectMake(0, 5, 20, 1)] fill];
		[[UIBezierPath bezierPathWithRect:CGRectMake(0, 10, 20, 1)] fill];
		
		[[UIColor whiteColor] setFill];
		[[UIBezierPath bezierPathWithRect:CGRectMake(0, 1, 20, 2)] fill];
		[[UIBezierPath bezierPathWithRect:CGRectMake(0, 6,  20, 2)] fill];
		[[UIBezierPath bezierPathWithRect:CGRectMake(0, 11, 20, 2)] fill];
		
		defaultImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
        
	});
    return defaultImage;
}

+ (NSString *)baseURL {
    return @"http://pokergames.azurewebsites.net/Services/";
}

+ (NSString *)baseURLFoto {
    // http://pokergames.blob.core.windows.net/pokergamesimgs/jogador59.jpg
    return @"http://pokergames.blob.core.windows.net/pokergamesimgs/";
}

+ (UIImage *) imgPlaceholder {
    return imgPlaceholder;
}

+ (UIImage *)imgPrimeiroLugar {
    return imgPrimeiroLugar;
}

+ (UIImage *)imgSegundoLugar {
    return imgSegundoLugar;
}

+ (UIImage *)imgTerceiroLugar {
    return imgTerceiroLugar;
}

+ (NSNumberFormatter*) currencyFormatter {
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    return numberFormatter;
}

@end
