//
//  PokerGamesUtil.m
//  PokerGames
//
//  Created by Fabiano Rosa on 27/04/13.
//  Copyright (c) 2013 Fabiano Rosa. All rights reserved.
//

#import "PokerGamesUtil.h"
#import "UIImageView+AFNetworking.h"

// variaveis estaticas
static UIImage* imgPlaceholder = nil;
static UIImage* imgPrimeiroLugar = nil;
static UIImage* imgSegundoLugar = nil;
static UIImage* imgTerceiroLugar = nil;
static UIImage* imgFotoJogador = nil;
static UIImage* imgMenu = nil;

static NSNumberFormatter *numberFormatter;

@implementation PokerGamesUtil

+(void)initialize
{
    imgPlaceholder = [UIImage imageNamed:@"profile-image-placeholder"];
    imgPrimeiroLugar = [UIImage imageNamed:@"primeiro"];
    imgSegundoLugar = [UIImage imageNamed:@"segundo"];
    imgTerceiroLugar = [UIImage imageNamed:@"terceiro"];
    imgFotoJogador = [UIImage imageNamed:@"jogador"];    
    numberFormatter = [[NSNumberFormatter alloc] init];
}

+ (UIImage *)menuImage {
    if (imgMenu == nil) {
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
        imgMenu = defaultImage;
    }
    return imgMenu;
}

+ (NSString *)baseURL {
    return @"http://pokergames.azurewebsites.net/Services/";
}

+ (NSString *)baseURLFoto {
    // http://pokergames.blob.core.windows.net/pokergamesimgs/jogador59.jpg
    return @"http://pokergames.blob.core.windows.net/pokergamesimgs/";
}

+ (void) setaImagemJogador:(UIImageView*)imgViewFoto foto:(NSString*)foto {
    // seta a foto do jogador
    //NSLog(@">>> FOTO: %@", foto);
    if ([foto isKindOfClass:[NSNull class]] || [@"" isEqualToString:foto]) {
        [imgViewFoto setImage:imgFotoJogador];
    } else {
         NSString *pathFoto = [NSString stringWithFormat:@"%@%@", [PokerGamesUtil baseURLFoto],  foto];
        [imgViewFoto setImageWithURL:[NSURL URLWithString:pathFoto] placeholderImage:[PokerGamesUtil imgPlaceholder]];
    }
}

+ (NSURL*) retornaUrlFoto:(NSString*)fileFoto {
    NSString *pathFoto = [NSString stringWithFormat:@"%@%@", [PokerGamesUtil baseURLFoto],  fileFoto];
    return [NSURL URLWithString:pathFoto];
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

+ (NSString *)deviceUUID {
    UIDevice *myDevice=[UIDevice currentDevice];
    return [[myDevice identifierForVendor] UUIDString];
}

@end
