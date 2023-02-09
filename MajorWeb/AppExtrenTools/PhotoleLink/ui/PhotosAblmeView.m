//
//  PhotosAblmeView.m
//  ThrowScreen
//
//  Created by zengbiwang on 2019/2/26.
//  Copyright © 2019 cxh. All rights reserved.
//

#import "PhotosAblmeView.h"
#import "PhotoLinkPlug.h"
#import "UIImage+ThrowScreenTools.h"
@interface PhotosAblmeView()
@property(nonatomic,strong)UIButton *addMoreBtn ;
@property(nonatomic,strong)UIButton *playBtn ;
@property(nonatomic,strong)UIButton *delBtn ;
@property(nonatomic,copy)NSString *uuid;
@property(nonatomic,assign)NSInteger index;

@end
@implementation PhotosAblmeView

-(void)updateUUID:(NSString*)uuid index:(NSInteger)index{
    self.uuid = uuid;
    self.index = index;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    float cellW = self.bounds.size.width;
    float cellH = cellW;
    UIImage *image = [UIImage imageWithContentsOfFile:[[PhotoLinkPlug PhotoLinkPlug] getAssetIcon:uuid]];
    image = [image scaleImage:cellW/image.size.width];
    imageView.image = image;
    imageView.frame = CGRectMake((cellW-image.size.width)/2, (cellH-image.size.height)/2, image.size.width, image.size.height);
    [self addSubview:imageView];
    
   

    _addMoreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_addMoreBtn setImage:[UIImage imageNamed:@"photo_add_more"] forState:UIControlStateNormal];
    [_addMoreBtn addTarget:self action:@selector(add:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_addMoreBtn];
    
    _delBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_delBtn setImage:[UIImage imageNamed:@"photo_delAblum"] forState:UIControlStateNormal];
    [_delBtn addTarget:self action:@selector(del:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_delBtn];
    
    _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_playBtn setImage:[UIImage imageNamed:@"play_pic"] forState:UIControlStateNormal];
    [_playBtn addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_playBtn];
    _delBtn.frame = _addMoreBtn.frame = _playBtn.frame = self.bounds;
    //88X272
    float h = _playBtn.frame.size.height;
    float w = h*(88.0/272);
    _playBtn.frame = CGRectMake(0,0, w,h );
     _delBtn.hidden = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateEdit:) name:@"PhotoUpdateEdit" object:nil];
}

-(void)updateEdit:(NSNotification*)object{
    _delBtn.hidden = ![[object object] boolValue];
   _addMoreBtn.hidden = _playBtn.hidden = !_delBtn.hidden;
}

-(void)add:(UIButton*)sender{
    [self.delegate photos_ablme_add:self.index];
}

-(void)del:(UIButton*)sender{
    [self.delegate photos_ablme_exce:false index:self.index];
}


-(void)play:(UIButton*)sender{
    [self.delegate photos_ablme_exce:true index:self.index];
}

-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
