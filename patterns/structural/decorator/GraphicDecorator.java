abstract class GraphicDecorator implements Graphic {
protected Graphic graphic;

protected GraphicDecorator(Graphic graphic){
this.graphic=graphic;
}
@Override
public void draw(){
graphic.draw();
}
}
