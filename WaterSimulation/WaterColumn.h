@interface WaterColumn : NSObject {
@private
    CGFloat _targetHeight;
}

@property(assign, nonatomic) CGFloat Height;
@property(assign, nonatomic) CGFloat Speed;

- (id)initWithTargetHeight:(CGFloat)targetHeight :(CGFloat)height :(CGFloat)speed;

-(void)updateTargetHeight:(CGFloat) height;

- (void)update:(CGFloat)dampening :(CGFloat)tension;

-(void) updateRotationWithX: (NSInteger)posX AndY:(NSInteger)posY AndZ:(NSInteger)posZ AndIndex:(NSInteger)index;

@end
