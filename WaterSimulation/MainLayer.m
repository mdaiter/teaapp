#import "cocos2d.h"
#import "WaterNode.h"
#import "MainLayer.h"

static const NSInteger kSpeed = -220;

@implementation MainLayer

+ (CCScene *)scene {
    CCScene *scene = [CCScene node];
    MainLayer *layer = [MainLayer node];
    [scene addChild:layer];
    return scene;
}

- (id)init {
    if ((self = [super initWithColor:ccc4(255, 255, 255, 255)])) {
        self.isTouchEnabled = YES;

        CCLabelTTF *label = [CCLabelTTF labelWithString:@"Is that my business?" fontName:@"Marker Felt" fontSize:32];
        [label setColor:ccc3(0, 0, 255)];
        CGSize size = [CCDirector sharedDirector].winSize;
        label.position = ccp( size.width / 2, size.height - 50);
        [self addChild:label z:0];

        _waterNode = [[WaterNode alloc] init];
        [self addChild:_waterNode];
    }
    return self;
}

- (void)dealloc {
    [_waterNode release];
    [super dealloc];
}

- (void)draw {
    [super draw];
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:[touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];

    [_waterNode splash:location.x :kSpeed];
}

@end