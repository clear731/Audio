//
//  AudioMix.h
//  audioGame
//
//  Created by lingcao(曹玲) on 2017/11/8.
//  Copyright © 2017年 lingcao. All rights reserved.
//  混合音频

#import <Foundation/Foundation.h>

@interface AudioMix : NSObject

+(NSString *)mixAudioWithFile1:(NSString *)file1 file2:(NSString *)file2 useChannel:(BOOL)isChannel;

+(NSString *)changePcmData:(NSString *)file;
@end
