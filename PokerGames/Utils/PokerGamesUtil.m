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
static UIImage* imgMenu = nil;
static NSNumberFormatter *numberFormatter;
static BOOL indLocalData;

@implementation PokerGamesUtil

+(void)initialize
{
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
    if ([foto isKindOfClass:[NSNull class]] || [@"" isEqualToString:foto] || indLocalData == YES) {
        [imgViewFoto setImage:[UIImage imageNamed:@"jogador"]];
    } else {
         NSString *pathFoto = [NSString stringWithFormat:@"%@%@", [PokerGamesUtil baseURLFoto],  foto];
        [imgViewFoto setImageWithURL:[NSURL URLWithString:pathFoto] placeholderImage:[UIImage imageNamed:@"profile-image-placeholder"]];
    }
}

+ (NSURL*) retornaUrlFoto:(NSString*)fileFoto {
    NSString *pathFoto = [NSString stringWithFormat:@"%@%@", [PokerGamesUtil baseURLFoto],  fileFoto];
    return [NSURL URLWithString:pathFoto];
}

+ (NSNumberFormatter*) currencyFormatter {
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    return numberFormatter;
}

+ (NSString *)deviceUUID {
    UIDevice *myDevice=[UIDevice currentDevice];
    return [[myDevice identifierForVendor] UUIDString];
}

+ (UIColor *) colorFromHexString:(NSString *)hexString alpha: (CGFloat)alpha {
    NSString *cleanString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    if([cleanString length] == 3) {
        cleanString = [NSString stringWithFormat:@"%@%@%@%@%@%@",
                       [cleanString substringWithRange:NSMakeRange(0, 1)],[cleanString substringWithRange:NSMakeRange(0, 1)],
                       [cleanString substringWithRange:NSMakeRange(1, 1)],[cleanString substringWithRange:NSMakeRange(1, 1)],
                       [cleanString substringWithRange:NSMakeRange(2, 1)],[cleanString substringWithRange:NSMakeRange(2, 1)]];
    }
    if([cleanString length] == 6) {
        cleanString = [cleanString stringByAppendingString:@"ff"];
    }
    
    unsigned int baseValue;
    [[NSScanner scannerWithString:cleanString] scanHexInt:&baseValue];
    
    float red = ((baseValue >> 24) & 0xFF)/255.0f;
    float green = ((baseValue >> 16) & 0xFF)/255.0f;
    float blue = ((baseValue >> 8) & 0xFF)/255.0f;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (NSString*) paramDebugApp {
    return @"-br.com.pokergames.Pokergames.debug";
}

+ (NSString*) paramLocalDataApp {
    return @"-br.com.pokergames.Pokergames.localData";
}

+ (BOOL)getIndLocalData {
    return indLocalData;
}

+ (void)setIndLocalData:(BOOL)value {
    indLocalData = value;
}

+ (id <PokerGamesFacade>)pokerGamesFacadeInstance {
    if (indLocalData == YES) {
        return [PokerGamesLocalFacade sharedInstance];
    } else {
        return [PokerGamesRemoteFacade sharedInstance];
    }
}

@end
