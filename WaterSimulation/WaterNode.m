#import "cocos2d.h"
#import "WaterNode.h"
#import "WaterColumn.h"

NSInteger kWaterHeight = 200;
static const CGFloat kTension = 0.025f;
static const CGFloat kDampening = 0.025f;
static const CGFloat kSpread = 0.25f;

@implementation WaterNode

-(void)recalcWaterArea{
    kWaterArea = kWaterWidth * kWaterHeight;
}

- (id)init {
    if (self = [super init]) {
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        _scale = winSize.width / (kColumnCount - 1);

        [self initColors];
        [self initColumns];

        self.shaderProgram = [[CCShaderCache sharedShaderCache]
                programForKey:kCCShader_PositionColor];
        
        kWaterWidth = [[UIScreen mainScreen] bounds].size.width;
        [self recalcWaterArea];
        
        //Start motion tracking
        [self initializeMotionManager];
        //Init audio
      [self initializeSound];
    }
    return self;
}

- (void)initColors {
    ccColor4B lightBlue = ccc4(156, 13, 7, 255);
    ccColor4B darkBlue = ccc4(128, 0, 0, 255);

    for (int i = 1; i < kColumnCount * 2; i += 2) {
        _colorArray[i - 1].color = lightBlue;
        _colorArray[i].color = darkBlue;
    }
}

- (void)initColumns {
    _columns = [[NSMutableArray alloc] init];
    for (int i = 0; i < kColumnCount; i++) {
        WaterColumn *column = [[WaterColumn alloc] initWithTargetHeight:kWaterHeight :kWaterHeight :0];
        [_columns addObject:column];
        [column release];
    }
}

- (void)dealloc {
    [_columns release];
    [super dealloc];
}

//Initialize sound playing
-(void)initializeSound{
    NSString* completionSoundPath = [[NSBundle mainBundle] pathForResource:@"KermitTrimmed" ofType:@"wav"];
    NSURL* completionSoundURL = [NSURL fileURLWithPath:completionSoundPath];
    AudioServicesCreateSystemSoundID((CFURLRef) completionSoundURL, &completionSound);
    NSLog(@"Finished initializing audio");
}

-(void)initializeMotionManager{
    motionManager = [[CMMotionManager alloc] init];
    
    if ([motionManager isGyroAvailable]){
        if ([motionManager isGyroActive] == NO){
            [motionManager setGyroUpdateInterval:1.0f/2.0f];
            
            [motionManager startGyroUpdatesToQueue:[NSOperationQueue mainQueue]
                                       withHandler:^(CMGyroData *gryoData, NSError *error){
                                           NSLog(@"Gyro rotation rate: %f %f %f", gryoData.rotationRate.x, gryoData.rotationRate.y, gryoData.rotationRate.z);
                                           
                                           posX += gryoData.rotationRate.x;
                                           posY += gryoData.rotationRate.y;
                                           posZ += gryoData.rotationRate.z;
                                           for (NSUInteger i = 0; i < kColumnCount; i++) {
                                               WaterColumn *waterColumn = _columns[i];
                                               [waterColumn updateRotationWithX:gryoData.rotationRate.x
                                                                           AndY:gryoData.rotationRate.y
                                                                           AndZ:gryoData.rotationRate.z
                                                                            AndIndex:i];
                                           }

                                       }];
        }
    }
    else{
        NSLog(@"Gyroscope is not avilable");
    }
}

-(void)updateWaterTargetHeights{
    CGFloat targetHeight = kWaterArea / kWaterWidth;
    NSLog(@"New water target height: %f", targetHeight);
    for (NSInteger i = 0; i < kColumnCount; i++){
        WaterColumn *waterColumn = _columns[i];
        [waterColumn updateTargetHeight:targetHeight];
        _columns[i] = waterColumn;
    }
}

- (void)update {

    for (NSUInteger i = 0; i < kColumnCount; i++) {
        WaterColumn *waterColumn = _columns[i];
        //[waterColumn update:kDampening :kTension];
        if (waterColumn.Height > [[UIScreen mainScreen] bounds].size.height){
            //We've got an overflow! Shift everything
            NSLog(@"We've got an overflow!");
            waterColumn.Height = [[UIScreen mainScreen] bounds].size.height;
            _columns[i] = waterColumn;
            //Get water area
            int blocks_above_zero = 0;
            int min_water_height = 6400;
            for (NSUInteger j = 0; j < kColumnCount; j++){
                
                WaterColumn *swaterColumn = _columns[j];
                if (swaterColumn.Height > 0){
                    blocks_above_zero++;
                    if (swaterColumn.Height < min_water_height){
                        min_water_height = swaterColumn.Height;
                    }
                }
                //_columns[j] = swaterColumn;
            }
            //Get new water area
            kWaterArea = ((waterColumn.Height - min_water_height) / 2) * (blocks_above_zero);
            kWaterHeight = kWaterArea / kWaterWidth;
            [self updateWaterTargetHeights];
            
            AudioServicesPlaySystemSound(completionSound);
            
            //break;
        }
    }
    
    
    if (kWaterArea <= 0){
    //    AudioServicesPlaySystemSound(*(_completionSound));
    }
    
    CGFloat leftDeltas[kColumnCount];
    CGFloat rightDeltas[kColumnCount];

    for (NSUInteger j = 0; j < 8; j++) {
        for (NSUInteger i = 0; i < kColumnCount; i++) {

            if (i > 0) {
                leftDeltas[i] = kSpread * ([_columns[i] Height] - [_columns[i - 1] Height]);
                ((WaterColumn *) _columns[i - 1]).Speed += leftDeltas[i];
            }
            if (i < kColumnCount - 1) {
                rightDeltas[i] = kSpread * ([_columns[i] Height] - [_columns[i + 1] Height]);
                ((WaterColumn *) _columns[i + 1]).Speed += rightDeltas[i];
            }
        }

        for (NSUInteger i = 0; i < kColumnCount; i++) {
            if (i > 0)
                ((WaterColumn *) _columns[i - 1]).Height += leftDeltas[i];
            if (i < kColumnCount - 1)
                ((WaterColumn *) _columns[i + 1]).Height += rightDeltas[i];
        }
    }
}

- (void)draw {
    [self update];

    for (NSUInteger i = 0; i < kColumnCount; i++) {
        GLushort x = (GLushort) (i * _scale);
        GLushort y = (GLushort) ((WaterColumn *) _columns[i]).Height;

        _vertexArray[2 * i] = (struct Vertex) {x, y};
        _vertexArray[2 * i + 1] = (struct Vertex) {x, 0};
    }

    ccGLEnableVertexAttribs(kCCVertexAttribFlag_Position | kCCVertexAttribFlag_Color);
    [self.shaderProgram use];
    [self.shaderProgram setUniformForModelViewProjectionMatrix];

    glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_UNSIGNED_SHORT, GL_FALSE, 0, _vertexArray);
    glEnableVertexAttribArray(kCCVertexAttribFlag_Position);

    glVertexAttribPointer(kCCVertexAttrib_Color, 4, GL_UNSIGNED_BYTE, GL_TRUE, 0, _colorArray);
    glEnableVertexAttribArray(kCCVertexAttribFlag_Color);

    glDrawArrays(GL_TRIANGLE_STRIP, 0, kColumnCount * 2);
}

- (void)splash:(CGFloat)x :(CGFloat)speed {
    NSUInteger index = (NSUInteger) (x / _scale);
    if (index > 0 && index < kColumnCount) {
        WaterColumn *waterColumn = _columns[index];
        waterColumn.Speed = speed;
    }
}

@end
