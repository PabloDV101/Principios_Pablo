class BorderDecorator extends GraphicDecorator {
public BorderDecorator(Graphic graphic){
super(graphic);
}
@Override
public void draw(){
super.draw();
System.out.println(" -> agregando borde");
}
}
