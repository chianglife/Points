//
//  ResponseChainViewController.m
//  PointsDemo
//
//  Created by Chiang on 2021/3/19.
//



//响应优先级 UIcontrol > UIGestureRecognizer > UIResponder

#import "ResponseChainViewController.h"

@implementation UIView(Responder)
//打印响应者链
- (void)printResponderChain {
    UIResponder *responder = self;
    printf("%s",[NSStringFromClass([responder class]) UTF8String]);
    while (responder.nextResponder) {
        responder = responder.nextResponder;
        printf(" --> %s",[NSStringFromClass([responder class]) UTF8String]);
    }
}

@end

@implementation FirstView

//这里已经找到了响应者了
//UITouch:一根手指一次触碰产生一个UITouch对象，两个手指两个
//事件传递从上往下，响应者链从下往上 （上代表父类下代表子类）。事件传递是为了寻找响应者，确定响应链
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {//UIResponder的实例方法
    NSLog(@"Found responder:%@", self.class);
    [super touchesBegan:touches withEvent:event];
}

//hitTest实现伪代码
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {//UIView的实例方法
    if (self.hidden || !self.userInteractionEnabled || self.alpha < 0.01 || ![self pointInside:point withEvent:event]) {
        return nil;
    } else {
        for (UIView *subview in [self.subviews reverseObjectEnumerator]) {
            NSLog(@"当前hsubView:%p 当前所在View:%p", subview, self);
            UIView *hitView = [subview hitTest:[subview convertPoint:point fromView:self] withEvent:event];
            if (hitView) {
                NSLog(@"确认hit-TestView:%p 当前所在View:%p", hitView, self);
                return hitView;
            }
        }
        return self;
    }
}

@end

@implementation SecondView

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"Found responder:%@", self.class);
//    [self printResponderChain];
    [super touchesBegan:touches withEvent:event];
}

//view4超出父视图不响应事件的处理方式
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    //将触摸点坐标转换到在view4上的坐标
    CGPoint pointTemp = [self convertPoint:point toView:self.view4];
    //若触摸点在view4上则返回YES，可以解决超出父视图的响应
    if ([self.view4 pointInside:pointTemp withEvent:event]) {
        return YES;
    }
    //否则返回默认的操作
    return [super pointInside:point withEvent:event];
}

@end

@implementation ThirdView

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"Found responder:%@", self.class);
    [self printResponderChain];
    [super touchesBegan:touches withEvent:event];
}

@end

@implementation FourthView

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"Found responder:%@", self.class);
    [super touchesBegan:touches withEvent:event];
}

@end

@interface ResponseChainViewController ()
@end

@implementation ResponseChainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSStringFromClass([self class]);
    
    FirstView *view1 = [[FirstView alloc] initWithFrame:CGRectMake(0, 100, 400, 400)];
    view1.backgroundColor = [UIColor redColor];
    [self.view addSubview:view1];
    
    SecondView *view2 = [[SecondView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    view2.backgroundColor = [UIColor blueColor];
    [view1 addSubview:view2];

    ThirdView *view3 = [[ThirdView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    view3.backgroundColor = [UIColor yellowColor];
    view3.userInteractionEnabled = YES;//如果为NO，会让响应者链保留到View2，自身不会响应
    [view2 addSubview:view3];
    
    //超出父视图view2坐标范围
    FourthView *view4 = [[FourthView alloc] initWithFrame:CGRectMake(150, 150, 100, 100)];
    view4.backgroundColor = [UIColor whiteColor];
    [view2 addSubview:view4];
    view2.view4 = view4;
    
    //UIControl比手势具有更高的事件响应的优先级
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(300, 300, 100, 100)];
    button.backgroundColor = [UIColor greenColor];
    [button addTarget:self action:@selector(buttonClicked) forControlEvents:UIControlEventTouchUpInside];
    [view1 addSubview:button];
    
    //UIGestureRecognizer比UIResponder具有更高的事件响应的优先级
    //cancelsTouchesInView 默认为YES。表示当手势识别器成功识别了手势之后，会通知Application取消响应链对事件的响应，并不再传递事件给第一响应者。若设置成NO，表示手势识别成功后不取消响应链对事件的响应，事件依旧会传递给第一响应者
    //delaysTouchesBegan 默认为NO。默认情况下手势识别器在识别手势期间，当触摸状态发生改变时，Application都会将事件传递给手势识别器和第一响应者；若设置成YES，则表示手势识别器在识别手势期间，截断事件，即不会将事件发送给第一响应者。
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
//    tap.cancelsTouchesInView = YES;//
//    tap.delaysTouchesBegan = YES;//这里为yes，直接截断事件传递
//    [view1 addGestureRecognizer:tap];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"Found responder:%@", self.class);
}

- (void)buttonClicked {//UIControl比手势具有更高的事件响应的优先级
    NSLog(@"button clicked ");
}

- (void)tapAction {
    NSLog(@"TapGesture ");
}

@end
