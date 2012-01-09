//
//  Game.h
//  SantaSled
//
//  Created by Víctor Baro on 17/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"




@interface Game : CCLayer {
    
    CCSprite *_background;
    CCSprite *_cloud;
    CCSprite *_santa;
    CCSprite *_tree;
    CCSprite *_rock;
    CCSprite *_candy;
    CCSprite *_powerBckg; //fondo para cuando el santa coge el caramelo y se acelera
    
    
    CCParticleMeteor *_meteor;
    
    CGPoint _startP;
    CGPoint _finishP;
    CGPoint _centerPad; //Me conozco en todo momento el centro del 'joystic' virtual
    
    float _timeB;
    float _timeT;
    float _timeR;
    float _timeC;
    float _speed;
    float _touchedCrono;    //Contador de tiempo para cuando Santa toca una piedra
    float _powerCrono;      //Contador de tiempo para cuando Santa coge caramelo
        
    int _numberOfTrees;
    int _numberOfRocks;
    int _score;
    int _lives;
    
    BOOL _isSantaTouched;   //YES en caso de que Santa se haya chocado con una piedra
    BOOL _isGameOver;       //YES si se acaban las vidas o se choca con un arbol
    BOOL _isPowerMode;      //Yes si santa coge un caramelo
}


@property(nonatomic, retain) NSDictionary *options;         //Opciones cargadas desde la plist
@property(nonatomic, retain) NSMutableArray *livesSprites;  //MutableArray con las vidas que tenemos (los corazones en la pantalla)
@property(nonatomic, retain) CCLabelTTF *playerScoreLabel;  //Label en pantalla con la puntuación

+(CCScene *) scene;

@end
