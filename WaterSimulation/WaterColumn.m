#import "WaterColumn.h"

@implementation WaterColumn

@synthesize Height = _height;
@synthesize Speed = _speed;

#define ROTATION_SCALE_FACTOR -1.10
#define INDEX_SCALE_FACTOR 2.5

- (id)initWithTargetHeight:(CGFloat)targetHeight :(CGFloat)height :(CGFloat)speed {
    if (self = [super init]) {
        _targetHeight = targetHeight;
        self.Height = height;
        self.Speed = speed;
    }
    return self;
}

-(void)updateTargetHeight:(CGFloat)height{
    _targetHeight = height;
}

-(void)updateRotationWithX:(NSInteger)posX AndY:(NSInteger)posY AndZ:(NSInteger)posZ AndIndex:(NSInteger)index{
    _height += posZ * (ROTATION_SCALE_FACTOR * INDEX_SCALE_FACTOR*(index - 40));
    if (_height < 0){
        _height = 0;
    }
    
}

- (void)update:(CGFloat)dampening :(CGFloat)tension {
    CGFloat deltaHeight = _targetHeight - _height;
    _speed += tension * deltaHeight - _speed * dampening;
    _height += _speed;
}

@end
