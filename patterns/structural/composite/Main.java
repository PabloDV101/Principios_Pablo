public class Main{
public static void main(String[] args){
Graphic circle1 = new Circle();
Graphic circle2 = new Circle();	

CompositeGraphic group = new CompositeGraphic();
group.add(circle1);
group.add(circle2);

group.draw();
}

}
