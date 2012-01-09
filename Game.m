//
//  Game.m
//  SantaSled
//
//  Created by Víctor Baro on 17/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//



#import "Game.h"
#import "GameOver.h"

@implementation Game

@synthesize options = _options;
@synthesize livesSprites = _livesSprites;
@synthesize playerScoreLabel = _playerScoreLabel;

+(CCScene *) scene {
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	Game *layer = [Game node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (void) removeAnySprite:(CCSprite *) sender {
    
    if (sender.tag == 1) {
        _numberOfTrees -= 1;
    } else if (sender.tag == 2) {
        _numberOfRocks -= 1;
    } else if (sender.tag == 3) {
        [self unschedule:@selector(pickCandy:)];
    }
    
    [self removeChild:sender cleanup:YES];
}

- (void) addClouds {
    _cloud = [CCSprite spriteWithFile:@"cloud.png"];
    _cloud.opacity = (arc4random()%150)+100;
    _cloud.scale = ((arc4random()%3)+2)*0.5;

    CGSize winSize = [[CCDirector sharedDirector] winSize];
    int minX = _cloud.contentSize.width/2;
    int maxX = winSize.width - _cloud.contentSize.width/2;
    int rangeX = maxX - minX;
    int actualX = (arc4random() % rangeX) + minX;
    _cloud.position = ccp(actualX, -_cloud.contentSize.height/2);
    [self addChild:_cloud z:3 tag:0];
    
    id moveCloud = [CCMoveTo actionWithDuration:((arc4random()%9)+1) position:ccp(actualX,_cloud.contentSize.height/2+winSize.height)];
    id moveCloudFinised = [CCCallFuncN actionWithTarget:self selector:@selector(removeAnySprite:)];
    [_cloud runAction:[CCSequence actions:moveCloud, moveCloudFinised, nil]];
         
}

- (void) bckgFinished {
     CGSize windowSize = [[CCDirector sharedDirector] winSize];
    _background.position = ccp(0,windowSize.height);
    id moveBckg = [CCMoveTo actionWithDuration:_timeB position:ccp(0,_background.contentSize.height - windowSize.height)];
    id moveFinished = [CCCallFunc actionWithTarget:self selector:@selector(bckgFinished)];
    [_background runAction:[CCSequence actions:moveBckg, moveFinished, nil]];
}

- (void) addTrees {
    
    if (_numberOfTrees <= 2) {
          
        _tree = [CCSprite spriteWithFile:@"tree.png"];
        //todo esto es lo mismo que para añadir una nube
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        int minX = _tree.contentSize.width/2; 
        int maxX = winSize.width - _tree.contentSize.width/2;
        int rangeX = maxX - minX;
        int actualX = (arc4random() % rangeX) + minX;
        _tree.position = ccp(actualX, -_tree.contentSize.height/2);
        [self addChild:_tree z:2 tag:1];
        _numberOfTrees +=1;
    
        _timeT = (_tree.contentSize.height + winSize.height)/_speed;
    
        id moveSprite = [CCMoveTo actionWithDuration:_timeT position:ccp(actualX,_tree.contentSize.height/2+winSize.height)];
        id moveSpriteFinished = [CCCallFuncN actionWithTarget:self selector:@selector(removeAnySprite:)];
        [_tree runAction:[CCSequence actions:moveSprite, moveSpriteFinished, nil]];
    }
}

- (void) addRock {
    
    if (_numberOfRocks <= 3) {
        //Lo mismo que para los árboles
        _rock = [CCSprite spriteWithFile:@"rock.png"];
    
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        int minX = _rock.contentSize.width/2;
        int maxX = winSize.width - _rock.contentSize.width/2;
        int rangeX = maxX - minX;
        int actualX = (arc4random() % rangeX) + minX;
        _rock.position = ccp(actualX, -_rock.contentSize.height/2);
        [self addChild:_rock z:2 tag:2];

        _numberOfRocks +=1;
    
        _timeR = (_rock.contentSize.height + winSize.height)/_speed;
    
        id moveSprite = [CCMoveTo actionWithDuration:_timeR position:ccp(actualX,_rock.contentSize.height/2+winSize.height)];
        id moveSpriteFinished = [CCCallFuncN actionWithTarget:self selector:@selector(removeAnySprite:)];
        [_rock runAction:[CCSequence actions:moveSprite, moveSpriteFinished, nil]];
        
    }
}

- (void) positionMeteor {
    _meteor.position = _santa.position;
}

- (void) pickCandy:(ccTime)dt {
    
    if ((CGRectIntersectsRect(_santa.boundingBox, _candy.boundingBox)) && (!_isPowerMode)) {
        
        _powerCrono = 0;
        _isPowerMode = YES;
        _isSantaTouched = YES; //Ponemos esto por si queda algun arbol/piedra en la pantalla, que no nos quiten una vida/gameover
        _candy.visible = NO;
        
        CGSize windowSize = [[CCDirector sharedDirector] winSize];
        _powerBckg = [CCSprite spriteWithFile:@"snowPower.png"];
        _powerBckg.anchorPoint = ccp(0,1);
        _powerBckg.scaleX = 0.7;
        _powerBckg.position = ccp(0,windowSize.height);
        
        [self addChild:_powerBckg z: 0]; //La situamos justo encima del fondo original
        
        [self schedule:@selector(bckgPowerFinished)];
        
        /*_meteor = [[CCParticleMeteor alloc] init];
        _meteor.texture = [[CCTextureCache sharedTextureCache] addImage:@"snow.png"];
        _meteor.position = _santa.position;
        _meteor.emissionRate = 5;
        [self addChild:_meteor];
        [self schedule:@selector(positionMeteor)];*/
        
    }
    
    
    if (_isPowerMode) {
        _powerCrono += dt;
        if (_powerCrono >= 2) {
            _isSantaTouched = NO;
            _isPowerMode = NO;
            _powerBckg.visible = NO;
            [_powerBckg removeFromParentAndCleanup:YES];
            _powerCrono = 0;
            [self unschedule:@selector(bckgPowerFinished)];
        }
    }
}

- (void) addCandy:(ccTime)dt {
    
    _candy = [CCSprite spriteWithFile:@"Candy.png"];
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    int minX = _candy.contentSize.width/2;
    int maxX = winSize.width - _candy.contentSize.width/2;
    int rangeX = maxX - minX;
    int actualX = (arc4random() % rangeX) + minX;
    _candy.position = ccp(actualX, -_candy.contentSize.height/2);
    [self addChild:_candy z:1 tag:3];
    
    
    _timeC = (_candy.contentSize.height + winSize.height)/_speed;
    
    [self schedule:@selector(pickCandy:) interval:0.05];
    
    id moveSprite = [CCMoveTo actionWithDuration:_timeC position:ccp(actualX,_candy.contentSize.height/2+winSize.height)];
    id moveSpriteFinished = [CCCallFuncN actionWithTarget:self selector:@selector(removeAnySprite:)];
    [_candy runAction:[CCSequence actions:moveSprite, moveSpriteFinished, nil]];
    
}

- (void) bckgPowerFinished {
    CGSize windowSize = [[CCDirector sharedDirector] winSize];
    _powerBckg.position = ccp(0,windowSize.height);
    id moveBckg = [CCMoveTo actionWithDuration:0.5 position:ccp(0,_powerBckg.contentSize.height - windowSize.height)];
    id moveFinished = [CCCallFunc actionWithTarget:self selector:@selector(bckgPowerFinished)];
    [_powerBckg runAction:[CCSequence actions:moveBckg, moveFinished, nil]];
}

- (void) hit:(ccTime)dt {
    
    //Choque contra roca
    if ((CGRectIntersectsRect(_santa.boundingBox, _rock.boundingBox)) && !_isSantaTouched){
        _isSantaTouched = YES;
        id hit = [CCBlink actionWithDuration:3.1 blinks:9];
        [_santa runAction:hit];
        _lives -= 1;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SantaLivesNotification" object:nil];
        if (_lives == 0) {
                _isGameOver = YES;
            }
    }
    
    //Acción que se lanza en caso de que Santa choque con una piedra para que durante 3 segundos no pueda chocar contra nada más
    if (_isSantaTouched) {
        _touchedCrono += dt;
        if (_touchedCrono >= 3) {
            _isSantaTouched = NO;
            _touchedCrono = 0;
        }
    }
    
    //Choque contra arbol
    if ((CGRectIntersectsRect(_santa.boundingBox, _tree.boundingBox)) && !_isSantaTouched){
        _isGameOver = YES;
    }

}

- (void) score:(ccTime)dt {
    
    if (!_isPowerMode){
    //El dt es igual a 0.5, si multiplicamos por 10 hacemos que cada 0.5seg aumente el Score 5puntos
    _score += dt*10;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ScoreNotification"
                                                        object:nil];
    } else if (_isPowerMode){
        _score += dt*20;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ScoreNotification"
                                                            object:nil];
    }
    
    if (_isGameOver){
        [self pauseSchedulerAndActions];
        [[CCDirector sharedDirector]replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[GameOver node]]];
    }
    
}

- (void) startGame {
    
    CGSize windowSize = [[CCDirector sharedDirector] winSize];
    
    //Activamos los gestos en pantalla
    self.isTouchEnabled = YES;

    
    //Iniciamos las opciones y variables
    
    _timeB = (_background.contentSize.height - 2 * windowSize.height)/_speed;
    
    //Movemos el fondo
    id moveBckg = [CCMoveTo actionWithDuration:_timeB position:ccp(0,_background.contentSize.height - windowSize.height)];
    id moveFinished = [CCCallFunc actionWithTarget:self selector:@selector(bckgFinished)];
    [_background runAction:[CCSequence actions:moveBckg, moveFinished, nil]];
    
    
    //Añadimos nubes para despistar y dar ambiente
    [self schedule:@selector(addClouds) interval:0.5];
    
    //Añadimos los árboles
    [self schedule:@selector(addTrees) interval:((arc4random()%5)+1)*0.5];
    _numberOfTrees = 1;
    
    //Añadimos las piedras
    [self schedule:@selector(addRock) interval:((arc4random()%5)+1)*0.5];
    _numberOfRocks = 1;
    
    //Añadimos el caramelo
    [self schedule:@selector(addCandy:) interval:5];
    
    //Creamos un schedule para los choques
    [self schedule:@selector(hit:) interval:0.05];
    
    
    //La puntuación será en función del tiempo
    [self schedule:@selector(score:) interval:0.5];
    
}

- (void) pauseMenu{
    
    
}

- (void) updateLives:(NSNotification *) notification {
    
    //quitamos los sprites de la pantalla
    [self.livesSprites enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self removeChild:obj cleanup:YES];
    }];
    
    //borramos el contenido del array
    [self.livesSprites removeAllObjects];
    
    //ponemos los corazoncitos que hagan falta segun _lives
    for(int i = 0; i < _lives; i++) {
        CCSprite *sprite = [CCSprite spriteWithFile:@"heart.png"];
        sprite.position = ccp(30 + (i * 30), 450);
        sprite.scale = 0.6;
        [self.livesSprites addObject:sprite];
        [self addChild:sprite z:5];
    }
    
}

- (void) updateScore:(NSNotification *) notification {
    [self.playerScoreLabel setString:[NSString stringWithFormat:@"%d",_score]];
}

- (id) init {
	if( (self=[super init])) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
        NSString *documentsDirectory = [paths objectAtIndex:0]; 
        NSString *path = [documentsDirectory stringByAppendingPathComponent:@"options.plist"]; 
        _options = [[NSDictionary alloc]initWithContentsOfFile:path];
        
        if ([[_options valueForKey:@"mode"] isEqualToString:@"Normal"]) {
            NSArray *values = [[NSArray alloc] initWithArray:[_options valueForKey:@"values1"]];
            _speed = [[values objectAtIndex:0]floatValue];
            _lives = [[values objectAtIndex:1]intValue];
        }
        
        if ([[_options valueForKey:@"mode"] isEqualToString:@"Dificil"]) {
            NSArray *values = [[NSArray alloc] initWithArray:[_options valueForKey:@"values2"]];
            _speed = [[values objectAtIndex:0]floatValue];
            _lives = [[values objectAtIndex:1]intValue];
        }
        
        _touchedCrono = 0;
        _score = 0;
        _isSantaTouched = NO;
        _isPowerMode = NO;
        
        //Tamaño de la pantalla
        CGSize windowSize = [[CCDirector sharedDirector] winSize];
        
        //Creamos el fondo y lo situamos
        _background = [CCSprite spriteWithFile:@"snowBckg.png"];
        _background.anchorPoint = ccp(0,1);
        _background.scaleX = 0.7;
        _background.position = ccp(0,windowSize.height);
        
        [self addChild:_background z: -1];
        
        
        //Añadimos al personaje
        _santa = [CCSprite spriteWithFile:@"santa.png"];
        _santa.anchorPoint = ccp(0.5,0.5);
        _santa.position = ccp(windowSize.width/2, windowSize.height + _santa.contentSize.height/2); //Justo encima de la pantalla
        
        [self addChild:_santa z:2];
        
        id moveSanta = [CCEaseIn actionWithAction:[CCMoveTo actionWithDuration:3 position:ccp(windowSize.width/2, windowSize.height/2+_santa.contentSize.height)] rate:5];
        id moveDone = [CCCallFunc actionWithTarget:self selector:@selector(startGame)];
        [_santa runAction:[CCSequence actions: moveSanta, moveDone, nil]];
        
        //Añadimos el menú de pausa
        CCMenuItemFont *pause = [CCMenuItemFont itemFromString:@"II" target:self selector:@selector(pauseMenu)];
        pause.color = ccBLACK;
        CCMenu *menu = [CCMenu menuWithItems:pause, nil];
        menu.position = ccp (windowSize.width - 35, windowSize.height - 35);
        [self addChild:menu];
        
        
        
        _livesSprites = [[NSMutableArray alloc] init];
        
        // Nos registramos a las notificaciones de las vidas del santa
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateLives:)
                                                     name:@"SantaLivesNotification"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SantaLivesNotification"
                                                            object:nil];
        
        //Para el Score
        _playerScoreLabel = [[CCLabelTTF labelWithString:@"0"
                                              dimensions:CGSizeMake(100, 25)
                                               alignment:UITextAlignmentRight
                                                fontName:@"Helvetica"
                                                fontSize:18] retain];
        _playerScoreLabel.color = ccBLACK;
        _playerScoreLabel.position = ccp(windowSize.width/2,450);
        [self addChild:_playerScoreLabel z:5];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateScore:)
                                                     name:@"ScoreNotification"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ScoreNotification"
                                                            object:nil];
        
        
        
        
	}
	return self;
}

- (void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch  *theTouch = [touches anyObject];
    _finishP = [theTouch locationInView:[theTouch view]];
    _centerPad = _finishP;
}

- (void) ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    CGSize windowSize = [[CCDirector sharedDirector] winSize];
    
    _startP = _finishP;
    
    UITouch  *theTouch = [touches anyObject];
    _finishP = [theTouch locationInView:[theTouch view]];
    
    
    CGPoint vector;
    vector.x = _finishP.x - _startP.x;
    
    float actualX = _santa.position.x + (4 * vector.x);
    
    if ((actualX < windowSize.width - _santa.contentSize.width/2 ) && (actualX > _santa.contentSize.width/2)) {
        _santa.position = ccp( actualX , _santa.position.y);
        /*explicar rotación
        if (_centerPad.x - _finishP.x > 0){  //dentro del if (vector.x < 0)
            id rotate1 = [CCRotateTo actionWithDuration:0.01 angle:20];
            [_santa runAction:rotate1];
        } else if (_centerPad.x - _finishP.x < 0) {
            id rotate2 = [CCRotateTo actionWithDuration:0.01 angle:-20];
            [_santa runAction:rotate2];
        }
    } else {
        id rotate3 = [CCRotateTo actionWithDuration:0.01 angle:0];
        [_santa runAction:rotate3];*/
    } 
    
}




@end
