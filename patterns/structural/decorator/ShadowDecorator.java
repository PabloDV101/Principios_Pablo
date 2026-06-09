class ShadowDecorator extends GraphicDecorator{
public ShadowDecorator(Graphic graphic){
super(graphic);
}
@Override
public void draw(){
super.draw();
System.out.println(" ->agregando sombra");
}
}
