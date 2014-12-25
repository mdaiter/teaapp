#import <CoreMotion/CoreMotion.h>
#import <AudioToolbox/AudioToolbox.h>

static const NSInteger kColumnCount = 80;

typedef struct Vertex {
    GLushort x;
    GLushort y;
} Vertex;



typedef struct Color {
    ccColor4B color;
} Color;

@interface WaterNode : CCNode {
@private
    NSMutableArray *_columns;
    CGFloat _scale;
    Vertex _vertexArray[kColumnCount * 2];
    Color _colorArray[kColumnCount * 2];
    CMMotionManager* motionManager;
    NSInteger kWaterWidth;
    NSInteger kWaterArea;
    
    //Track position
    NSInteger posX;
    NSInteger posY;
    NSInteger posZ;
    
    SystemSoundID completionSound;
}

//Sound for managing when to play

- (void)splash:(CGFloat)index :(CGFloat)speed;

@end
