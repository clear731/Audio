//
//  AudioMix.m
//  audioGame
//
//  Created by lingcao(曹玲) on 2017/11/8.
//  Copyright © 2017年 lingcao. All rights reserved.
//

#import "AudioMix.h"
#import <AudioToolbox/AudioToolbox.h>
#import <Foundation/Foundation.h>
#include "WaveHeader.h"

#define AudioChannels 1 //音频声道数
#define AudioSampleRate 44100 //采样率
#define AudioSampleSize 16 //采样大小

@implementation AudioMix

#pragma mark 音频+音频
// 合成音频
+(NSString *)mixAudioWithFile1:(NSString *)file1 file2:(NSString *)file2 useChannel:(BOOL)isChannel
{
    NSString *mixFilePath = [NSString stringWithFormat:@"%@/recorder3.wav",NSHomeDirectory()];
    
    @try {
        NSData *soundData1 = [NSData dataWithContentsOfFile:file1];
        NSData *data1 = [soundData1 subdataWithRange:NSMakeRange(0x1000, [soundData1 length] - 0x1000)];
        
        
        NSData *soundData2 = [NSData dataWithContentsOfFile:file2];
        NSData *data2 = [soundData2 subdataWithRange:NSMakeRange(0x1000, [soundData2 length] - 0x1000)];
        
        NSData *soundTouchData;
        if (isChannel)
        {
            soundTouchData = [AudioMix channelsPlusWithFirstData:data1 secondData:data2];
        }
        else
        {
            soundTouchData = [AudioMix pcmPlusWithFirstData:data1 secondData:data2];
        }
        
        NSMutableData *wavDatas = [[NSMutableData alloc] init];
        int fileLength = (int)soundTouchData.length;
        void *header = createWaveHeader(fileLength, AudioChannels + 1, AudioSampleRate, AudioSampleSize);
        [wavDatas appendBytes:header length:44];
        [wavDatas appendData:soundTouchData];
        
        [wavDatas writeToFile:mixFilePath atomically:YES];
        soundTouchData = nil;
        wavDatas = nil;
    }
    @catch (NSException *exception) {
        NSLog(@"exception:%@",exception);
    }

    NSLog(@"%@",mixFilePath);
    return mixFilePath;
}

//声道叠加 first , second ,first , second ,
+(NSData *)channelsPlusWithFirstData:(NSData *)firstData secondData:(NSData *)secondData
{
    NSUInteger fistLength = firstData.length;
    NSUInteger secondLength = secondData.length;
    NSUInteger datalength = (fistLength>secondLength?fistLength:secondLength);
    char *pcmSecondData = (char *)secondData.bytes;
    char *pcmFirstData = (char *)firstData.bytes;

    char *samples = (char *)malloc(sizeof(char) * datalength * 2);
    
    char *r = samples;
    char *s = pcmSecondData;
    char *f = pcmFirstData;
    for (int i = 0; i < datalength * 2; i ++ )
    {
        if (i % 2 == 0)
        {
            if (i / 2 < fistLength)
            {
                *r = *f;
                f ++;
                r++ ;
                *r = *f;
                f ++;
            }
            else
            {
                *r = 0;
                r++ ;
                *r = 0;
            }

        }
        else
        {
            if (i / 2 < secondLength)
            {
                *r = *s;
                s ++;
                r++ ;
                *r = *s;
                s ++;
            }
            else
            {
                *r = 0;
                r++ ;
                *r = 0;
            }
        }
        r ++;
    }
    
    return [NSData dataWithBytes:samples length:datalength * 2];
}
//pcm数据叠加 first/2 + second /2
+(NSData *)pcmPlusWithFirstData:(NSData *)firstData secondData:(NSData *)secondData
{
    NSUInteger fistLength = firstData.length;
    NSUInteger secondLength = secondData.length;
    NSUInteger dataSize = (fistLength>secondLength?secondLength:fistLength);
    NSUInteger datalength = (fistLength>secondLength?fistLength:secondLength);
    char *pcmSecondData = (char *)secondData.bytes;
    char *pcmFirstData = (char *)firstData.bytes;
    
    char *samples = (char *)malloc(sizeof(char) * datalength);
    
    char *r = samples;
    char *s = pcmSecondData;
    char *f = pcmFirstData;
    for (int i = 0; i < dataSize; i ++ )
    {
        *r = *f/2 + *s/2;
        f ++;
        s ++;
        r ++;
    }
    
    if (dataSize == secondLength)
    {
        NSUInteger more = fistLength - secondLength;
        for (int i = 0; i < more; i ++ )
        {
            *r = *f/2;
            f ++;
            r ++;
        }
    }
    else if (dataSize == fistLength)
    {
        NSUInteger more = secondLength - fistLength;
        for (int i = 0; i < more; i ++ )
        {
            *r = *s/2;
            s ++;
            r ++;
        }
    }
    return [NSData dataWithBytes:samples length:datalength];
}

#pragma mark 音频改变pcm数据
+(NSString *)changePcmData:(NSString *)file
{
//    NSData *test = [@"data" dataUsingEncoding:NSUTF8StringEncoding];
//    [self changePcmWithData:test];
    
    NSString *resultFilePath = [NSString stringWithFormat:@"%@/changePcmData.wav",NSHomeDirectory()];
    NSLog(@"%@",resultFilePath);
    @try {
        NSData *soundData = [NSData dataWithContentsOfFile:file];
        NSData *data = [soundData subdataWithRange:NSMakeRange(0x1000, [soundData length] - 0x1000)];// 4052 + 44
        
        // pcm/2
        NSData *soundTouchData = [AudioMix changePcmWithData:data];
        
        NSMutableData *wavDatas = [[NSMutableData alloc] init];
        int fileLength = (int)soundTouchData.length;
        void *header = createWaveHeader(fileLength, AudioChannels, AudioSampleRate/2, AudioSampleSize);
        [wavDatas appendBytes:header length:44];
        [wavDatas appendData:soundTouchData];
        
        [wavDatas writeToFile:resultFilePath atomically:YES];
        soundTouchData = nil;
        wavDatas = nil;
    }
    @catch (NSException *exception) {
        NSLog(@"exception:%@",exception);
    }
    return resultFilePath;
}

// pcm/2
+(NSData *)changePcmWithData:(NSData *)soundData
{
    NSUInteger length = soundData.length;// soundData.length bit数
    char *pcmData = (char *)soundData.bytes;
    char *samples = (char *)malloc(sizeof(char) * length);
    
    char *p = samples;
    char *q = pcmData;
    for (int i = 0; i < length; i ++ )
    {
        *p = *q/2;
        q ++;
        p ++;
    }
    return [[NSData alloc] initWithBytes:samples length:length];
}


@end
